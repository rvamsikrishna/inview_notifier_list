import 'package:flutter/foundation.dart';
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
      });

      test('initializes with empty ids when none provided', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inView('anything'), isFalse);
        expect(state.inViewWidgetIdsLength, 0);
      });

      test('inViewWidgetIdsLength reflects initial ids count', () {
        final state = InViewState(
          intialIds: ['x', 'y'],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inViewWidgetIdsLength, 2);
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

      test('replaces context when same id is added again', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        state.addContext(context: null, id: 'item-0');
        state.addContext(context: null, id: 'item-0');

        // Should still be 1, not 2 — dedup by id
        expect(state.numberOfContextStored, 1);
      });

      test('stores multiple contexts with different ids', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        for (var i = 0; i < 5; i++) {
          state.addContext(context: null, id: 'item-$i');
        }

        expect(state.numberOfContextStored, 5);
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

      test('keeps the most recent contexts (skips from start)', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        // Add in order: 0, 1, 2, 3, 4
        for (var i = 0; i < 5; i++) {
          state.addContext(context: null, id: '$i');
        }

        // Keep last 2 — should keep items with id '3' and '4'
        state.removeContexts(2);
        expect(state.numberOfContextStored, 2);
      });
    });

    group('inView', () {
      test('returns true for ids in the current in-view list', () {
        final state = InViewState(
          intialIds: ['visible'],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inView('visible'), isTrue);
      });

      test('returns false for ids not in the current in-view list', () {
        final state = InViewState(
          intialIds: ['visible'],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inView('hidden'), isFalse);
      });

      test('returns false after id is removed from in-view list', () {
        final state = InViewState(
          intialIds: ['a', 'b'],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(state.inView('a'), isTrue);
        expect(state.inView('b'), isTrue);
        expect(state.inViewWidgetIdsLength, 2);
      });
    });

    group('ChangeNotifier contract', () {
      test('can add and remove listeners without error', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        int callCount = 0;
        void listener() => callCount++;

        state.addListener(listener);
        state.removeListener(listener);

        // After removing, the listener should not be called
        expect(callCount, 0);
      });

      test('dispose does not throw', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        expect(() => state.dispose(), returnsNormally);
      });

      test('adding listener after dispose throws', () {
        final state = InViewState(
          intialIds: [],
          isInViewCondition: (dt, db, vp) => true,
        );

        state.dispose();

        expect(
          () => state.addListener(() {}),
          throwsA(isA<FlutterError>()),
        );
      });
    });
  });
}
