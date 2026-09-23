import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/iam_management/presentation/iam_management_screen.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableWidget() {
    return ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: const MaterialApp(
          home: Scaffold(
            body: IamManagementScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('IamManagementScreen renders and switches between tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify main header title
    expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);

    // Default tab is Users
    expect(find.text('Users'), findsWidgets);

    // Switch to Roles & RBAC tab
    await tester.tap(find.text('Roles & RBAC'));
    await tester.pumpAndSettle();
    expect(find.text('Roles & RBAC'), findsWidgets);

    // Switch to Groups tab
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsWidgets);

    // Switch to Scopes tab
    await tester.tap(find.text('Scope Tree'));
    await tester.pumpAndSettle();
    expect(find.text('Scope Tree'), findsWidgets);
  });
}
