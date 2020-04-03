//This widget passes down the InViewState down the widget tree;
import 'package:flutter/widgets.dart';

import 'inview_state.dart';

class InheritedInViewWidget extends InheritedWidget {
  final InViewState inViewState;
  final Widget child;

  InheritedInViewWidget({Key key, this.inViewState, this.child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedInViewWidget oldWidget) => false;
}
