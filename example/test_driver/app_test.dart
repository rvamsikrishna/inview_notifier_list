import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group("test scroll fast up and down", () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver?.close();
    });

    test("scroll fast", () async {
      final listFinder = find.byValueKey("list1");
      // scroll to item 1
      await driver!.scroll(listFinder, 0, -200, Duration(milliseconds: 100));

      // hack: force the driver wait 500ms for the notification events be process
      await driver!.scroll(listFinder, 0, 0, Duration(milliseconds: 500));

      var txt1 = await driver!.getText(find.byValueKey("item-1"));
      var txt2 = await driver!.getText(find.byValueKey("item-2"));

      // scroll up and down between item 1 & 2.
      for (int i = 0; i < 11; ++i) {
        await driver!.scroll(listFinder, 0, -400, Duration(milliseconds: 100));
        await driver!.scroll(listFinder, 0, 400, Duration(milliseconds: 100));
      }

      // hack: force the driver wait 500ms for the notification events be process
      await driver!.scroll(listFinder, 0, 0, Duration(milliseconds: 500));

      // expect item 1 notInView
      var txt = await driver!.getText(find.byValueKey("item-1"));
      expect(txt, txt1);

      // expect item 2 notInView
      txt = await driver!.getText(find.byValueKey("item-2"));
      expect(txt, txt2);
    });
  });
}
