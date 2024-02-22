# **inview_notifier_list**

[![pub package](https://img.shields.io/badge/pub-v3.0.0-blue)](https://pub.dev/packages/inview_notifier_list)

A Flutter package that builds a [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) or [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) and notifies when the widgets are on screen within a provided area.

|                                                            Example 1                                                             |                                                              Example 2                                                              |                                                     Example 3(Auto-play video)                                                      |
|:--------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------:|
| ![ezgif com-gif-maker (1)](https://user-images.githubusercontent.com/31307345/59602739-2f022d00-9125-11e9-84ef-19a33f8bd782.gif) | ![ezgif com-video-to-gif (1)](https://user-images.githubusercontent.com/31307345/59602740-2f022d00-9125-11e9-8ee6-044e44f6048f.gif) | ![ezgif com-video-to-gif (2)](https://user-images.githubusercontent.com/31307345/59602744-2f9ac380-9125-11e9-8a8f-7e68bdc27c16.gif) |
|                                                **Example 4(Custom Scroll View)**                                                 |                                                                                                                                     |                                                                                                                                     |
|       ![csv_example](https://user-images.githubusercontent.com/31307345/78342587-22b56680-75b7-11ea-8f6e-22a8f378546d.gif)       |                                                                                                                                     |                                                                                                                                     |

## Index

- [Use cases](https://github.com/rvamsikrishna/inview_notifier_list#use-cases)
- [Installation](https://github.com/rvamsikrishna/inview_notifier_list#installation)
- [Basic Usage](https://github.com/rvamsikrishna/inview_notifier_list#basic-usage)
- [Types of Notifiers](https://github.com/rvamsikrishna/inview_notifier_list#types-of-notifiers)
- [Properties](https://github.com/rvamsikrishna/inview_notifier_list#properties)
- [Credits](https://github.com/rvamsikrishna/inview_notifier_list#credits)

## Use-cases

- To auto-play a video when a user scrolls.

- To add real-time update listeners from database to the posts/content only within an area visible to the user.

  > Note: If you have other use cases please update this section and create a PR.

## Installation

Just add the package to your dependencies in the `pubspec.yaml` file:

```yaml
dependencies:
  inview_notifier_list: ^3.0.0
```

## Basic Usage

###### Step 1:

Add the `InViewNotifierList` to your widget tree

```dart
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InViewNotifierList(
		/// ...
      ),
    );
  }
}

```

###### Step 2:

Add the [required](https://api.flutter.dev/flutter/meta/required-constant.html) property `isInViewPortCondition` to the `InViewNotifierList` widget. This is the function that defines the area which the widgets overlap should be notified as currently in-view.

```dart
typedef bool IsInViewPortCondition(
  double deltaTop,
  double deltaBottom,
  double viewPortDimension,
);

```

It takes 3 parameters:

1. **deltaTop**: It is the distance from top of the widget to be notified in the list view to top of the viewport(0.0).

2. **deltaBottom**: It is the distance from bottom of the widget to be notified in the list view to top of the viewport(0.0).

3. **viewPortDimension**: The height or width of the viewport depending on the `srollDirection` property provided. The image below showcases the values if the `srollDirection` is `Axis.vertical`.

   ![Untitled Diagram](https://user-images.githubusercontent.com/31307345/59606620-3c241980-912f-11e9-8c63-3029661c76ac.jpg)

Here is an example that returns `true` only when the widget's top is above the halfway of the viewport and the widget's bottom is below the halfway of the viewport. It is shown in [example1](https://github.com/rvamsikrishna/inview_notifier_list/blob/master/example/lib/my_list.dart#L24).

```dart
InViewNotifierList(
  isInViewPortCondition:
      (double deltaTop, double deltaBottom, double viewPortDimension) {
    return deltaTop < (0.5 * viewPortDimension) &&
        deltaBottom > (0.5 * viewPortDimension);
  },
),

```

###### step 3:

Add the [IndexedWidgetBuilder](https://api.flutter.dev/flutter/widgets/IndexedWidgetBuilder.html) , which builds the children on demand. It is just like the [ListView.builder](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html).

```dart
InViewNotifierList(
    isInViewPortCondition:(...){...},
    itemCount: 10,
    builder: (BuildContext context, int index) {
      return child;
    }

),
```

###### step 4:

Use the `InViewNotifierWidget` to get notified if the required widget is currently in-view or not.

The `InViewNotifierWidget` consists of the following properties:

1. `id`: a **required** String property. This should be unique for every widget that wants to get notified.
2. `builder` : Signature for a function that creates a widget for a given index. The function that defines and returns the widget that should be notified as inView. See [InViewNotifierWidgetBuilder](https://pub.dev/documentation/inview_notifier_list/latest/inview_notifier_list/InViewNotifierWidgetBuilder.html).
3. `child`: The child widget to pass to the builder.

```dart
InViewNotifierWidget(
  id: 'unique-Id',
  builder: (BuildContext context, bool isInView, Widget child) {
    return Container(
      child: Text(
        isInView ? 'in view' : 'not in view',
      ),
    );
  },
)
```

That's it, done!

A complete code:

```dart
InViewNotifierList(
  isInViewPortCondition:
      (double deltaTop, double deltaBottom, double vpHeight) {
    return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
  },
  itemCount: 10,
  builder: (BuildContext context, int index) {
    return InViewNotifierWidget(
      id: '$index',
      builder: (BuildContext context, bool isInView, Widget child) {
        return Container(
          height: 250.0,
          color: isInView ? Colors.green : Colors.red,
          child: Text(
            isInView ? 'Is in view' : 'Not in view',
          ),
        );
      },
    );
  },
);

```

Run the [example](https://github.com/rvamsikrishna/inview_notifier_list/tree/master/example) app provided and check out the folder for complete code.

## Types of Notifiers

1. [InViewNotifierList](https://pub.dev/documentation/inview_notifier_list/latest/inview_notifier_list/InViewNotifierList-class.html): builds a [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) and notifies when the widgets are on screen within a provided area.
2. [InViewNotifierCustomScrollView](https://pub.dev/documentation/inview_notifier_list/latest/inview_notifier_list/InViewNotifierCustomScrollView-class.html): builds a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) and notifies when the widgets are on screen within a provided area.

## Properties

- `isInViewPortCondition`: [**Required**] The function that defines the area within which the widgets should be notified as in-view.

- `initialInViewIds`: The String list of unique ids of the child widgets that should be initialized as in-view when the list view is built for the first time.

- `endNotificationOffset`: The distance from the bottom of the list where the `onListEndReached` should be invoked. Defaults to the end of the list i.e 0.0.

- `onListEndReached`: The function that is invoked when the list scroll reaches the end or the `endNotificationOffset` if provided.

- `throttleDuration`: The duration to be used for throttling the scroll notification. Defaults to 200 milliseconds.

- `scrollDirection`: The axis along which the scroll view scrolls.

##### Credits:

Thanks to [Didier Boelens](https://www.didierboelens.com/) for the raw solution.
