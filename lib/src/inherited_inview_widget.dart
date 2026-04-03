import 'package:flutter/widgets.dart';

import 'inview_state.dart';

class InheritedInViewWidget extends InheritedWidget {
  final InViewState? inViewState;

  const InheritedInViewWidget({
    super.key,
    this.inViewState,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedInViewWidget oldWidget) => false;
}
