import 'package:flutter_test/flutter_test.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

void main() {
  group('InViewState', () {
    group('constructor and initialInViewIds', () {
      test('initializes with provided ids marked as in-view', () {
        final state = InViewState(
          intialIds: ['a', 'b', 'c'],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inView('a'), isTrue);
        expect(state.inView('b'), isTrue);
        expect(state.inView('c'), isTrue);
        expect(state.inView('d'), isFalse);
        expect(state.inViewWidgetIdsLength, 3);
      });
    });

    group('addContext', () {
      test('adds a new context', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        state.addContext(context: null, id: 'item-0');
        expect(state.numberOfContextStored, 1);
      });

      test('replaces context when same id is added again (dedup)', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        state.addContext(context: null, id: 'item-0');
        state.addContext(context: null, id: 'item-0');

        // Should still be 1, not 2 — dedup by id
        expect(state.numberOfContextStored, 1);
      });
    });

    group('removeContexts', () {
      test('trims contexts to the specified remaining count', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        for (var i = 0; i < 10; i++) {
          state.addContext(context: null, id: '$i');
        }

        expect(state.numberOfContextStored, 10);

        state.removeContexts(3);
        expect(state.numberOfContextStored, 3);
      });

      test('does nothing when letRemain >= current count', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        for (var i = 0; i < 5; i++) {
          state.addContext(context: null, id: '$i');
        }

        state.removeContexts(5);
        expect(state.numberOfContextStored, 5);

        state.removeContexts(10);
        expect(state.numberOfContextStored, 5);
      });
    });
  });
}
