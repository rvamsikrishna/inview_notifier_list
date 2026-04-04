import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stream_transform/stream_transform.dart';

import 'inherited_inview_widget.dart';
import 'inview_state.dart';

///builds a [ScrollView] and notifies when the widgets are on screen within a provided area.
class InViewNotifier extends StatefulWidget {
  ///The String list of ids of the child widgets that should be initialized as inView
  ///when the list view is built for the first time.
  final List<String> initialInViewIds;

  ///The widget that should be displayed in the [InViewNotifier].
  ///
  ///This is typically a [ScrollView] (e.g. [ListView], [CustomScrollView]),
  ///but can be any widget when a [ScrollViewWrapper] is used to wrap
  ///the scroll view with additional functionality like pull-to-refresh.
  final Widget child;

  ///The distance from the bottom of the list where the [onListEndReached] should be invoked.
  final double endNotificationOffset;

  ///The function that is invoked when the list scroll reaches the end
  ///or the [endNotificationOffset] if provided.
  final VoidCallback? onListEndReached;

  ///The duration to be used for throttling the scroll notification.
  ///Defaults to 200 milliseconds.
  final Duration throttleDuration;

  ///The axis along which the scroll view scrolls.
  final Axis scrollDirection;

  ///The function that defines the area within which the widgets should be notified
  ///as inView.
  final IsInViewPortCondition isInViewPortCondition;

  const InViewNotifier({
    super.key,
    required this.child,
    this.initialInViewIds = const [],
    this.endNotificationOffset = 0.0,
    this.onListEndReached,
    this.throttleDuration = const Duration(milliseconds: 200),
    this.scrollDirection = Axis.vertical,
    required this.isInViewPortCondition,
  });

  @override
  State<InViewNotifier> createState() => _InViewNotifierState();
}

class _InViewNotifierState extends State<InViewNotifier> {
  InViewState? _inViewState;
  StreamController<ScrollNotification>? _streamController;

  @override
  void initState() {
    super.initState();
    _initializeInViewState();
    _startListening();
  }

  @override
  void didUpdateWidget(InViewNotifier oldWidget) {
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

    _streamController!.stream
        .audit(widget.throttleDuration)
        .listen(_inViewState!.onScroll);
  }

  void _initializeInViewState() {
    _inViewState = InViewState(
      intialIds: widget.initialInViewIds,
      isInViewCondition: widget.isInViewPortCondition,
      scrollDirection: widget.scrollDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InheritedInViewWidget(
      inViewState: _inViewState,
      child: NotificationListener<ScrollNotification>(
        child: widget.child,
        onNotification: (ScrollNotification notification) {
          final AxisDirection scrollDirection =
              notification.metrics.axisDirection;

          final bool isScrollDirection = switch (widget.scrollDirection) {
            Axis.vertical => scrollDirection == AxisDirection.down ||
                scrollDirection == AxisDirection.up,
            Axis.horizontal => scrollDirection == AxisDirection.left ||
                scrollDirection == AxisDirection.right,
          };

          final double maxScroll = notification.metrics.maxScrollExtent;

          //end of the listview reached
          if (isScrollDirection &&
              maxScroll - notification.metrics.pixels <=
                  widget.endNotificationOffset) {
            if (widget.onListEndReached != null) {
              widget.onListEndReached!();
            }
          }

          //when user is not scrolling
          if (notification is UserScrollNotification &&
              notification.direction == ScrollDirection.idle) {
            if (!_streamController!.isClosed && isScrollDirection) {
              _streamController!.add(notification);
            }
          }

          if (!_streamController!.isClosed && isScrollDirection) {
            _streamController!.add(notification);
          }
          return false;
        },
      ),
    );
  }
}

///The function that defines the area within which the widgets should be notified
///as inView.
typedef IsInViewPortCondition = bool Function(
  double deltaTop,
  double deltaBottom,
  double viewPortDimension,
);

///A function that wraps the internal [ScrollView] with an additional widget.
///
///This is useful for adding pull-to-refresh, shimmer wrappers, or any other
///widget that needs to sit between the [NotificationListener] and the
///[ScrollView].
///
///The [scrollView] parameter is the fully constructed [ScrollView] created
///internally by [InViewNotifierList] or [InViewNotifierCustomScrollView].
///
///Example with a pull-to-refresh library:
///```dart
///InViewNotifierList(
///  scrollViewWrapper: (scrollView) => SmartRefresher(
///    controller: refreshController,
///    child: scrollView,
///  ),
///  // ...
///)
///```
///
///**Important:** The wrapper must allow [ScrollNotification] events to bubble
///up from the inner scroll view. Most widgets do this by default. If the
///wrapper provides its own [ScrollController], ensure it does not conflict
///with the [ScrollController] passed to [InViewNotifierList] — managing
///scroll controller ownership is the caller's responsibility.
typedef ScrollViewWrapper = Widget Function(Widget scrollView);
