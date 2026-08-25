import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/app.dart';

void main() {
  testWidgets('App renders main navigation shell without crashing', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const RideSensorCaptureApp());
      expect(find.byType(MainNavigationShell), findsOneWidget);
    });
  });
}
