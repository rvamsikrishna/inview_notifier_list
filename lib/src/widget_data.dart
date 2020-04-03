import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WidgetData {
  final BuildContext context;
  final String id;

  WidgetData({@required this.context, @required this.id});

  @override
  String toString() {
    return describeIdentity(this) + " id=$id";
  }
}
