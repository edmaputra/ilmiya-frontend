import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/features/messaging/widgets/security_audit_dialog.dart';

void main() {
  testWidgets('SecurityAuditDialog renders security details and closes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => const SecurityAuditDialog(),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(SecurityAuditDialog), findsOneWidget);
    expect(find.textContaining('End-to-End Encryption Audit'), findsOneWidget);
    expect(find.textContaining('ECDH Curve25519'), findsOneWidget);

    final confirmBtn = find.text('Confirm Verified Identity');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SecurityAuditDialog), findsNothing);
  });
}
