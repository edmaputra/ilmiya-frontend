import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/school_profile/presentation/tenant_management_screen.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

Widget buildTestableTenantScreen({AuthNotifier? authNotifier}) {
  return ChangeNotifierProvider<AuthNotifier>(
    create: (_) => authNotifier ?? AuthNotifier(),
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: const MaterialApp(
        home: Scaffold(
          body: TenantManagementScreen(),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    MockStorageService().reset();
  });

  group('TenantManagementScreen Tests', () {
    testWidgets(
        'renders title, superadmin badge, and switches through all 3 tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      // Main title and badge
      expect(find.text('Tenant & School Profile Management'), findsOneWidget);
      expect(find.text('SUPERADMIN'), findsWidgets);

      // Default tab: Tenants Directory
      expect(find.text('TOTAL TENANTS'), findsOneWidget);
      expect(find.text('ACTIVE SCHOOLS'), findsOneWidget);

      // Switch to Institutional Inspector tab
      final inspectorTab = find.text('Institutional Inspector');
      await tester.ensureVisible(inspectorTab);
      await tester.tap(inspectorTab);
      await tester.pumpAndSettle();
      expect(find.text('Select Tenant to Inspect:'), findsOneWidget);
      expect(find.text('Legal & Institutional Identity'), findsOneWidget);

      // Switch to System & Quotas tab
      final quotasTab = find.text('System & Quotas');
      await tester.ensureVisible(quotasTab);
      await tester.tap(quotasTab);
      await tester.pumpAndSettle();
      expect(find.text('Multi-Tenant Platform Governance & Quotas'),
          findsOneWidget);
      expect(find.text('Data Isolation & Security Policies'), findsOneWidget);
    });

    testWidgets('search filtering in Tenants Directory narrows results',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final searchField = find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.hintText ==
              'Search by school name, tenant ID, code, or NPSN...');
      expect(searchField, findsOneWidget);

      // Filter for Lincoln
      await tester.enterText(searchField, 'Lincoln');
      await tester.pumpAndSettle();

      expect(find.textContaining('Lincoln'), findsWidgets);
      expect(find.text('Al-Azhar Islamic Academy'), findsNothing);

      // Filter for nonexistent
      await tester.enterText(searchField, 'NonExistentSchool12345');
      await tester.pumpAndSettle();

      expect(
          find.text('No school tenants matched the criteria.'), findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('Al-Azhar Islamic Academy'), findsOneWidget);
    });

    testWidgets('status filter chips filter tenants correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      // Tap PENDING status chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'PENDING'));
      await tester.pumpAndSettle();

      expect(find.text('Horizon International STEM Academy'), findsOneWidget);
      expect(find.text('Al-Azhar Islamic Academy'), findsNothing);

      // Tap SUSPENDED status chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'SUSPENDED'));
      await tester.pumpAndSettle();

      expect(find.text('St. Jude Preparatory School'), findsOneWidget);

      // Tap ALL status chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'ALL'));
      await tester.pumpAndSettle();

      expect(find.text('Al-Azhar Islamic Academy'), findsOneWidget);
    });

    testWidgets('Register School button opens dialog and Cancel dismisses it',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final registerBtn = find.text('Register School');
      expect(registerBtn, findsOneWidget);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(find.text('Register School Tenant'), findsOneWidget);
      expect(
          find.text(
              'Provision a new institutional partition with isolated databases, academic calendar, and IAM scope tree.'),
          findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Register School Tenant'), findsNothing);
    });

    testWidgets('Register School registers new tenant with valid fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register School'));
      await tester.pumpAndSettle();

      // Fill in fields
      final tenantIdField = find.widgetWithText(TextField, 'Tenant ID *');
      final codeField = find.widgetWithText(TextField, 'Institution Code *');
      final nameField =
          find.widgetWithText(TextField, 'School / Institution Name *');

      await tester.enterText(tenantIdField, 'tenant-summit-007');
      await tester.enterText(codeField, 'SUMMIT-007');
      await tester.enterText(nameField, 'Summit Valley Prep');
      await tester.pumpAndSettle();

      // Tap Register Tenant inside dialog actions
      await tester.tap(find.text('Register Tenant'));
      await tester.pumpAndSettle();

      expect(find.text('Register School Tenant'), findsNothing);
      expect(
          find.text('Summit Valley Prep', skipOffstage: false), findsOneWidget);
    });

    testWidgets('Edit Profile icon button opens dialog and Cancel dismisses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final editBtns = find.byTooltip('Edit Profile');
      expect(editBtns, findsWidgets);
      await tester.tap(editBtns.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Tenant:'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Tenant:'), findsNothing);
    });

    testWidgets(
        'Operational Settings icon button opens dialog and Cancel dismisses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final settingsBtns = find.byTooltip('Operational Settings');
      expect(settingsBtns, findsWidgets);
      await tester.tap(settingsBtns.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Operational Rules:'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Operational Rules:'), findsNothing);
    });

    testWidgets('Toggle status opens confirmation dialog and Cancel dismisses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final suspendBtns = find.byTooltip('Suspend Tenant');
      expect(suspendBtns, findsWidgets);
      await tester.tap(suspendBtns.first);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Tenant Status Change'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Tenant Status Change'), findsNothing);
    });

    testWidgets('Switch tenant button triggers active session switch',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final switchBtns = find.text('Switch');
      expect(switchBtns, findsWidgets);
      await tester.tap(switchBtns.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Active session switched to tenant:'),
          findsOneWidget);
    });

    testWidgets(
        'Non-superadmin user sees access restricted view with persona switch',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = AuthNotifier();
      // Switch to student persona Alex Rivera (non-superadmin)
      await auth.loginAsPersona(DemoPersonaKey.student);

      await tester.pumpWidget(buildTestableTenantScreen(authNotifier: auth));
      await tester.pumpAndSettle();

      expect(find.text('SuperAdmin Access Required'), findsOneWidget);
      expect(
          find.text('Switch to Platform SuperAdmin Persona'), findsOneWidget);

      // Tapping switch persona upgrades to SuperAdmin
      await tester.tap(find.text('Switch to Platform SuperAdmin Persona'));
      await tester.pumpAndSettle();

      expect(find.text('Tenant & School Profile Management'), findsOneWidget);
    });
  });
}
