import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

import 'video_widget.dart';

class VideoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierList(
          srollDirection: Axis.vertical,
          initialInViewIds: ['0'],
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double viewPortDimension) {
            return deltaTop < (0.5 * viewPortDimension) &&
                deltaBottom > (0.5 * viewPortDimension);
          },
          children: List.generate(
            10,
            (index) {
              return Container(
                width: double.infinity,
                height: 300.0,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 50.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final InViewState inViewState =
                        InViewNotifierList.of(context);

                    inViewState.addContext(context: context, id: '$index');

                    return AnimatedBuilder(
                      animation: inViewState,
                      builder: (BuildContext context, Widget child) {
                        return VideoWidget(
                            play: inViewState.inView('$index'),
                            url:
                                'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4');
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 1.0,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
