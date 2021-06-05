import 'package:flutter/material.dart';
import 'package:inview_notifier_list/src/inview_notifier.dart';

import 'inherited_inview_widget.dart';
import 'inview_state.dart';

///builds a [ListView] and notifies when the widgets are on screen within a provided area.
///
///The constructor takes an [IndexedWidgetBuilder] which builds the children on demand.
///It's just like the [ListView.builder].
class InViewNotifierList extends InViewNotifier {
  InViewNotifierList({
    Key? key,
    int? itemCount,
    required IndexedWidgetBuilder builder,
    List<String> initialInViewIds = const [],
    int contextCacheCount = 10,
    double endNotificationOffset = 0.0,
    VoidCallback? onListEndReached,
    Duration throttleDuration = const Duration(milliseconds: 200),
    Axis scrollDirection = Axis.vertical,
    required IsInViewPortCondition isInViewPortCondition,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    bool addAutomaticKeepAlives = true,
  })  : assert(contextCacheCount >= 1),
        assert(endNotificationOffset >= 0.0),
        super(
          key: key,
          initialInViewIds: initialInViewIds,
          endNotificationOffset: endNotificationOffset,
          onListEndReached: onListEndReached,
          throttleDuration: throttleDuration,
          contextCacheCount: contextCacheCount,
          isInViewPortCondition: isInViewPortCondition,
          child: ListView.builder(
            padding: padding,
            controller: controller,
            scrollDirection: scrollDirection,
            physics: physics,
            reverse: reverse,
            primary: primary,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            itemBuilder: builder,
          ),
        );

  static InViewState? of(BuildContext context) {
    final InheritedInViewWidget widget = context
        .getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()!
        .widget as InheritedInViewWidget;
    return widget.inViewState;
  }
}

///builds a [CustomScrollView] and notifies when the widgets are on screen within a provided area.
///
///A [CustomScrollView] lets you supply [slivers] directly to create various scrolling effects,
///such as lists, grids, and expanding headers. For example, to create a scroll view
///that contains an expanding app bar followed by a list and a grid, use a list of
///three slivers: [SliverAppBar], [SliverList], and [SliverGrid].

class InViewNotifierCustomScrollView extends InViewNotifier {
  InViewNotifierCustomScrollView({
    Key? key,
    required List<Widget> slivers,
    List<String> initialInViewIds = const [],
    int contextCacheCount = 10,
    double endNotificationOffset = 0.0,
    VoidCallback? onListEndReached,
    Duration throttleDuration = const Duration(milliseconds: 200),
    Axis scrollDirection = Axis.vertical,
    required IsInViewPortCondition isInViewPortCondition,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    Key? center,
    double anchor = 0.0,
  }) : super(
          key: key,
          initialInViewIds: initialInViewIds,
          endNotificationOffset: endNotificationOffset,
          onListEndReached: onListEndReached,
          throttleDuration: throttleDuration,
          contextCacheCount: contextCacheCount,
          isInViewPortCondition: isInViewPortCondition,
          child: CustomScrollView(
            slivers: slivers,
            anchor: anchor,
            controller: controller,
            scrollDirection: scrollDirection,
            physics: physics,
            reverse: reverse,
            primary: primary,
            shrinkWrap: shrinkWrap,
            center: center,
          ),
        );

  static InViewState? of(BuildContext context) {
    final InheritedInViewWidget widget = context
        .getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()!
        .widget as InheritedInViewWidget;
    return widget.inViewState;
  }
}

///The widget that gets notified if it is currently inside the viewport condition
///provided by the [IsInViewPortCondition] condition.
///
///
/// ## Performance optimizations
///
/// If your [builder] function contains a subtree that does not depend on the
/// animation, it's more efficient to build that subtree once instead of
/// rebuilding it on every animation tick.
///
/// If you pass the pre-built subtree as the [child] parameter, the
/// AnimatedBuilder will pass it back to your builder function so that you
/// can incorporate it into your build.
///
/// Using this pre-built child is entirely optional, but can improve
/// performance significantly in some cases and is therefore a good practice.
class InViewNotifierWidget extends StatelessWidget {
  ///a required String property. This should be unique for every widget
  ///that wants to get notified.
  final String id;

  ///The function that defines and returns the widget that should be notified
  ///as inView.
  ///
  ///The `isInView` tells whether the returned widget is in view or not.
  ///
  ///The child should typically be part of the returned widget tree.
  final InViewNotifierWidgetBuilder builder;

  ///The child widget to pass to the builder.
  final Widget? child;

  const InViewNotifierWidget({
    Key? key,
    required this.id,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InViewState state = InViewNotifierList.of(context)!;
    state.addContext(context: context, id: id);

    return Container(
      child: AnimatedBuilder(
        animation: state,
        child: child,
        builder: (BuildContext context, Widget? child) {
          final bool isInView = state.inView(id);

          return builder(context, isInView, child);
        },
      ),
    );
  }
}

///The function that defines and returns the widget that should be notified
///as inView.
///
///The `isInView` tells whether the returned widget is in view or not.
///
///The child should typically be part of the returned widget tree.
typedef Widget InViewNotifierWidgetBuilder(
  BuildContext context,
  bool isInView,
  Widget? child,
);
