import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/src/inview_notifier.dart';

import 'inherited_inview_widget.dart';
import 'inview_state.dart';

///builds a [ListView] and notifies when the widgets are on screen within a provided area.
///
///The constructor takes an [IndexedWidgetBuilder] which builds the children on demand.
///It's just like the [ListView.builder].
class InViewNotifierList extends InViewNotifier {
  // scrollDirection is intentionally not a super parameter — it is used both
  // for super.scrollDirection and to configure the inner ListView.
  // ignore: use_super_parameters
  InViewNotifierList({
    super.key,
    int? itemCount,
    required IndexedWidgetBuilder builder,
    super.initialInViewIds,
    super.endNotificationOffset,
    super.onListEndReached,
    super.throttleDuration,
    Axis scrollDirection = Axis.vertical,
    required super.isInViewPortCondition,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? itemExtent,
    Widget? prototypeItem,
    ChildIndexGetter? findChildIndexCallback,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
    ScrollViewWrapper? scrollViewWrapper,
  })  : assert(endNotificationOffset >= 0.0),
        super(
          scrollDirection: scrollDirection,
          child: _applyWrapper(
            scrollViewWrapper,
            ListView.builder(
              padding: padding,
              controller: controller,
              scrollDirection: scrollDirection,
              physics: physics,
              reverse: reverse,
              primary: primary,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
              shrinkWrap: shrinkWrap,
              itemCount: itemCount,
              itemBuilder: builder,
              itemExtent: itemExtent,
              prototypeItem: prototypeItem,
              findChildIndexCallback: findChildIndexCallback,
              cacheExtent: cacheExtent,
              semanticChildCount: semanticChildCount,
              dragStartBehavior: dragStartBehavior,
              keyboardDismissBehavior: keyboardDismissBehavior,
              restorationId: restorationId,
              clipBehavior: clipBehavior,
            ),
          ),
        );

  static InViewState? of(BuildContext context) {
    final InheritedInViewWidget widget = context
        .getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()!
        .widget as InheritedInViewWidget;
    return widget.inViewState;
  }

  static Widget _applyWrapper(ScrollViewWrapper? wrapper, Widget scrollView) {
    return wrapper != null ? wrapper(scrollView) : scrollView;
  }
}

///builds a [CustomScrollView] and notifies when the widgets are on screen within a provided area.
///
///A [CustomScrollView] lets you supply [slivers] directly to create various scrolling effects,
///such as lists, grids, and expanding headers. For example, to create a scroll view
///that contains an expanding app bar followed by a list and a grid, use a list of
///three slivers: [SliverAppBar], [SliverList], and [SliverGrid].

class InViewNotifierCustomScrollView extends InViewNotifier {
  // scrollDirection is intentionally not a super parameter — it is used both
  // for super.scrollDirection and to configure the inner CustomScrollView.
  // ignore: use_super_parameters
  InViewNotifierCustomScrollView({
    super.key,
    required List<Widget> slivers,
    super.initialInViewIds,
    super.endNotificationOffset,
    super.onListEndReached,
    super.throttleDuration,
    Axis scrollDirection = Axis.vertical,
    required super.isInViewPortCondition,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBehavior? scrollBehavior,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    Key? center,
    double anchor = 0.0,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
    ScrollViewWrapper? scrollViewWrapper,
  }) : super(
          scrollDirection: scrollDirection,
          child: _applyWrapper(
            scrollViewWrapper,
            CustomScrollView(
              slivers: slivers,
              anchor: anchor,
              controller: controller,
              scrollDirection: scrollDirection,
              physics: physics,
              scrollBehavior: scrollBehavior,
              reverse: reverse,
              primary: primary,
              shrinkWrap: shrinkWrap,
              center: center,
              cacheExtent: cacheExtent,
              semanticChildCount: semanticChildCount,
              dragStartBehavior: dragStartBehavior,
              keyboardDismissBehavior: keyboardDismissBehavior,
              restorationId: restorationId,
              clipBehavior: clipBehavior,
            ),
          ),
        );

  static InViewState? of(BuildContext context) {
    final InheritedInViewWidget widget = context
        .getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()!
        .widget as InheritedInViewWidget;
    return widget.inViewState;
  }

  static Widget _applyWrapper(ScrollViewWrapper? wrapper, Widget scrollView) {
    return wrapper != null ? wrapper(scrollView) : scrollView;
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
class InViewNotifierWidget extends StatefulWidget {
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
    super.key,
    required this.id,
    required this.builder,
    this.child,
  });

  @override
  State<InViewNotifierWidget> createState() => _InViewNotifierWidgetState();
}

class _InViewNotifierWidgetState extends State<InViewNotifierWidget> {
  late final InViewState state;

  @override
  void initState() {
    super.initState();
    state = InViewNotifierList.of(context)!;
    state.addContext(context: context, id: widget.id);
  }

  @override
  void dispose() {
    state.removeContext(context: context);
    super.dispose();
  }

  @override
  void didUpdateWidget(InViewNotifierWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      state.removeContext(context: context);
      state.addContext(context: context, id: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final bool isInView = state.inView(widget.id);
        return widget.builder(context, isInView, child);
      },
    );
  }
}

///The function that defines and returns the widget that should be notified
///as inView.
///
///The `isInView` tells whether the returned widget is in view or not.
///
///The child should typically be part of the returned widget tree.
typedef InViewNotifierWidgetBuilder = Widget Function(
  BuildContext context,
  bool isInView,
  Widget? child,
);
