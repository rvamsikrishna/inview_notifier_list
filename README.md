# **inview_notifier_list**

A Flutter package that builds a [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) and notifies when the widgets are on screen within a provided area. 

|                                                            Example 1                                                             |                                                              Example 2                                                              |                                                     Example 3(Auto-play video)                                                      |
| :------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------: |
| ![ezgif com-gif-maker (1)](https://user-images.githubusercontent.com/31307345/59602739-2f022d00-9125-11e9-84ef-19a33f8bd782.gif) | ![ezgif com-video-to-gif (1)](https://user-images.githubusercontent.com/31307345/59602740-2f022d00-9125-11e9-8ee6-044e44f6048f.gif) | ![ezgif com-video-to-gif (2)](https://user-images.githubusercontent.com/31307345/59602744-2f9ac380-9125-11e9-8a8f-7e68bdc27c16.gif) |

## Use-cases

- To auto-play a video when a user scrolls.

- To add real-time update listeners from database to the posts/content only within an area visible to the user.

  > Note: If you have other use cases please update this section and create aPR.

  

## Installation

Just add the package to your dependencies in the `pubspec.yaml` file:

```yaml
dependencies:
  inview_notifier_list: ^0.0.3
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
		...
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

1. **deltaTop**:  It is the distance from top of the widget to be notified in the list view to top of the viewport(0.0).

2. **deltaBottom**:  It is the distance from bottom of the widget to be notified in the list view to top of the viewport(0.0).

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

Add the widgets to be displayed in the list view to the `children` property. 

```dart
InViewNotifierList(
    isInViewPortCondition:(...){...},
    children: <Widget>[
        ListChild(...),
        ListChild(...),
        ListChild(...),
        ...
    ],
),
```



###### step 4:

Add the widget's `context` and its String `id` to the `InViewState` that you want to be notified whether it is in-view or not.

The `InViewState` can be accessed by calling the `of` method of `InViewNotifierList` anywhere below the `InViewNotifierList` widget tree as follows:

```dart
InViewState state = InViewNotifierList.of(context);
```

Use `state` to add context for notification.

```dart
class ListChild extends StatelessWidget {
  final String id;

  const ListChild({Key key,@required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      
    InViewState state = InViewNotifierList.of(context);
    state.addContext(context: context, id: id);

    return Container(
      ...
    );
  }
}
```



###### Step 5:

Wrap the widget you want to get notified with an [AnimatedBuilder](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html) passing the above mentioned `InViewState` to the `animation` property. 

Then use the `InViewState`'s `inView` method which takes in the String id as an argument to check if the required widget is currently in-view or not.

```dart
Widget build(BuildContext context) {
  InViewState state = InViewNotifierList.of(context);
  state.addContext(context: context, id: id);
  return AnimatedBuilder(
    animation: state,
    builder: (BuildContext context, Widget child) {
      final bool inView = state.inView(id);
      return Container(
        child: Text(inView ? 'Is in View' : 'Not in View'),
      );
    },
  );
}

```

You can do the same using an [`AnimatedWidget`](https://api.flutter.dev/flutter/widgets/AnimatedWidget-class.html).



That's it, done! Run the [example](https://github.com/rvamsikrishna/inview_notifier_list/tree/master/example) app provided and check out the folder for complete code.

## Properties

- `isInViewPortCondition`: [**Required**]   The function that defines the area within which the widgets should be notified as in-view.
- `children`: *The widgets that should be displayed in the list view.
- `initialInViewIds`:   The String list of unique ids of the child widgets that should be initialized as in-view when the list view is built for the first time.
- `contextCacheCount`:   The number of widget's contexts the `InViewNotifierList` should stored/cached for the calculations thats needed to be done to check if the widgets are in-view or not. Defaults to 10 and should be greater than 1. This is done to reduce the number of calculations being performed.
- `endNotificationOffset`:   The distance from the bottom of the list where the `onListEndReached` should be invoked. Defaults to the end of the list i.e 0.0.
- `onListEndReached`:  The function that is invoked when the list scroll reaches the end or the `endNotificationOffset` if provided.
- `throttleDuration`:   The duration to be used for throttling the scroll notification. Defaults to 200 milliseconds.
- `scrollDirection`: The axis along which the scroll view scrolls. Defaults to `Axis.vertical`.
- `controller`:   An object that can be used to control the position to which this scroll view is scrolled. See [ScrollController](https://api.flutter.dev/flutter/widgets/ScrollController-class.html).
- `padding`: The amount of space by which to inset the children.
- `physics`: How the scroll view should respond to user input. See [ScrollPhysics](https://api.flutter.dev/flutter/widgets/ScrollPhysics-class.html).

##### Credits:

Thanks to [Didier Boelens](https://www.didierboelens.com/) for the raw solution.









