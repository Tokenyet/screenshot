// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:screenshot/screenshot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture screen test', (WidgetTester tester) async {
    final Screenshot plugin = Screenshot.instance;
    final CapturedData? data = await plugin.capture(mode: ScreenshotMode.screen);
    // Should capture screen successfully on Windows
    expect(data, isNotNull);
    if (data != null) {
      expect(data.width, greaterThan(0));
      expect(data.height, greaterThan(0));
      expect(data.bytes.isNotEmpty, true);
    }
  });
}
