import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circle_access_lock/circle_access_lock.dart';
import 'package:flutter/gestures.dart';

void main() {
  testWidgets('Test Circle Access Lock', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final navigatorKey = GlobalKey<NavigatorState>();

    final circleAccessLock =
        CircleAccessLock(navigatorKey: navigatorKey, isTest: true);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () async {
                circleAccessLock.enable();
              },
              child: const Text('Enable Circle Access Lock',
                  textDirection: TextDirection.ltr),
            );
          },
        ),
      ),
    );

    final gesture = await tester.press(
        find.byWidgetPredicate((widget) =>
            widget is Text && widget.data == 'Enable Circle Access Lock'),
        buttons: kPrimaryButton,
        warnIfMissed: true);
    await gesture.up();

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(circleAccessLock.isEnabled, true);
  });
}
