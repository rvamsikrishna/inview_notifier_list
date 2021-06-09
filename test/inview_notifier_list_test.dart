import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import '../example/lib/my_list.dart';
import '../example/lib/csv_example.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
  group('test the inViewState', () {
    test('only n number of contexts are stored', () {
      final InViewState state = InViewState(
        intialIds: [],
        isInViewCondition: (doublex, double y, double z) => true,
        scrollDirection: Axis.vertical,
      );

      state.addContext(context: null, id: '0');

      expect(state.numberOfContextStored, 1);

      for (var i = 1; i <= 10; i++) {
        state.addContext(context: null, id: '$i');
      }

      expect(state.numberOfContextStored, 11);

      final letRemain = 5;
      state.removeContexts(letRemain);

      expect(state.numberOfContextStored, 5);
    });
  });

  group('Test the InViewNotifierList widget', () {
    _buildInViewNotifier(
      WidgetTester tester, {
      IsInViewPortCondition? condition,
      ScrollController? controller,
      bool isCustomScrollView = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: !isCustomScrollView
              ? MyList(
                  inViewPortCondition: condition!,
                  controller: controller!,
                )
              : CSVExample(
                  scrollController: controller!,
                  inViewPortCondition: condition!,
                ),
        ),
      );
    }

    testWidgets('Only one container is green when halfway condition is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      IsInViewPortCondition condition = (double deltaTop, double deltaBottom, double vpHeight) {
        return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
      };

      await binding.setSurfaceSize(Size(500, 800));

      await _buildInViewNotifier(tester, condition: condition, controller: controller);

      expect(ContianerByColorFinder(Colors.lightGreen), findsNothing);
      controller.jumpTo(600.0);
      await tester.pump(Duration(milliseconds: 2000));

      expect(ContianerByColorFinder(Colors.lightGreen), findsOneWidget);
    });

    testWidgets(
        'Only 3 in grid containers are green when halfway condition is provided for CustomScrollView',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      IsInViewPortCondition condition = (double deltaTop, double deltaBottom, double vpHeight) {
        return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
      };

      await binding.setSurfaceSize(Size(500, 800));

      await _buildInViewNotifier(
        tester,
        condition: condition,
        controller: controller,
        isCustomScrollView: true,
      );

      expect(ContianerByColorFinder(Colors.lightGreen), findsNWidgets(3));
      controller.jumpTo(300.0);
      await tester.pump(Duration(milliseconds: 2000));

      expect(ContianerByColorFinder(Colors.lightGreen), findsNWidgets(3));

      //jump to a sliver listview. Now only 1 item is inview.
      controller.jumpTo(1200.0);
      await tester.pump(Duration(milliseconds: 2000));

      expect(ContianerByColorFinder(Colors.lightGreen), findsNWidgets(1));
    });

    testWidgets('Two containera are green when condition with 200.0 height is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      IsInViewPortCondition condition = (double deltaTop, double deltaBottom, double vpHeight) {
        return deltaTop < (0.5 * vpHeight) + 100.0 && deltaBottom > (0.5 * vpHeight) - 100.0;
      };

      await binding.setSurfaceSize(Size(500, 800));

      await _buildInViewNotifier(tester, condition: condition, controller: controller);

      expect(ContianerByColorFinder(Colors.lightGreen), findsNothing);
      controller.jumpTo(380.0);
      await tester.pump(Duration(milliseconds: 2000));

      expect(ContianerByColorFinder(Colors.lightGreen), findsNWidgets(2));
    });
  });
}

class ContianerByColorFinder extends MatchFinder {
  final Color color;

  ContianerByColorFinder(this.color, {bool skipOffstage = true})
      : super(skipOffstage: skipOffstage);

  @override
  String get description => 'Container{color: "$color"}';

  @override
  bool matches(Element candidate) {
    if (candidate.widget is Container) {
      final Container contianerWidget = candidate.widget as Container;
      if (contianerWidget.decoration is BoxDecoration) {
        final BoxDecoration decoration = contianerWidget.decoration as BoxDecoration;
        return decoration.color == color;
      }
      return false;
    }
    return false;
  }
}
