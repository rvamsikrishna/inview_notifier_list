import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class Box extends StatelessWidget {
  final String id;

  const Box({Key key, @required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    InViewState state = InViewNotifierList.of(context);
    state.addContext(context: context, id: id);

    return AnimatedBuilder(
      animation: state,
      builder: (BuildContext context, Widget child) {
        final bool isInView = state.inView(id);
        final String inViewTxt = isInView ? 'inView' : 'notInView';

        return Container(
          width: double.infinity,
          height: 250.0,
          alignment: Alignment.center,
          color: isInView ? Colors.lightGreen : Colors.amber,
          child: Text(
            '$id : $inViewTxt',
            key: ValueKey("item-$id"),
            style: Theme.of(context).textTheme.display1,
          ),
        );
      },
    );
  }
}
