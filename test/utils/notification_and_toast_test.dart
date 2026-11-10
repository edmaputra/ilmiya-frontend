import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/notification_service.dart';
import 'package:ilmiya_app/core/utils/app_toast.dart';

void main() {
  group('NotificationService Tests', () {
    test('playNotificationChime executes without uncaught errors', () async {
      await expectLater(
        NotificationService.playNotificationChime(),
        completes,
      );
    });
  });

  group('AppToast Widget Tests', () {
    testWidgets('AppToast renders success, error, and info snackbars',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        AppToast.showSuccess(context, 'Success action'),
                    child: const Text('Show Success'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppToast.showError(context, 'Error action'),
                    child: const Text('Show Error'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppToast.showInfo(context, 'Info action'),
                    child: const Text('Show Info'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Tap Show Success
      await tester.tap(find.text('Show Success'));
      await tester.pumpAndSettle();
      expect(find.text('Success action'), findsOneWidget);

      // Tap Show Error
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();
      expect(find.text('Error action'), findsOneWidget);

      // Tap Show Info
      await tester.tap(find.text('Show Info'));
      await tester.pumpAndSettle();
      expect(find.text('Info action'), findsOneWidget);
    });
  });
}
