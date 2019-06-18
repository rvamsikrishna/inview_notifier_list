import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import '../example/lib/my_list.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
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

      final letRemain = 5;
      state.removeContexts(letRemain);

      expect(state.numberOfContextStored, 5);
    });
  });

  group('Test the InViewNotifierList widget', () {
    _buildInViewNotifier(
      WidgetTester tester, {
      IsInViewPortCondition condition,
      ScrollController controller,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: MyList(
            inViewPortCondition: condition,
            controller: controller,
          ),
        ),
      );
    }

    testWidgets(
        'Only one container is green when halfway condition is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      IsInViewPortCondition condition =
          (double deltaTop, double deltaBottom, double vpHeight) {
        return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
      };

      await binding.setSurfaceSize(Size(500, 800));

      await _buildInViewNotifier(tester,
          condition: condition, controller: controller);

      expect(ContianerByColorFinder(Colors.lightGreen), findsNothing);
      controller.jumpTo(600.0);
      await tester.pump(Duration(milliseconds: 2000));

      expect(ContianerByColorFinder(Colors.lightGreen), findsOneWidget);
    });

    testWidgets(
        'Two containera are green when condition with 200.0 height is provided',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      IsInViewPortCondition condition =
          (double deltaTop, double deltaBottom, double vpHeight) {
        return deltaTop < (0.5 * vpHeight) + 100.0 &&
            deltaBottom > (0.5 * vpHeight) - 100.0;
      };

      await binding.setSurfaceSize(Size(500, 800));

      await _buildInViewNotifier(tester,
          condition: condition, controller: controller);

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
      final Container contianerWidget = candidate.widget;
      if (contianerWidget.decoration is BoxDecoration) {
        final BoxDecoration decoration = contianerWidget.decoration;
        return decoration.color == color;
      }
      return false;
    }
    return false;
  }
}
