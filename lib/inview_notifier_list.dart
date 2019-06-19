import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stream_transform/stream_transform.dart';

///builds a [ListView] and notifies when the widgets are on screen within a provided area.
class InViewNotifierList extends StatefulWidget {
  ///The String list of ids of the child widgets that should be initialized as inView
  ///when the list view is built for the first time.
  final List<String> initialInViewIds;

  ///The widgets that should be displayed in the listview.
  final List<Widget> children;

  ///The number of widget's contexts the InViewNotifierList should stored/cached for
  ///the calculations thats needed to be done to check if the widgets are inView or not.
  ///Defaults to 10 and should be greater than 1. This is done to reduce the number of calculations being performed.
  final int contextCacheCount;

  ///The distance from the bottom of the list where the [onListEndReached] should be invoked.
  final double endNotificationOffset;

  ///The function that is invoked when the list scroll reaches the end
  ///or the [endNotificationOffset] if provided.
  final VoidCallback onListEndReached;

  ///The duration to be used for throttling the scroll notification.
  ///Defaults to 200 milliseconds.
  final Duration throttleDuration;

  ///The axis along which the scroll view scrolls.
  final Axis scrollDirection;

  ///The function that defines the area within which the widgets should be notified
  ///as inView.
  final IsInViewPortCondition isInViewPortCondition;

  ///An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController controller;

  const InViewNotifierList({
    Key key,
    this.children = const [],
    this.initialInViewIds = const [],
    this.contextCacheCount = 10,
    this.endNotificationOffset = 0.0,
    this.onListEndReached,
    this.throttleDuration = const Duration(milliseconds: 200),
    this.scrollDirection = Axis.vertical,
    @required this.isInViewPortCondition,
    this.controller,
  })  : assert(contextCacheCount >= 1),
        assert(endNotificationOffset >= 0.0),
        assert(children != null),
        assert(isInViewPortCondition != null),
        super(key: key);

  @override
  _InViewNotifierListState createState() => _InViewNotifierListState();

  static InViewState of(BuildContext context) {
    final _InheritedInViewWidget widget = context
        .ancestorInheritedElementForWidgetOfExactType(_InheritedInViewWidget)
        .widget;
    return widget.inViewState;
  }
}

class _InViewNotifierListState extends State<InViewNotifierList> {
  InViewState _inViewState;
  StreamController<ScrollNotification> _streamController;

  @override
  void initState() {
    super.initState();
    _initializeInViewState();

    _startListening();
  }

  @override
  void didUpdateWidget(InViewNotifierList oldWidget) {
    if (oldWidget.throttleDuration != widget.throttleDuration) {
      //when throttle duration changes, close the existing stream controller if exists
      //and start listening to a stream that is throttled by new duration.
      _streamController?.close();
      _startListening();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _inViewState?.dispose();
    _inViewState = null;
    _streamController?.close();
    super.dispose();
  }

  void _startListening() {
    _streamController = StreamController<ScrollNotification>();

    _streamController.stream
        .transform(throttle(widget.throttleDuration))
        .listen(_inViewState.onScroll);
  }

  void _initializeInViewState() {
    _inViewState = InViewState(
      intialIds: widget.initialInViewIds,
      isInViewCondition: widget.isInViewPortCondition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedInViewWidget(
      inViewState: _inViewState,
      child: NotificationListener<ScrollNotification>(
        child: ListView.custom(
          controller: widget.controller,
          scrollDirection: widget.scrollDirection,
          childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return widget.children[index];
            },
            childCount: widget.children.length,
          ),
        ),
        onNotification: (ScrollNotification notification) {
          bool isScrollDirection;
          //the direction of user scroll up, down, left, right.
          final AxisDirection scrollDirection =
              notification.metrics.axisDirection;

          switch (widget.scrollDirection) {
            case Axis.vertical:
              isScrollDirection = scrollDirection == AxisDirection.down ||
                  scrollDirection == AxisDirection.up;
              break;
            case Axis.horizontal:
              isScrollDirection = scrollDirection == AxisDirection.left ||
                  scrollDirection == AxisDirection.right;
              break;
          }
          final double maxScroll = notification.metrics.maxScrollExtent;

          //end of the listview reached
          if (isScrollDirection &&
              maxScroll - notification.metrics.pixels <=
                  widget.endNotificationOffset) {
            if (widget.onListEndReached != null) {
              widget.onListEndReached();
            }
          }

          //when user is not scrolling
          if (notification is UserScrollNotification &&
              notification.direction == ScrollDirection.idle) {
            //Keeps only the last number contexts provided by user. This prevents overcalculation
            //by iterating over non visible widget contexts in scroll listener
            _inViewState.removeContexts(widget.contextCacheCount);

            if (!_streamController.isClosed && isScrollDirection) {
              _streamController.add(notification);
            }
          }

          if (!_streamController.isClosed && isScrollDirection) {
            _streamController.add(notification);
          }
        },
      ),
    );
  }
}

//This widget passes down the InViewState down the widget tree;
class _InheritedInViewWidget extends InheritedWidget {
  final InViewState inViewState;
  final Widget child;

  _InheritedInViewWidget({Key key, this.inViewState, this.child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedInViewWidget oldWidget) => false;
}

class _WidgetData {
  final BuildContext context;
  final String id;

  _WidgetData({@required this.context, @required this.id});
}

///Class that stores the context's of the widgets and String id's of the widgets that are
///currently in-view. It notifies the listeners when the list is scrolled.
class InViewState extends ChangeNotifier {
  ///The context's of the widgets in the listview that the user expects a
  ///notification whether it is in-view or not.
  Set<_WidgetData> _contexts;

  ///The String id's of the widgets in the listview that the user expects a
  ///notification whether it is in-view or not. This helps to make recognition easy.
  List<String> _currentInViewIds = [];
  final IsInViewPortCondition _isInViewCondition;

  InViewState({List<String> intialIds, Function isInViewCondition})
      : _isInViewCondition = isInViewCondition {
    _contexts = Set<_WidgetData>();
    _currentInViewIds.addAll(intialIds);
  }

  ///Number of widgets that are currently in-view.
  int get inViewWidgetIdsLength => _currentInViewIds.length;

  int get numberOfContextStored => _contexts.length;

  ///Add the widget's context and an unique string id that needs to be notified.
  void addContext({@required BuildContext context, @required String id}) {
    _contexts.add(_WidgetData(context: context, id: id));
  }

  ///Keeps the number of widget's contexts the InViewNotifierList should stored/cached for
  ///the calculations thats needed to be done to check if the widgets are inView or not.
  ///Defaults to 10 and should be greater than 1. This is done to reduce the number of calculations being performed.
  void removeContexts(int letRemain) {
    if (_contexts.length > letRemain) {
      _contexts = _contexts.skip(_contexts.length - letRemain).toSet();
    }
  }

  ///Checks if the widget with the `id` is currently in-view or not.
  bool inView(String id) {
    return _currentInViewIds.contains(id);
  }

  ///The listener that is called when the list view is scrolled.
  void onScroll(ScrollNotification notification) {
    // Iterate through each item to check
    // whether it is in the viewport
    _contexts.forEach((_WidgetData item) {
      // Retrieve the RenderObject, linked to a specific item
      final RenderObject renderObject = item.context.findRenderObject();

      // If none was to be found, or if not attached, leave by now
      if (renderObject == null || !renderObject.attached) {
        return;
      }

      //Retrieve the viewport related to the scroll area
      final RenderAbstractViewport viewport =
          RenderAbstractViewport.of(renderObject);
      final double vpHeight = notification.metrics.viewportDimension;
      final RevealedOffset vpOffset =
          viewport.getOffsetToReveal(renderObject, 0.0);

      // Retrieve the dimensions of the item
      final Size size = renderObject?.semanticBounds?.size;

      //distance from top of the widget to top of the viewport
      final double deltaTop = vpOffset.offset - notification.metrics.pixels;

      //distance from bottom of the widget to top of the viewport
      final double deltaBottom = deltaTop + size.height;
      bool isInViewport = false;

      //Check if the item is in the viewport by evaluating the provided widget's isInViewPortCondition condition.
      isInViewport = _isInViewCondition(deltaTop, deltaBottom, vpHeight);

      if (isInViewport) {
        //prevent changing the value on every scroll if its already the same
        if (!_currentInViewIds.contains(item.id)) {
          _currentInViewIds.add(item.id);
          notifyListeners();
        }
      } else {
        if (_currentInViewIds.contains(item.id)) {
          _currentInViewIds.remove(item.id);
          notifyListeners();
        }
      }
    });
  }
}

///The function that defines the area within which the widgets should be notified
///as inView.
typedef bool IsInViewPortCondition(
  double deltaTop,
  double deltaBottom,
  double viewPortDimension,
);
