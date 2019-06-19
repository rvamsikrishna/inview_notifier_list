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