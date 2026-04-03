import 'package:example/csv_example.dart';
import 'package:flutter/material.dart';

import 'my_list.dart';
import 'video_list.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        color: Colors.grey.shade300,
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Tab> myTabs = const <Tab>[
    Tab(text: 'Example 1'),
    Tab(text: 'Example 2'),
    Tab(text: 'Autoplay Video'),
    Tab(text: 'Custom Scroll View'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: const Text('InViewNotifierList'),
          centerTitle: true,
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            const MyList(
              key: ValueKey("list1"),
              initialInViewIds: ['0'],
              inViewArea: SizedBox(
                height: 1.0,
                child: ColoredBox(color: Colors.redAccent),
              ),
            ),
            MyList(
              initialInViewIds: const ['0'],
              inViewPortCondition:
                  (double deltaTop, double deltaBottom, double vpHeight) {
                return (deltaTop < (0.5 * vpHeight) + 100.0 &&
                    deltaBottom > (0.5 * vpHeight) - 100.0);
              },
              inViewArea: Container(
                height: 200.0,
                color: Colors.redAccent.withValues(alpha: 0.2),
              ),
            ),
            const VideoList(),
            CSVExample(),
          ],
        ),
      ),
    );
  }
}
