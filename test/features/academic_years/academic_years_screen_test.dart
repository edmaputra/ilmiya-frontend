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

  void setUpViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('AcademicYearsScreen renders and displays academic years',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify title and main elements are rendered
    expect(find.text('Academic Years & Terms'), findsOneWidget);
    expect(find.text('New Academic Year'), findsOneWidget);
  });

  testWidgets('AcademicYearsScreen shows CURRENTLY ACTIVE badge',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Mock data has 'Tahun Ajaran 2026/2027' as the active year
    expect(find.text('CURRENTLY ACTIVE'), findsOneWidget);
  });

  testWidgets(
      'AcademicYearsScreen shows year cards in All Academic Years section',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // The catalog section header
    expect(find.text('All Institutional Calendars'), findsOneWidget);

    // Both mock academic year names should appear
    expect(find.text('Tahun Ajaran 2026/2027'), findsWidgets);
    expect(find.text('Tahun Ajaran 2025/2026'), findsOneWidget);
  });

  testWidgets('New Academic Year button opens dialog with correct title',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap the 'New Academic Year' ElevatedButton
    final newYearButton =
        find.widgetWithText(ElevatedButton, 'New Academic Year');
    expect(newYearButton, findsOneWidget);
    await tester.tap(newYearButton);
    await tester.pumpAndSettle();

    // AlertDialog should open with 'New Academic Year' title text
    expect(find.text('New Academic Year'), findsWidgets);

    // The dialog should show the default name field value
    expect(find.text('Tahun Ajaran 2027/2028'), findsOneWidget);

    // Dismiss by tapping Cancel
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Dialog should be closed — 'New Academic Year' still exists in the button,
    // but 'Tahun Ajaran 2027/2028' should be gone
    expect(find.text('Tahun Ajaran 2027/2028'), findsNothing);
  });

  testWidgets(
      'Add Term button on active year card opens Add Academic Term dialog',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // The active year card has an 'Add Term' OutlinedButton.icon
    final addTermButton = find.widgetWithText(OutlinedButton, 'Add Term');
    expect(addTermButton, findsOneWidget);
    await tester.tap(addTermButton);
    await tester.pumpAndSettle();

    // AlertDialog title should be 'Add Academic Term'
    expect(find.text('Add Academic Term'), findsOneWidget);

    // Dismiss by tapping Cancel
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.text('Add Academic Term'), findsNothing);
  });

  testWidgets(
      'AcademicYearsScreen shows Terms & Semesters Breakdown section for active year',
      (WidgetTester tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Terms & Semesters Breakdown'), findsOneWidget);

    // Active year has 'Semester 1 (Ganjil)' and 'Semester 2 (Genap)' terms
    expect(find.text('Semester 1 (Ganjil)'), findsWidgets);
    expect(find.text('Semester 2 (Genap)'), findsOneWidget);
  });
}
