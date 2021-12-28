import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

import 'box.dart';

class CSVExample extends StatelessWidget {
  final ScrollController? scrollController;
  final IsInViewPortCondition? inViewPortCondition;

  const CSVExample({Key? key, this.scrollController, this.inViewPortCondition})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final IsInViewPortCondition condition = inViewPortCondition ??
        (double deltaTop, double deltaBottom, double vpHeight) {
          return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
        };

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierCustomScrollView(
          initialInViewIds: ['grid3', 'grid4', 'grid5'],
          isInViewPortCondition: condition,
          controller: scrollController,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Box(
                      id: 'grid$index',
                      height: 200.0,
                    );
                  },
                  childCount: 20,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      width: double.infinity,
                      height: 300.0,
                      color: Colors.blueGrey,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 50.0),
                      child: Box(id: 'list$index'),
                    );
                  },
                  childCount: 3,
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Box(
                    id: '2nd-grid$index',
                    height: 200.0,
                  );
                },
                childCount: 10,
              ),
            ),
          ],
        ),
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              // height: 200.0,
              // color: Colors.redAccent.withOpacity(0.2),
              height: 1.0,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }
}
