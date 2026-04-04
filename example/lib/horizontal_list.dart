import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierList(
          scrollDirection: Axis.horizontal,
          initialInViewIds: const ['0'],
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double vpWidth) {
            return deltaTop < (0.5 * vpWidth) && deltaBottom > (0.5 * vpWidth);
          },
          itemCount: 20,
          builder: (BuildContext context, int index) {
            return Container(
              width: 300.0,
              color: Colors.blueGrey,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget? child) {
                  return Container(
                    width: 300.0,
                    alignment: Alignment.center,
                    color: isInView ? Colors.lightGreen : Colors.amber,
                    child: Text(
                      '$index : ${isInView ? 'inView' : 'notInView'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                },
              ),
            );
          },
        ),
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 1.0,
              height: double.infinity,
              child: const ColoredBox(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
