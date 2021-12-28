import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inview_notifier_list/src/widget_data.dart';

import 'inview_notifier.dart';

///Class that stores the context's of the widgets and String id's of the widgets that are
///currently in-view. It notifies the listeners when the list is scrolled.
class InViewState extends ChangeNotifier {
  ///The context's of the widgets in the listview that the user expects a
  ///notification whether it is in-view or not.
  late Set<WidgetData> _contexts;

  ///The String id's of the widgets in the listview that the user expects a
  ///notification whether it is in-view or not. This helps to make recognition easy.
  List<String> _currentInViewIds = [];
  final IsInViewPortCondition? _isInViewCondition;

  final Axis _scrollDirection;

  InViewState(
      {required List<String> intialIds,
      required Axis scrollDirection,
      bool Function(double, double, double)? isInViewCondition})
      : _scrollDirection = scrollDirection,
        _isInViewCondition = isInViewCondition {
    _contexts = Set<WidgetData>();
    _currentInViewIds.addAll(intialIds);
  }

  ///Number of widgets that are currently in-view.
  int get inViewWidgetIdsLength => _currentInViewIds.length;

  int get numberOfContextStored => _contexts.length;

  ///Add the widget's context and an unique string id that needs to be notified.
  void addContext({required BuildContext? context, required String id}) {
    _contexts.removeWhere((d) => d.id == id);
    _contexts.add(WidgetData(context: context, id: id));
  }

  void removeContext({required BuildContext context}) {
    _contexts.removeWhere((d) => d.context == context);
  }

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
    _contexts.forEach((WidgetData item) {
      // Retrieve the RenderObject, linked to a specific item
      final RenderObject? renderObject = item.context!.findRenderObject();

      // If none was to be found, or if not attached, leave by now
      if (renderObject == null || !renderObject.attached) {
        return;
      }

      //Retrieve the viewport related to the scroll area
      final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject)!;
      final double vpHeight = notification.metrics.viewportDimension;
      final RevealedOffset vpOffset = viewport.getOffsetToReveal(renderObject, 0.0);

      // Retrieve the dimensions of the item
      final Size size = renderObject.semanticBounds.size;

      //distance from top of the widget to top of the viewport
      final double deltaTop = vpOffset.offset - notification.metrics.pixels;

      final double itemDimension = _scrollDirection == Axis.vertical ? size.height : size.width;
      //distance from bottom of the widget to top of the viewport
      final double deltaBottom = deltaTop + itemDimension;
      bool isInViewport = false;

      //Check if the item is in the viewport by evaluating the provided widget's isInViewPortCondition condition.
      isInViewport = _isInViewCondition!(deltaTop, deltaBottom, vpHeight);

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
