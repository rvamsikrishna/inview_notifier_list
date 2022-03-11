import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshList extends StatefulWidget {
  const RefreshList({Key? key}) : super(key: key);

  @override
  State<RefreshList> createState() => _RefreshListState();
}

class _RefreshListState extends State<RefreshList> {
  final _refreshController = RefreshController(initialRefresh: true);

  final data = <int>[];

  int get nextInt => Random().nextInt(1000);

  @override
  void initState() {
    super.initState();
  }

  void onLoading() {
    Future.delayed(const Duration(milliseconds: 500), () {
      data.addAll(List.generate(10, (i) => nextInt));
      _refreshController.loadComplete();
      setState(() {});
    });
  }

  void onRefresh() {
    Future.delayed(const Duration(milliseconds: 500), () {
      data.clear();
      data.addAll(List.generate(10, (_) => nextInt));
      _refreshController.refreshCompleted();
      setState(() {});
    });
  }

  bool _conditaion(double deltaTop, double deltaBottom, double vpHeight) {
    // return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
    return (deltaTop < (0.5 * vpHeight) + 100.0 &&
        deltaBottom > (0.5 * vpHeight) - 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InViewNotifier(
          isInViewPortCondition: _conditaion,
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onLoading: onLoading,
            onRefresh: onRefresh,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final item = data[i];
                return InViewNotifierWidget(
                  id: '$i',
                  builder: (_, inView, child) {
                    if (!inView) {
                      return child!;
                    }
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: child,
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$item',
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    height: 100,
                    color: i.isOdd ? Colors.green : Colors.blue,
                  ),
                );
              },
            ),
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.red.withOpacity(0.2),
              height: 200,
            ),
          ),
        ),
      ],
    );
  }
}
