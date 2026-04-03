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
  group('test the inViewState', () {
    test('only n number of contexts are stored', () {
      final InViewState state = InViewState(
        intialIds: [],
        isInViewCondition: (doublex, double y, double z) => true,
      );

      state.addContext(context: null, id: '0');

      expect(state.numberOfContextStored, 1);

      for (var i = 1; i <= 10; i++) {
        state.addContext(context: null, id: '$i');
      }

      expect(state.numberOfContextStored, 11);

      const letRemain = 5;
      state.removeContexts(letRemain);

      expect(state.numberOfContextStored, 5);
    });
  });

  group('Test the InViewNotifierList widget', () {
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
