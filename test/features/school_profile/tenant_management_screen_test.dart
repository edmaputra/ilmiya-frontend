import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/auth/presentation/login_dialog.dart';
import 'package:ilmiya_app/features/school_profile/dialogs/register_foundation_dialog.dart';
import 'package:ilmiya_app/features/school_profile/presentation/schools_campuses_screen.dart';
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

Widget buildTestableSchoolsCampusesScreen({AuthNotifier? authNotifier}) {
  return ChangeNotifierProvider<AuthNotifier>(
    create: (_) => authNotifier ?? AuthNotifier(),
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: const MaterialApp(
        home: Scaffold(
          body: SchoolsCampusesScreen(),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    ApiClient().tenantId = 'tenant-lincoln-high-001';
    MockStorageService().reset();
  });

  group('TenantManagementScreen Tests', () {
    testWidgets(
        'renders title, superadmin badge, and switches through all tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      // Main title and badge
      expect(find.text('Tenant Governance & Platform Administration'),
          findsOneWidget);
      expect(find.text('SUPERADMIN'), findsWidgets);

      // Default tab: Foundations (Yayasan)
      expect(find.text('TOTAL FOUNDATIONS'), findsOneWidget);
      expect(find.text('ACTIVE FOUNDATIONS'), findsOneWidget);
      expect(find.text('Register Foundation / Tenant'), findsOneWidget);

      // Switch to System & Quotas tab
      final quotasTab = find.text('System & Quotas');
      await tester.ensureVisible(quotasTab);
      await tester.tap(quotasTab);
      await tester.pumpAndSettle();
      expect(find.text('Multi-Tenant Platform Governance & Quotas'),
          findsOneWidget);
      expect(find.text('Data Isolation & Security Policies'), findsOneWidget);
    });

    testWidgets('search filtering in Foundations Directory narrows results',
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
              'Search by foundation name, tenant ID, or AHU number...');
      expect(searchField, findsOneWidget);

      // Filter for Lincoln Foundation
      await tester.enterText(searchField, 'Lincoln');
      await tester.pumpAndSettle();

      expect(find.textContaining('Lincoln'), findsWidgets);
      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsNothing);

      // Filter for nonexistent
      await tester.enterText(searchField, 'NonExistentFoundation12345');
      await tester.pumpAndSettle();

      expect(find.text('No foundation tenants matched the criteria.'),
          findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsOneWidget);
    });

    testWidgets('status filter chips filter foundations correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      // Tap SUSPENDED status chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'SUSPENDED'));
      await tester.pumpAndSettle();

      expect(find.text('St. Jude Educational Association'), findsOneWidget);
      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsNothing);

      // Tap ALL status chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'ALL'));
      await tester.pumpAndSettle();

      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsOneWidget);
    });

    testWidgets(
        'Register Foundation button opens dialog and Cancel dismisses it',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final registerBtn = find.text('Register Foundation / Tenant');
      expect(registerBtn, findsOneWidget);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(find.text('Register Foundation / Tenant'), findsWidgets);
      expect(
          find.text(
              'Provision a parent Foundation (Yayasan) organization to govern multiple school campuses and centralize administrative oversight.'),
          findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Provision a parent Foundation (Yayasan) organization to govern multiple school campuses and centralize administrative oversight.'),
          findsNothing);
    });

    testWidgets(
        'Register Foundation registers new foundation with valid fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register Foundation / Tenant'));
      await tester.pumpAndSettle();

      // Fill in fields
      final tenantIdField =
          find.widgetWithText(TextField, 'Foundation / Tenant ID *');
      final nameField =
          find.widgetWithText(TextField, 'Foundation Name (Yayasan) *');

      await tester.enterText(tenantIdField, 'tenant-summit-007');
      await tester.enterText(nameField, 'Yayasan Summit Valley');
      await tester.pumpAndSettle();

      // Tap Register Foundation inside dialog actions
      final submitBtn =
          find.widgetWithText(FilledButton, 'Register Foundation');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterFoundationDialog), findsNothing);
      expect(find.text('Yayasan Summit Valley', skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('Add School Campus button opens RegisterSchoolDialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final addCampusBtns = find.text('Add School Campus');
      expect(addCampusBtns, findsWidgets);
      await tester.tap(addCampusBtns.first);
      await tester.pumpAndSettle();

      expect(find.text('Register School Campus / Unit'), findsOneWidget);
      expect(find.text('Parent Foundation (Yayasan) *'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Register School Campus / Unit'), findsNothing);
    });

    testWidgets('Edit Foundation icon button opens dialog and Cancel dismisses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final editBtns = find.text('Edit Foundation');
      expect(editBtns, findsWidgets);
      await tester.tap(editBtns.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Foundation:'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit Foundation:'), findsNothing);
    });

    testWidgets('Toggle Foundation status toggles status',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final suspendBtns = find.text('Suspend');
      expect(suspendBtns, findsWidgets);
      await tester.tap(suspendBtns.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('is now suspended'), findsOneWidget);
    });

    testWidgets('Switch Session button triggers session switch and toast',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final switchBtns = find.text('Switch Session');
      expect(switchBtns, findsWidgets);
      await tester.ensureVisible(switchBtns.first);
      await tester.tap(switchBtns.first);
      await tester.pumpAndSettle();

      expect(
          find.textContaining('session switched to tenant:'), findsOneWidget);
    });

    testWidgets('Schools & Campuses tab searches and renders school cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableSchoolsCampusesScreen());
      await tester.pumpAndSettle();

      final searchField = find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.hintText ==
              'Search by school name, tenant ID, code, or NPSN...');
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Lincoln');
      await tester.pumpAndSettle();

      expect(find.textContaining('Lincoln'), findsWidgets);
    });

    testWidgets('Schools & Campuses tab filters schools by active tenant',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = AuthNotifier();

      await tester
          .pumpWidget(buildTestableSchoolsCampusesScreen(authNotifier: auth));
      await tester.pumpAndSettle();

      // Active tenant is DEFAULT_TENANT_ID (Lincoln High)
      expect(find.textContaining('Lincoln High Campus'), findsWidgets);
      expect(find.textContaining('Al-Azhar Islamic Academy'), findsNothing);

      // Switch active tenant to Al-Azhar
      await auth.switchTenant('tenant-alazhar-003');
      await tester.pumpAndSettle();

      // Should now show Al-Azhar and hide Lincoln High Campus
      expect(find.textContaining('Al-Azhar Islamic Academy'), findsWidgets);
      expect(find.textContaining('Lincoln High Campus'), findsNothing);
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
      expect(find.text('Sign In with SuperAdmin Account'), findsOneWidget);

      // Tapping switch button opens login dialog
      await tester.tap(find.text('Sign In with SuperAdmin Account'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginDialog), findsOneWidget);
    });

    testWidgets(
        'renders Foundations Directory without overflow on mobile viewport (375x667)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      expect(find.text('Tenant Governance & Platform Administration'),
          findsOneWidget);
      expect(find.text('TOTAL FOUNDATIONS'), findsOneWidget);

      final registerBtn = find.text('Register Foundation / Tenant');
      await tester.drag(find.byType(ListView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(registerBtn, findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(find.textContaining('Lincoln'), findsWidgets);
    });

    testWidgets(
        'renders System & Quotas tab without overflow on mobile viewport (375x667)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      final quotasTab = find.text('System & Quotas');
      await tester.ensureVisible(quotasTab);
      await tester.tap(quotasTab);
      await tester.pumpAndSettle();

      expect(find.text('Multi-Tenant Platform Governance & Quotas'),
          findsOneWidget);
      expect(find.text('Max Active Student Accounts'), findsOneWidget);
      expect(find.text('Data Isolation & Security Policies'), findsOneWidget);
    });

    testWidgets(
        'renders Institutional Inspector tab on mobile (375x667) and tablet (768x1024) without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableSchoolsCampusesScreen());
      await tester.pumpAndSettle();

      final inspectorTab = find.text('Institutional Inspector');
      await tester.ensureVisible(inspectorTab);
      await tester.tap(inspectorTab);
      await tester.pumpAndSettle();

      expect(find.text('Select Tenant to Inspect:'), findsOneWidget);
      expect(find.text('Legal & Institutional Identity'), findsOneWidget);
      expect(find.text('Operational Policies'), findsOneWidget);

      // Also verify on tablet portrait (768x1024)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpAndSettle();

      expect(find.text('Legal & Institutional Identity'), findsOneWidget);
      expect(find.text('Operational Policies'), findsOneWidget);
    });

    testWidgets(
        'renders full-width metric cards responsively across desktop, tablet, and mobile',
        (WidgetTester tester) async {
      // Desktop viewport (1280x800) -> 4-column row
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableTenantScreen());
      await tester.pumpAndSettle();

      expect(find.text('TOTAL FOUNDATIONS'), findsOneWidget);
      expect(find.text('ACTIVE FOUNDATIONS'), findsOneWidget);
      expect(find.text('SUSPENDED'), findsWidgets);
      expect(find.text('TOTAL CAMPUSES'), findsOneWidget);

      // Tablet viewport (600x900) -> 2x2 grid
      tester.view.physicalSize = const Size(600, 900);
      await tester.pumpAndSettle();

      expect(find.text('TOTAL FOUNDATIONS'), findsOneWidget);
      expect(find.text('ACTIVE FOUNDATIONS'), findsOneWidget);
      expect(find.text('SUSPENDED'), findsWidgets);
      expect(find.text('TOTAL CAMPUSES'), findsOneWidget);

      // Narrow mobile viewport (320x568) -> 1-column stack
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();

      expect(find.text('TOTAL FOUNDATIONS'), findsOneWidget);
      expect(find.text('ACTIVE FOUNDATIONS'), findsOneWidget);
      expect(find.text('SUSPENDED'), findsWidgets);
      expect(find.text('TOTAL CAMPUSES'), findsOneWidget);
    });
  });
}
