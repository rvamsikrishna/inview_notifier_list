import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class Box extends StatelessWidget {
  final String id;
  final double height;
  const Box({
    Key? key,
    required this.id,
    this.height = 250.0,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InViewNotifierWidget(
      id: id,
      builder: (BuildContext context, bool isInView, Widget? child) {
        final String inViewTxt = isInView ? 'inView' : 'notInView';

        return Container(
          width: double.infinity,
          height: height,
          alignment: Alignment.center,
          color: isInView ? Colors.lightGreen : Colors.amber,
          child: Text(
            '$id : $inViewTxt',
            key: ValueKey("item-$id"),
            style: Theme.of(context).textTheme.headline4,
          ),
        );
      },
    );
  }
}
