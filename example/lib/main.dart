import 'package:flutter/material.dart';

import 'my_list.dart';
import 'video_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        color: Colors.grey.shade300,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Example 1'),
    Tab(text: 'Example 2'),
    Tab(text: 'Autoplay Video'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: Text('ÍnViewNotifierList'),
          centerTitle: true,
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            MyList(
              key: ValueKey("list1"),
              initialInViewIds: ['0'],
              inViewArea: Container(
                height: 1.0,
                color: Colors.redAccent,
              ),
            ),
            MyList(
              initialInViewIds: ['0'],
              inViewPortCondition:
                  (double deltaTop, double deltaBottom, double vpHeight) {
                return (deltaTop < (0.5 * vpHeight) + 100.0 &&
                    deltaBottom > (0.5 * vpHeight) - 100.0);
              },
              inViewArea: Container(
                height: 200.0,
                color: Colors.redAccent.withOpacity(0.2),
              ),
            ),
            VideoList(),
          ],
        ),
      ),
    );
  }
}
