import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

enum RefreshType { flutterBuiltIn, easyRefresh }

class RefreshList extends StatefulWidget {
  const RefreshList({super.key});

  @override
  State<RefreshList> createState() => _RefreshListState();
}

class _RefreshListState extends State<RefreshList> {
  RefreshType _selected = RefreshType.flutterBuiltIn;
  int _itemCount = 15;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() => _itemCount = 15);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SegmentedButton<RefreshType>(
            segments: const [
              ButtonSegment(
                value: RefreshType.flutterBuiltIn,
                label: Text('RefreshIndicator'),
              ),
              ButtonSegment(
                value: RefreshType.easyRefresh,
                label: Text('EasyRefresh'),
              ),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) {
              setState(() => _selected = selection.first);
            },
          ),
        ),
        Expanded(
          child: _selected == RefreshType.flutterBuiltIn
              ? _buildWithRefreshIndicator()
              : _buildWithEasyRefresh(),
        ),
      ],
    );
  }

  Widget _buildWithRefreshIndicator() {
    return Stack(
      fit: StackFit.expand,
      children: [
        InViewNotifierList(
          initialInViewIds: const ['0'],
          isInViewPortCondition: _isInViewCondition,
          scrollViewWrapper: (scrollView) => RefreshIndicator(
            onRefresh: _onRefresh,
            child: scrollView,
          ),
          itemCount: _itemCount,
          builder: _itemBuilder,
        ),
        _inViewAreaOverlay(),
      ],
    );
  }

  Widget _buildWithEasyRefresh() {
    return Stack(
      fit: StackFit.expand,
      children: [
        InViewNotifierList(
          initialInViewIds: const ['0'],
          isInViewPortCondition: _isInViewCondition,
          scrollViewWrapper: (scrollView) => EasyRefresh(
            onRefresh: () async => _onRefresh(),
            child: scrollView,
          ),
          itemCount: _itemCount,
          builder: _itemBuilder,
        ),
        _inViewAreaOverlay(),
      ],
    );
  }

  bool _isInViewCondition(
      double deltaTop, double deltaBottom, double vpHeight) {
    return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Container(
      width: double.infinity,
      height: 300.0,
      color: Colors.blueGrey,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 50.0),
      child: InViewNotifierWidget(
        id: '$index',
        builder: (BuildContext context, bool isInView, Widget? child) {
          return Container(
            width: double.infinity,
            height: 250.0,
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
  }

  Widget _inViewAreaOverlay() {
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 1.0,
          child: const ColoredBox(color: Colors.redAccent),
        ),
      ),
    );
  }
}
