import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

bool halfwayCondition(double deltaTop, double deltaBottom, double vpHeight) {
  return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
}

bool expandedCondition(double deltaTop, double deltaBottom, double vpHeight) {
  return deltaTop < (0.5 * vpHeight) + 100.0 &&
      deltaBottom > (0.5 * vpHeight) - 100.0;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('InViewNotifierList - core behavior', () {
    buildInViewNotifier(
      WidgetTester tester, {
      IsInViewPortCondition? condition,
      ScrollController? controller,
      bool isCustomScrollView = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: !isCustomScrollView
              ? TestMyList(
                  inViewPortCondition: condition!,
                  controller: controller!,
                )
              : TestCSVExample(
                  scrollController: controller!,
                  inViewPortCondition: condition!,
                ),
        ),
      );
    }

    testWidgets(
        'Only one container is green when halfway condition is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      await binding.setSurfaceSize(const Size(500, 800));

      await buildInViewNotifier(tester,
          condition: halfwayCondition, controller: controller);

      expect(ContainerByColorFinder(Colors.lightGreen), findsNothing);
      controller.jumpTo(600.0);
      await tester.pump(const Duration(milliseconds: 2000));

      expect(ContainerByColorFinder(Colors.lightGreen), findsOneWidget);
    });

    testWidgets(
        'Only 3 in grid containers are green when halfway condition is provided for CustomScrollView',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      await binding.setSurfaceSize(const Size(500, 800));

      await buildInViewNotifier(
        tester,
        condition: halfwayCondition,
        controller: controller,
        isCustomScrollView: true,
      );

      expect(ContainerByColorFinder(Colors.lightGreen), findsNWidgets(3));
      controller.jumpTo(300.0);
      await tester.pump(const Duration(milliseconds: 2000));

      expect(ContainerByColorFinder(Colors.lightGreen), findsNWidgets(3));

      //jump to a sliver listview. Now only 1 item is inview.
      controller.jumpTo(1200.0);
      await tester.pump(const Duration(milliseconds: 2000));

      expect(ContainerByColorFinder(Colors.lightGreen), findsNWidgets(1));
    });

    testWidgets(
        'Two containers are green when condition with 200.0 height is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      await binding.setSurfaceSize(const Size(500, 800));

      await buildInViewNotifier(tester,
          condition: expandedCondition, controller: controller);

      expect(ContainerByColorFinder(Colors.lightGreen), findsNothing);
      controller.jumpTo(380.0);
      await tester.pump(const Duration(milliseconds: 2000));

      expect(ContainerByColorFinder(Colors.lightGreen), findsNWidgets(2));
    });
  });

  group('InViewNotifierList - initialInViewIds', () {
    testWidgets('marks specified ids as in-view on first build',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            initialInViewIds: const ['0', '1'],
            isInViewPortCondition: halfwayCondition,
            itemCount: 5,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(
                    key: ValueKey('item-$index'),
                    height: 300,
                    color: isInView ? Colors.green : Colors.red,
                  );
                },
              );
            },
          ),
        ),
      );

      final item0 =
          tester.widget<Container>(find.byKey(const ValueKey('item-0')));
      final item1 =
          tester.widget<Container>(find.byKey(const ValueKey('item-1')));
      expect(item0.color, Colors.green);
      expect(item1.color, Colors.green);
    });

    testWidgets('items not in initialInViewIds start as not-in-view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            initialInViewIds: const ['0'],
            isInViewPortCondition: halfwayCondition,
            itemCount: 5,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(
                    key: ValueKey('item-$index'),
                    height: 300,
                    color: isInView ? Colors.green : Colors.red,
                  );
                },
              );
            },
          ),
        ),
      );

      final item1 =
          tester.widget<Container>(find.byKey(const ValueKey('item-1')));
      final item2 =
          tester.widget<Container>(find.byKey(const ValueKey('item-2')));
      expect(item1.color, Colors.red);
      expect(item2.color, Colors.red);
    });
  });

  group('InViewNotifierList - onListEndReached', () {
    testWidgets('fires callback when scrolled to the end',
        (WidgetTester tester) async {
      final controller = ScrollController();
      int endReachedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: halfwayCondition,
            onListEndReached: () => endReachedCount++,
            itemCount: 10,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(height: 300);
                },
              );
            },
          ),
        ),
      );

      expect(endReachedCount, 0);

      // Scroll to the very end
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump(const Duration(milliseconds: 300));

      expect(endReachedCount, greaterThan(0));
    });

    testWidgets('fires callback when within endNotificationOffset',
        (WidgetTester tester) async {
      final controller = ScrollController();
      int endReachedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: halfwayCondition,
            endNotificationOffset: 200.0,
            onListEndReached: () => endReachedCount++,
            itemCount: 20,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(height: 300);
                },
              );
            },
          ),
        ),
      );

      expect(endReachedCount, 0);

      // Scroll to near the end (within 200px offset)
      final nearEnd = controller.position.maxScrollExtent - 100.0;
      controller.jumpTo(nearEnd);
      await tester.pump(const Duration(milliseconds: 300));

      expect(endReachedCount, greaterThan(0));
    });

    testWidgets('does not fire when not scrolled to end',
        (WidgetTester tester) async {
      final controller = ScrollController();
      int endReachedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: halfwayCondition,
            onListEndReached: () => endReachedCount++,
            itemCount: 50,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(height: 300);
                },
              );
            },
          ),
        ),
      );

      // Scroll just a little — not near end
      controller.jumpTo(100.0);
      await tester.pump(const Duration(milliseconds: 300));

      expect(endReachedCount, 0);
    });
  });

  group('InViewNotifierList - edge cases', () {
    testWidgets('handles empty list (0 items) without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            isInViewPortCondition: halfwayCondition,
            itemCount: 0,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(height: 300);
                },
              );
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles single item list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            isInViewPortCondition: halfwayCondition,
            initialInViewIds: const ['only'],
            itemCount: 1,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: 'only',
                builder: (context, isInView, child) {
                  return Container(
                    key: const ValueKey('single'),
                    height: 300,
                    color: isInView ? Colors.green : Colors.red,
                  );
                },
              );
            },
          ),
        ),
      );

      final item =
          tester.widget<Container>(find.byKey(const ValueKey('single')));
      expect(item.color, Colors.green);
    });

    testWidgets('works with reverse: true', (WidgetTester tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            reverse: true,
            isInViewPortCondition: halfwayCondition,
            itemCount: 20,
            builder: (context, index) {
              return Container(
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    return Container(
                      key: ValueKey('rev-$index'),
                      height: 300,
                      color: isInView ? Colors.green : Colors.red,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Should build without errors
      expect(tester.takeException(), isNull);

      // Scroll and verify detection still works
      controller.jumpTo(600.0);
      await tester.pump(const Duration(milliseconds: 300));

      // At least one item should be detected as in-view
      expect(
        find.byWidgetPredicate(
            (w) => w is Container && w.color == Colors.green),
        findsWidgets,
      );
    });

    testWidgets('works with shrinkWrap: true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                InViewNotifierList(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  isInViewPortCondition: halfwayCondition,
                  initialInViewIds: const ['0'],
                  itemCount: 3,
                  builder: (context, index) {
                    return InViewNotifierWidget(
                      id: '$index',
                      builder: (context, isInView, child) {
                        return Container(
                          key: ValueKey('shrink-$index'),
                          height: 200,
                          color: isInView ? Colors.green : Colors.red,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Should build without errors in shrinkWrap mode
      expect(tester.takeException(), isNull);
      final item =
          tester.widget<Container>(find.byKey(const ValueKey('shrink-0')));
      expect(item.color, Colors.green);
    });

    testWidgets('works with horizontal scroll direction',
        (WidgetTester tester) async {
      final controller = ScrollController();
      await binding.setSurfaceSize(const Size(800, 500));

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 500,
            child: InViewNotifierList(
              controller: controller,
              scrollDirection: Axis.horizontal,
              isInViewPortCondition:
                  (double deltaTop, double deltaBottom, double vpWidth) {
                return deltaTop < (0.5 * vpWidth) &&
                    deltaBottom > (0.5 * vpWidth);
              },
              itemCount: 20,
              builder: (context, index) {
                return InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    return Container(
                      key: ValueKey('h-$index'),
                      width: 300,
                      height: 500,
                      color: isInView ? Colors.green : Colors.red,
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // Each item is 300px wide. Viewport is 800px, midpoint at 400px.
      // At offset 500: item 1 spans [−200, 100], item 2 spans [100, 400],
      // item 3 spans [400, 700] — only item 2 straddles the midpoint
      // (deltaTop=100 < 400, deltaBottom=400 is NOT > 400).
      // So we need an offset where exactly one item straddles the midpoint.
      // At offset 450: item 2 spans [150, 450] — deltaTop=150 < 400, deltaBottom=450 > 400. In-view.
      //                item 1 spans [−150, 150] — deltaBottom=150, NOT > 400.
      //                item 3 spans [450, 750] — deltaTop=450, NOT < 400.
      controller.jumpTo(450.0);
      await tester.pump(const Duration(milliseconds: 300));

      // Exactly one item should be detected as in-view
      final item2 = tester.widget<Container>(find.byKey(const ValueKey('h-2')));
      expect(item2.color, Colors.green);

      // Neighboring items should NOT be in-view
      final item1 = tester.widget<Container>(find.byKey(const ValueKey('h-1')));
      final item3 = tester.widget<Container>(find.byKey(const ValueKey('h-3')));
      expect(item1.color, Colors.red);
      expect(item3.color, Colors.red);
    });
  });

  group('InViewNotifierList - scrollViewWrapper', () {
    testWidgets('in-view detection works through a wrapper widget',
        (WidgetTester tester) async {
      final controller = ScrollController();
      await binding.setSurfaceSize(const Size(500, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: halfwayCondition,
            scrollViewWrapper: (scrollView) {
              // Simulates a refresh widget wrapping the scroll view.
              return ColoredBox(
                color: Colors.transparent,
                child: scrollView,
              );
            },
            itemCount: 30,
            builder: (context, index) {
              return Container(
                width: double.infinity,
                height: 300.0,
                color: Colors.blueGrey,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 50.0),
                child: InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    return Container(
                      key: ValueKey('w-$index'),
                      height: 250.0,
                      color: isInView ? Colors.green : Colors.red,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Scroll so that an item crosses the midpoint
      controller.jumpTo(600.0);
      await tester.pump(const Duration(milliseconds: 300));

      // Detection should work despite the wrapper between
      // NotificationListener and the ListView
      expect(
        find.byWidgetPredicate(
            (w) => w is Container && w.color == Colors.green),
        findsOneWidget,
      );
    });
  });

  group('InViewNotifierCustomScrollView', () {
    testWidgets('handles empty slivers list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierCustomScrollView(
            isInViewPortCondition: halfwayCondition,
            slivers: const [],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('InViewNotifier - throttleDuration', () {
    testWidgets(
        'rebuilds stream when throttleDuration changes and scroll still works',
        (WidgetTester tester) async {
      Duration duration = const Duration(milliseconds: 200);
      final controller = ScrollController();
      await binding.setSurfaceSize(const Size(500, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    key: const ValueKey('change-throttle'),
                    onPressed: () => setState(
                        () => duration = const Duration(milliseconds: 500)),
                    child: const Text('Change'),
                  ),
                  Expanded(
                    child: InViewNotifierList(
                      controller: controller,
                      throttleDuration: duration,
                      isInViewPortCondition: halfwayCondition,
                      itemCount: 20,
                      builder: (context, index) {
                        return Container(
                          height: 300,
                          margin: const EdgeInsets.symmetric(vertical: 50),
                          child: InViewNotifierWidget(
                            id: '$index',
                            builder: (context, isInView, child) {
                              return Container(
                                key: ValueKey('t-$index'),
                                height: 300,
                                color: isInView ? Colors.green : Colors.red,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Change throttleDuration — triggers didUpdateWidget
      await tester.tap(find.byKey(const ValueKey('change-throttle')));
      await tester.pump();

      // Scroll after throttle change — detection must still work
      controller.jumpTo(600.0);
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.byWidgetPredicate(
            (w) => w is Container && w.color == Colors.green),
        findsWidgets,
      );
    });
  });

  group('InViewNotifier - notifyListeners dedup', () {
    testWidgets(
        'does not fire redundant notifications when state has not changed',
        (WidgetTester tester) async {
      final controller = ScrollController();
      int buildCount = 0;
      await binding.setSurfaceSize(const Size(500, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            initialInViewIds: const ['0'],
            isInViewPortCondition: halfwayCondition,
            itemCount: 10,
            builder: (context, index) {
              return Container(
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    if (index == 0) buildCount++;
                    return Container(
                      height: 300,
                      color: isInView ? Colors.green : Colors.red,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Scroll to the same position twice — item '0' stays in view both times
      // notifyListeners should NOT fire again since state didn't change
      controller.jumpTo(1.0);
      await tester.pump(const Duration(milliseconds: 300));
      controller.jumpTo(2.0);
      await tester.pump(const Duration(milliseconds: 300));

      // Build count should not have increased significantly
      // (at most 1 extra from the state change, not 2+ from redundant notifies)
      expect(buildCount - initialBuildCount, lessThanOrEqualTo(1));
    });
  });
}

// ---------------------------------------------------------------------------
// Test helper widgets (inlined from example app to avoid cross-dependency)
// ---------------------------------------------------------------------------

class TestMyList extends StatelessWidget {
  final int itemsLength;
  final IsInViewPortCondition inViewPortCondition;
  final ScrollController controller;

  const TestMyList({
    super.key,
    this.itemsLength = 30,
    required this.inViewPortCondition,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InViewNotifierList(
      controller: controller,
      isInViewPortCondition: inViewPortCondition,
      itemCount: itemsLength,
      builder: (BuildContext context, int index) {
        return Container(
          width: double.infinity,
          height: 300.0,
          color: Colors.blueGrey,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 50.0),
          child: TestBox(id: '$index'),
        );
      },
    );
  }
}

class TestCSVExample extends StatelessWidget {
  final ScrollController scrollController;
  final IsInViewPortCondition inViewPortCondition;

  const TestCSVExample({
    super.key,
    required this.scrollController,
    required this.inViewPortCondition,
  });

  @override
  Widget build(BuildContext context) {
    return InViewNotifierCustomScrollView(
      initialInViewIds: const ['grid3', 'grid4', 'grid5'],
      isInViewPortCondition: inViewPortCondition,
      controller: scrollController,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return TestBox(id: 'grid$index', height: 200.0);
              },
              childCount: 20,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  width: double.infinity,
                  height: 300.0,
                  color: Colors.blueGrey,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 50.0),
                  child: TestBox(id: 'list$index'),
                );
              },
              childCount: 3,
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return TestBox(id: '2nd-grid$index', height: 200.0);
            },
            childCount: 10,
          ),
        ),
      ],
    );
  }
}

class TestBox extends StatelessWidget {
  final String id;
  final double height;
  const TestBox({super.key, required this.id, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    return InViewNotifierWidget(
      id: id,
      builder: (BuildContext context, bool isInView, Widget? child) {
        return Container(
          width: double.infinity,
          height: height,
          alignment: Alignment.center,
          color: isInView ? Colors.lightGreen : Colors.amber,
          child: Text(
            '$id : ${isInView ? 'inView' : 'notInView'}',
            key: ValueKey("item-$id"),
          ),
        );
      },
    );
  }
}

class ContainerByColorFinder extends MatchFinder {
  final Color color;

  ContainerByColorFinder(this.color, {super.skipOffstage});

  @override
  String get description => 'Container{color: "$color"}';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Container) {
      final Container containerWidget = candidate.widget as Container;
      if (containerWidget.decoration is BoxDecoration) {
        final BoxDecoration decoration =
            containerWidget.decoration as BoxDecoration;
        return decoration.color == color;
      } else {
        return containerWidget.color == color;
      }
    }
    return false;
  }
}
