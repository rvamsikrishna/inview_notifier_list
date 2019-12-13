import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group("test scroll fast up and down", () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver?.close();
    });

    test("scroll fast", () async {
      final listFinder = find.byValueKey("list1");
      await driver.scroll(listFinder, 0, -200, Duration(milliseconds: 600));

      var txt1 = await driver.getText(find.byValueKey("item-1"));
      var txt2 = await driver.getText(find.byValueKey("item-2"));

      for (int i = 0; i < 11; ++i) {
        await driver.scroll(listFinder, 0, -400, Duration(milliseconds: 100));
        driver.waitFor(listFinder);
        await driver.scroll(listFinder, 0, 400, Duration(milliseconds: 100));
        driver.waitFor(listFinder);
      }

      // expect item 1 notInView
      var txt = await driver.getText(find.byValueKey("item-1"));
      driver.waitFor(find.byValueKey("item-1"));
      expect(txt, txt1);

      // expect item 2 notInView
      txt = await driver.getText(find.byValueKey("item-2"));
      driver.waitFor(find.byValueKey("item-2"));
      expect(txt, txt2);
    });
  });
}
