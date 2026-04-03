# CLAUDE.md — Project Guide for Claude Code

## What This Package Does

`inview_notifier_list` is a Flutter package that builds a `ListView` or `CustomScrollView` and notifies when child widgets enter or leave a defined viewport area. Used for auto-playing videos on scroll, lazy-loading content, triggering animations, etc.

**pub.dev:** https://pub.dev/packages/inview_notifier_list
**496+ likes, 6.7k weekly downloads.**

## Architecture

The package is intentionally small — 5 source files, ~400 lines of Dart:

```
lib/src/
├── inview_notifier.dart          # Base StatefulWidget — scroll listener, throttled stream, viewport detection
├── inview_notifier_list.dart     # InViewNotifierList (ListView), InViewNotifierCustomScrollView, InViewNotifierWidget
├── inview_state.dart             # ChangeNotifier — tracks which widget ids are currently in-view
├── inherited_inview_widget.dart  # InheritedWidget — passes InViewState down the tree
└── widget_data.dart              # Simple data class — stores BuildContext + id pairs
```

### How It Works (Core Flow)

1. `InViewNotifier` wraps a `ScrollView` in a `NotificationListener<ScrollNotification>`
2. Scroll events are throttled via `stream_transform`'s `audit()` into a `StreamController`
3. On each throttled event, `InViewState.onScroll()` iterates all registered widget contexts
4. For each widget, it calculates `deltaTop` and `deltaBottom` relative to the viewport
5. The user-provided `IsInViewPortCondition` function evaluates whether the widget is "in view"
6. `InViewState` extends `ChangeNotifier` — it calls `notifyListeners()` only when state actually changes
7. `InViewNotifierWidget` uses `AnimatedBuilder` on the `InViewState` to rebuild when visibility changes

### Key Design Decisions

- **Throttling over debouncing:** `audit()` emits the last event at the end of each period, so detection stays responsive during fast scroll without flooding the handler.
- **No widget-level configuration:** The `IsInViewPortCondition` is set once at the list level, not per-widget. This keeps the API simple.
- **Builder pattern over children list:** Uses `ListView.builder` under the hood for lazy construction.
- **`ChangeNotifier` dedup:** Lines 86-95 of `inview_state.dart` prevent redundant `notifyListeners()` calls when a widget's in-view state hasn't actually changed. Do not remove these guards.

## Development

### Setup

```bash
flutter pub get
cd example && flutter pub get && cd ..
```

### Quality Checks

```bash
dart format --set-exit-if-changed .   # Formatting
dart analyze --fatal-infos            # Zero warnings, zero infos
flutter test                          # All tests must pass
flutter test --coverage               # Must stay above 90%
```

### Running the Example App

```bash
cd example
flutter run
```

The example has 4 tabs: basic in-view detection, expanded detection area, auto-play video, and CustomScrollView with grids + lists.

## Conventions

### Dart Style

- **Dart 3+ required.** SDK constraint: `>=3.0.0 <4.0.0`
- Use `super.key` and super parameters — never `Key? key` with `super(key: key)`
- Use modern `typedef` syntax: `typedef Foo = void Function(int)` not `typedef void Foo(int)`
- Use switch expressions where appropriate — no `late` + `switch`/`break` pattern
- Prefer `const` constructors
- No unnecessary `Container` wrappers — use `SizedBox`, `ColoredBox`, or return the child directly
- No `!` operator on Flutter APIs that return non-nullable in Flutter 3.x (e.g., `RenderAbstractViewport.of()`)

### Testing

- **CI enforces 90% minimum coverage.** PRs below this fail.
- Every test must catch a real bug. No coverage padding.
- Do NOT test Flutter framework behavior (e.g., `ChangeNotifier.addListener` works). Test YOUR logic.
- Do NOT test `toString()` or debug helpers.
- Tests are self-contained — do NOT import from `example/lib/`. Inline test widgets in the test file.
- Use `binding.setSurfaceSize()` inside `testWidgets` callbacks, never in `setUp`.

### What Not to Do

- Do not add features without an issue discussion first. The API surface is intentionally small.
- Do not refactor code you didn't change.
- Do not add comments, docstrings, or type annotations to unchanged code.
- Do not "improve" surrounding code when fixing a bug.
- Do not wrap things in `Container` just to add a single property.

### Commits

```
fix: description     # Bug fixes
feat: description    # New features
test: description    # Test changes
chore: description   # Maintenance (deps, CI, docs)
docs: description    # Documentation
ci: description      # CI/CD changes
```

### Changelog

User-facing changes go in `CHANGELOG.md`. Use `## [Unreleased]` for pending work. Maintainer assigns version on release.

## File Map

| File | What It Does | Touch With Care |
|------|-------------|-----------------|
| `lib/src/inview_state.dart` | Core algorithm — viewport intersection math | YES — the scroll detection logic is battle-tested |
| `lib/src/inview_notifier.dart` | Scroll listener + throttled stream | YES — stream lifecycle is subtle |
| `lib/src/inview_notifier_list.dart` | Public widgets + `InViewNotifierWidget` lifecycle | Moderate — widget lifecycle methods are critical |
| `lib/src/inherited_inview_widget.dart` | InheritedWidget plumbing | Simple — rarely needs changes |
| `lib/src/widget_data.dart` | Data class | Simple |
| `pubspec.yaml` | Version is source of truth for publish workflow | Version bump = auto-publish on merge |
| `.github/workflows/ci.yml` | CI: format, analyze, test, 90% coverage gate, dry-run | |
| `.github/workflows/publish.yml` | Auto-publish to pub.dev on version bump + GitHub Release | |

## DO NOT TOUCH — Critical Code That Looks "Wrong" But Is Correct

These patterns look like mistakes or candidates for "improvement" but are intentional. Breaking any of them causes real production bugs.

### 1. `getElementForInheritedWidgetOfExactType` in `InViewNotifierList.of()`
```dart
// inview_notifier_list.dart — InViewNotifierList.of() and InViewNotifierCustomScrollView.of()
context.getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()
```
**DO NOT change to `dependOnInheritedWidgetOfExactType`.** The current method does NOT register a rebuild dependency. If you "fix" it to use `dependOn...`, every `InViewNotifierWidget` rebuilds on every scroll frame — catastrophic performance.

### 2. `item.context!.findRenderObject()` in `InViewState.onScroll()`
```dart
// inview_state.dart:59
final RenderObject? renderObject = item.context!.findRenderObject();
```
**The `!` on `context` is intentional.** Context is guaranteed non-null at this point: `addContext` is called in `initState`, `removeContext` in `dispose`. If you "improve" this to `item.context?.findRenderObject()` with a silent return, widgets silently stop being detected as in-view.

### 3. `_inViewState?.dispose()` BEFORE `super.dispose()`
```dart
// inview_notifier.dart:75-80
void dispose() {
  _inViewState?.dispose();
  _inViewState = null;
  _streamController?.close();
  super.dispose();
}
```
**The order matters.** `_inViewState` is a `ChangeNotifier` owned by this widget. It must be disposed before `super.dispose()`. Removing it = memory leak. Moving it after `super.dispose()` = crash.

### 4. `audit()` not `debounce()` on the scroll stream
```dart
// inview_notifier.dart:87-89
_streamController!.stream
    .audit(widget.throttleDuration)
    .listen(_inViewState!.onScroll);
```
**DO NOT replace `audit` with `debounce`.** `audit` emits the last event at the end of each period — responsive during fast scroll. `debounce` waits for silence — misses events during continuous scroll. They look similar but produce fundamentally different behavior.

### 5. `updateShouldNotify` returns `false`
```dart
// inherited_inview_widget.dart
bool updateShouldNotify(InheritedInViewWidget oldWidget) => false;
```
**This is correct.** State changes propagate via `ChangeNotifier` + `AnimatedBuilder`, not through `InheritedWidget` rebuilds. Changing this to `true` causes unnecessary subtree rebuilds on every scroll event.

### 6. `notifyListeners` dedup guards in `onScroll()`
```dart
// inview_state.dart:86-95
if (isInViewport) {
  if (!_currentInViewIds.contains(item.id)) {
    _currentInViewIds.add(item.id);
    notifyListeners();
  }
} else {
  if (_currentInViewIds.contains(item.id)) {
    _currentInViewIds.remove(item.id);
    notifyListeners();
  }
}
```
**DO NOT simplify by removing the `contains` checks.** Without them, `notifyListeners` fires on every throttled scroll event even when nothing changed — causing redundant widget rebuilds across the entire list.

### 7. `intialIds` parameter name (typo)
```dart
// inview_state.dart:20
InViewState({required List<String> intialIds, ...})
```
**DO NOT rename to `initialIds`.** This is a public API. Renaming it is a breaking change that requires a major version bump. It has been this way since v2.0.0.

## Known Quirks

- `InViewNotifierCustomScrollView.of()` exists but is never called — `InViewNotifierWidget` always calls `InViewNotifierList.of()`. Both are identical. This is dead code but kept for API symmetry.
- The example app uses `video_player` which requires platform-specific setup. The package itself has no platform dependencies.
