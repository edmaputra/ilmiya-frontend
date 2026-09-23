import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/school_profile/presentation/school_profile_screen.dart';
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
            body: SchoolProfileScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('SchoolProfileScreen renders school details and edit button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify main components are rendered
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byType(SchoolProfileScreen), findsOneWidget);
  });
}
