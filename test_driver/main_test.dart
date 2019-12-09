import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  test("xxx", () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    var listFind = find.byValueKey("list1");

    driver.scroll(listFind, 0, 10, Duration(milliseconds: 200));

  });
}
