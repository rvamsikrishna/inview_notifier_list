## [4.0.0] - 3rd April 2026.

**Breaking Changes**

- **Minimum SDK**: Dart `>=3.0.0`, Flutter `>=3.10.0`. Dropped Dart 2.x support.

**Fixes & Improvements**

- Fixed `InheritedInViewWidget` redeclaring `child` field from `ProxyWidget` (compile error on Dart 3.x).
- Removed unnecessary `!` on `RenderAbstractViewport.of()` (now returns non-nullable in Flutter 3.x).
- Modernized `typedef` syntax to generic function type aliases.
- Replaced `switch`/`break` with Dart 3 switch expression for scroll direction.
- Removed unnecessary `Container` wrapper in `InViewNotifierWidget`.
- Adopted `super.key` and super parameters across all widget constructors.
- Tests are now self-contained (no longer import from the example app).
- Replaced Travis CI with GitHub Actions.
- Added `analysis_options.yaml` with `flutter_lints`.

**Example App**

- Regenerated Android/iOS/web native scaffolding for Flutter 3.x.
- Updated `TextTheme.headline4` (removed) to `headlineSmall`.
- Updated `VideoPlayerController.network()` (deprecated) to `.networkUrl()`.
- Updated `Color.withOpacity()` (deprecated) to `.withValues(alpha:)`.

## [3.0.0] - 28th December 2021.

**Breaking Changes**

- Removed the `contextCacheCount` property. The context will be auto cached and removed.

- Fixed `Cannot get renderObject of inactive element.` issue. Thanks to [SteepSheep](https://github.com/SteepSheep)'s [PR](https://github.com/rvamsikrishna/inview_notifier_list/pull/45).

- updated the video example to use latest plugin version.

## [2.0.0] - 5th June 2021.

- Migrated to Null Safety.

## [1.0.0] - 3rd April 2020.

- Code refactors.

- Added support for `CustomScrollView` with the addition of `InViewNotifierCustomScrollView`.

- `InViewNotifierList` now uses a `builder` function to build it's children. This is replaced with previously used `children` property.

- Added `InViewNotifierWidget` which gets notified if it is currently inside the viewport condition

  provided by the `InViewPortCondition` condition. Checkout out the [example](https://github.com/rvamsikrishna/inview_notifier_list/tree/master/example/lib) for usage.

- No longer need to add widget's context to `InViewState` and use `AnimatedBuilder` to get notified if the widget is in-view.

## [0.0.4] - 13th December 2019.

- Fixed fast scroll bugs.
- Updated use of `ancestorInheritedElementForWidgetOfExactType`(depricated) with `getElementForInheritedWidgetOfExactType`.
- Added more properties to list like `reverse`, `shrinkWrap`.

## [0.0.3] - 10th September 2019.

Added two extra properties `padding` and `physics`.

## [0.0.1] - 18th June 2019.

A Flutter package that builds a ListView and notifies when the widgets are on screen within a provided area.

## [0.0.1+1] - 19th June 2019.

**Breaking**- Fixed the typo for the property name from `srollDirection` to `scrollDirection`.

Before(v0.0.1):

```dart
InViewNotifierList(
  srollDirection: Axis.vertical,
)
```

After(v0.0.2):

```dart
InViewNotifierList(
  scrollDirection: Axis.vertical,
)
`
```
