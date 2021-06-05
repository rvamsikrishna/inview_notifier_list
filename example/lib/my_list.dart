import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

import 'box.dart';

class MyList extends StatelessWidget {
  final int itemsLength;
  final IsInViewPortCondition? inViewPortCondition;
  final Widget? inViewArea;
  final List<String> initialInViewIds;
  final ScrollController? controller;

  const MyList({
    Key? key,
    this.itemsLength = 30,
    this.inViewPortCondition,
    this.inViewArea,
    this.initialInViewIds = const [],
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IsInViewPortCondition condition = inViewPortCondition ??
        (double deltaTop, double deltaBottom, double vpHeight) {
          return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
        };

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierList(
          controller: controller,
          initialInViewIds: initialInViewIds,
          isInViewPortCondition: condition,
          itemCount: itemsLength,
          builder: (BuildContext context, int index) {
            return Container(
              width: double.infinity,
              height: 300.0,
              color: Colors.blueGrey,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: Box(id: '$index'),
            );
          },
        ),
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: inViewArea ?? Container(),
          ),
        ),
      ],
    );
  }
}
