import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/academic_years/presentation/academic_years_screen.dart';
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
            body: AcademicYearsScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('AcademicYearsScreen renders and displays academic years',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify title and main elements are rendered
    expect(find.text('Academic Years & Terms'), findsOneWidget);
    expect(find.text('New Academic Year'), findsOneWidget);
  });
}
