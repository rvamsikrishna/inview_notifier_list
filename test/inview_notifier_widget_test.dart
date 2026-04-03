import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InViewNotifierWidget lifecycle', () {
    testWidgets('registers context on initState and receives in-view updates',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            isInViewPortCondition: _halfwayCondition,
            initialInViewIds: const ['0'],
            itemCount: 10,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (context, isInView, child) {
                  return Container(
                    key: ValueKey('box-$index'),
                    height: 300,
                    color: isInView ? Colors.green : Colors.red,
                  );
                },
              );
            },
          ),
        ),
      );

      // Item '0' should be in-view via initialInViewIds
      final box0 =
          tester.widget<Container>(find.byKey(const ValueKey('box-0')));
      expect(box0.color, Colors.green);
    });

    testWidgets('didUpdateWidget re-registers when id changes',
        (WidgetTester tester) async {
      final controller = ScrollController();
      String currentId = 'id-A';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return InViewNotifierList(
                controller: controller,
                isInViewPortCondition: _halfwayCondition,
                initialInViewIds: const ['id-A'],
                itemCount: 5,
                builder: (context, index) {
                  if (index == 0) {
                    return InViewNotifierWidget(
                      id: currentId,
                      builder: (context, isInView, child) {
                        return GestureDetector(
                          key: const ValueKey('target'),
                          onTap: () => setState(() => currentId = 'id-B'),
                          child: Container(
                            height: 300,
                            color: isInView ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    );
                  }
                  return SizedBox(
                    height: 300,
                    child: InViewNotifierWidget(
                      id: 'other-$index',
                      builder: (context, isInView, child) {
                        return Container(height: 300);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      // Initially 'id-A' is in view
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('target')),
          matching: find.byType(Container),
        ),
      );
      expect(box.color, Colors.green);

      // Trigger id change from 'id-A' to 'id-B'
      await tester.tap(find.byKey(const ValueKey('target')));
      await tester.pump(const Duration(milliseconds: 300));

      // 'id-B' is not in initialInViewIds, and no scroll happened,
      // so it should not be in-view until a scroll triggers detection
      final updatedBox = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('target')),
          matching: find.byType(Container),
        ),
      );
      expect(updatedBox.color, Colors.red);
    });

    testWidgets('dispose removes context without crashing',
        (WidgetTester tester) async {
      final controller = ScrollController();
      bool showWidget = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    key: const ValueKey('toggle'),
                    onPressed: () => setState(() => showWidget = false),
                    child: const Text('Toggle'),
                  ),
                  Expanded(
                    child: InViewNotifierList(
                      controller: controller,
                      isInViewPortCondition: _halfwayCondition,
                      initialInViewIds: const ['0'],
                      itemCount: showWidget ? 5 : 0,
                      builder: (context, index) {
                        return InViewNotifierWidget(
                          id: '$index',
                          builder: (context, isInView, child) {
                            return Container(height: 200);
                          },
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

      // Remove all items — triggers dispose on InViewNotifierWidgets
      await tester.tap(find.byKey(const ValueKey('toggle')));
      await tester.pump();

      // If dispose didn't properly clean up, scrolling would crash
      // on stale contexts. Just verify no exception.
      expect(tester.takeException(), isNull);
    });

    testWidgets('child parameter is passed through to builder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            isInViewPortCondition: _halfwayCondition,
            initialInViewIds: const ['0'],
            itemCount: 1,
            builder: (context, index) {
              return InViewNotifierWidget(
                id: '$index',
                child: const Text('pre-built child'),
                builder: (context, isInView, child) {
                  return Column(
                    key: const ValueKey('column'),
                    children: [
                      if (child != null) child,
                      Text(isInView ? 'in' : 'out'),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );

      // The pre-built child should be present in the tree
      expect(find.text('pre-built child'), findsOneWidget);
      expect(find.text('in'), findsOneWidget);
    });
  });

  group('InViewNotifierWidget with scrolling', () {
    testWidgets('widget transitions from not-in-view to in-view on scroll',
        (WidgetTester tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: _halfwayCondition,
            itemCount: 20,
            builder: (context, index) {
              return Container(
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    return Container(
                      key: ValueKey('item-$index'),
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

      // Initially no items should be green (none at halfway point)
      expect(_greenContainerFinder(), findsNothing);

      // Scroll to bring an item to the halfway point
      controller.jumpTo(600.0);
      await tester.pump(const Duration(milliseconds: 300));

      expect(_greenContainerFinder(), findsOneWidget);
    });

    testWidgets('widget transitions from in-view back to not-in-view',
        (WidgetTester tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: InViewNotifierList(
            controller: controller,
            isInViewPortCondition: _halfwayCondition,
            initialInViewIds: const ['0'],
            itemCount: 20,
            builder: (context, index) {
              return Container(
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: InViewNotifierWidget(
                  id: '$index',
                  builder: (context, isInView, child) {
                    return Container(
                      key: ValueKey('item-$index'),
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

      // Item '0' starts as in-view
      final initial =
          tester.widget<Container>(find.byKey(const ValueKey('item-0')));
      expect(initial.color, Colors.green);

      // Scroll far away — item '0' should leave viewport
      controller.jumpTo(3000.0);
      await tester.pump(const Duration(milliseconds: 300));

      // Item '0' is no longer visible at all (scrolled off)
      expect(find.byKey(const ValueKey('item-0')), findsNothing);
    });
  });
}

bool _halfwayCondition(double deltaTop, double deltaBottom, double vpHeight) {
  return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
}

Finder _greenContainerFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is Container && widget.color == Colors.green,
  );
}
