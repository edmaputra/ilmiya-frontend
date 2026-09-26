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

  setUp(() {});

  group('SchoolProfileScreen', () {
    testWidgets('renders school details and Edit Profile button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SchoolProfileScreen), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('renders mock school name from storage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // The mock storage returns 'SMA Negeri 1 Ilmiya (Lincoln High Campus)'
      expect(
        find.text('SMA Negeri 1 Ilmiya (Lincoln High Campus)'),
        findsOneWidget,
      );
    });

    testWidgets('renders Operational Rules section with Configure button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Operational Rules'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
    });

    testWidgets(
        'tapping Edit Profile opens AlertDialog with Edit Institutional Profile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap the Edit Profile button
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify the dialog opened
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit Institutional Profile'), findsOneWidget);

      // Tap Cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping Configure opens Operational Settings AlertDialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap the Configure button (calls _showSettingsDialog)
      await tester.tap(find.text('Configure'));
      await tester.pumpAndSettle();

      // Verify the Operational Settings dialog opened
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Operational Settings'), findsOneWidget);

      // Tap Cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Edit Profile dialog shows school name field pre-filled',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // The dialog should show text fields with school info.
      // 'Address' also appears as an info-row label on the main screen, so
      // we assert at least one occurrence for those duplicated labels.
      expect(find.text('School Name'), findsOneWidget);
      expect(find.text('Address'), findsAtLeastNWidgets(1));
      expect(find.text('Contact Email'), findsAtLeastNWidgets(1));

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Operational Settings dialog shows Working Days and grading fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Configure'));
      await tester.pumpAndSettle();

      expect(find.text('School Working Days:'), findsOneWidget);
      expect(find.text('Grading Framework'), findsOneWidget);
      // 'Academic Term Layout' also appears in the main screen card,
      // so assert at least one occurrence.
      expect(find.text('Academic Term Layout'), findsAtLeastNWidgets(1));

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'renders cleanly without overflow on mobile phone dimensions (390x844)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SchoolProfileScreen), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Institutional Details'), findsOneWidget);
      expect(find.text('Operational Rules'), findsOneWidget);
      expect(find.text('Active Working Days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
