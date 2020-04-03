## [1.0.0] - 3rd April 2020.

- Code refactors.

- Added support for `CustomScrollView` with the addition of `InViewNotifierCustomScrollView`.

- `InViewNotifierList`  now uses a `builder` function to build it's children. This is replaced with previously used `children` property.

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