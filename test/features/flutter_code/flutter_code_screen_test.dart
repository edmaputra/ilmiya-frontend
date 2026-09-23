import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/features/flutter_code/presentation/flutter_code_screen.dart';

void main() {
  testWidgets('FlutterCodeScreen renders and switches subtabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterCodeScreen(),
        ),
      ),
    );

    expect(find.byType(FlutterCodeScreen), findsOneWidget);
    expect(find.text('Source Code'), findsOneWidget);
    expect(find.text('Architecture'), findsOneWidget);
    expect(find.text('CLI Guide'), findsOneWidget);

    // Switch to Architecture tab
    await tester.tap(find.text('Architecture'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Clean Feature-First Flutter Architecture'),
        findsOneWidget);

    // Switch to CLI Guide tab
    await tester.tap(find.text('CLI Guide'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CLI Setup & Multiplatform Build Instructions'),
        findsOneWidget);

    // Switch back to Source Code tab
    await tester.tap(find.text('Source Code'));
    await tester.pumpAndSettle();

    expect(find.text('pubspec.yaml'), findsWidgets);
  });
}
