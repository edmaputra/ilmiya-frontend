import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/models/school.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/school_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/academic_years/presentation/academic_years_screen.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/assign_role_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/edit_role_dialog.dart';
import 'package:ilmiya_app/features/iam_management/presentation/iam_management_screen.dart';
import 'package:ilmiya_app/features/iam_management/widgets/iam_user_tile.dart';
import 'package:ilmiya_app/features/school_profile/presentation/school_profile_screen.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_sidebar.dart';
import 'package:ilmiya_app/shared_widgets/tenant_session_required_view.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  late ApiClient apiClient;
  late MockStorageService mockStorage;
  late IamService iamService;
  late SchoolService schoolService;
  late AuthNotifier authNotifier;
  late AppState appState;

  setUp(() {
    apiClient = ApiClient()..isMockMode = true;
    mockStorage = MockStorageService();
    iamService = IamService(apiClient: apiClient, mockStorage: mockStorage);
    schoolService =
        SchoolService(apiClient: apiClient, mockStorage: mockStorage);
    authNotifier = AuthNotifier(apiClient: apiClient, iamService: iamService);
    appState = AppState();
  });

  Widget buildTestHost(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: MaterialApp(
          home: Scaffold(body: child),
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

  group('1. SuperAdmin Platform Session & Tenant Switching', () {
    testWidgets(
        'Superadmin login starts in platform session and requires switching tenant to manage schools/IAM',
        (WidgetTester tester) async {
      setUpViewport(tester);

      // Login as Superadmin persona
      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      expect(authNotifier.isSuperAdmin, isTrue);
      expect(authNotifier.isPlatformSession, isTrue);
      expect(authNotifier.tenantId, equals('platform'));

      // Render School Profile screen -> should prompt TenantSessionRequiredView
      await tester.pumpWidget(buildTestHost(const SchoolProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TenantSessionRequiredView), findsOneWidget);
      expect(find.textContaining('Tenant Session Required'), findsOneWidget);

      // Render Academic Years screen -> should also prompt TenantSessionRequiredView
      await tester.pumpWidget(buildTestHost(const AcademicYearsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TenantSessionRequiredView), findsOneWidget);

      // Render IAM Console -> should also prompt TenantSessionRequiredView
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TenantSessionRequiredView), findsOneWidget);

      // Now switch session to a target school tenant
      await authNotifier.switchTenant('tenant-lincoln-high-001');
      expect(authNotifier.hasSwitchedTenant, isTrue);
      expect(authNotifier.isPlatformSession, isFalse);
      expect(authNotifier.tenantId, equals('tenant-lincoln-high-001'));

      // Re-render IAM Console -> should now render full IAM Console
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TenantSessionRequiredView), findsNothing);
      expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);
    });

    testWidgets(
        'Superadmin sidebar menu only shows Tenant Console in platform session, and reloads full menu after Switch Session',
        (WidgetTester tester) async {
      setUpViewport(tester);

      // Login as Superadmin persona (platform session)
      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      expect(authNotifier.isPlatformSession, isTrue);

      // Render Sidebar in platform session
      await tester.pumpWidget(buildTestHost(const AppShellSidebar()));
      await tester.pumpAndSettle();

      // Only Tenant Console should be visible
      expect(find.text('Tenant Console'), findsOneWidget);
      expect(find.text('School Profile'), findsNothing);
      expect(find.text('Executive Dashboard'), findsNothing);
      expect(find.text('Academic Years'), findsNothing);
      expect(find.text('Courses & Grades'), findsNothing);
      expect(find.text('IAM Console'), findsNothing);

      // Switch session
      await authNotifier.switchTenant('tenant-lincoln-high-001');
      await tester.pumpAndSettle();

      // Full menu is now reloaded for SuperAdmin
      expect(find.text('Tenant Console'), findsOneWidget);
      expect(find.text('School Profile'), findsOneWidget);
      expect(find.text('Executive Dashboard'), findsOneWidget);
      expect(find.text('Academic Years'), findsOneWidget);
      expect(find.text('Courses & Grades'), findsOneWidget);
      expect(find.text('IAM Console'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });
  });

  group('2. Provisioning of Tenant Admin', () {
    test(
        'Registering a tenant provisions root scope and assigns it to tenant admin',
        () async {
      final req = RegisterSchoolRequest(
        tenantId: 'tenant-darussalam-001',
        institutionCode: 'DARUSSALAM',
        name: 'Darussalam Islamic Boarding School',
        address: 'Jl. Pesantren No. 1, Bogor',
        contactEmail: 'info@darussalam.org',
        contactPhone: '+6281234567890',
        adminEmail: 'admin@darussalam.org',
        adminName: 'Ustadz Ahmad Fauzi',
        adminPassword: 'Password123!',
      );

      final school = await schoolService.registerSchool(req);
      expect(school.tenantId, equals('tenant-darussalam-001'));

      // Verify root scope creation
      final scopes =
          await iamService.getScopeTree(tenantId: 'tenant-darussalam-001');
      expect(scopes.isNotEmpty, isTrue);
      final rootScope = scopes.first;
      expect(rootScope.code, equals('ROOT'));
      expect(rootScope.path, equals('/ROOT'));
      expect(rootScope.id, equals('scope-tenant-darussalam-001-root'));

      // Verify tenant admin user creation
      final users =
          await iamService.listUsers(tenantId: 'tenant-darussalam-001');
      final adminUser =
          users.firstWhere((u) => u.email == 'admin@darussalam.org');
      expect(adminUser.fullName, contains('Ustadz Ahmad Fauzi'));

      // Verify tenant admin role assignment with root scope
      final assignments = await iamService.getUserRoles(adminUser.id);
      expect(assignments.isNotEmpty, isTrue);
      final assignment = assignments.first;
      expect(assignment.tenantId, equals('tenant-darussalam-001'));
      expect(assignment.scopeNodeId, equals(rootScope.id));
    });

    testWidgets(
        'Tenant Admin is eligible for IAM Console and isolated to its own tenant',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.tenantAdmin);
      expect(authNotifier.isTenantAdmin, isTrue);
      expect(authNotifier.isSuperAdmin, isFalse);
      expect(authNotifier.isPlatformSession, isFalse);

      // Verify Sidebar does not display Tenant Console (tab 8) for Tenant Admin
      await tester.pumpWidget(buildTestHost(const AppShellSidebar()));
      await tester.pumpAndSettle();
      expect(find.text('Tenant Console'), findsNothing);

      // Verify IAM Console renders for Tenant Admin
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);
    });
  });

  group('3. IAM Console -> User List & Scope Assignment', () {
    testWidgets(
        'AssignRoleDialog allows selecting and assigning role and scope',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final user = UserResponse(
        id: 'u-test-999',
        email: 'guru.matematika@ilmiya.edu',
        fullName: 'Budi Santoso, S.Pd',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final roles = [
        RoleResponse(
          id: 'role-teacher',
          tenantId: 'tenant-lincoln-high-001',
          code: 'TEACHER',
          name: 'Teacher',
          permissions: ['exam:grade:create', 'exam:grade:read'],
          isSystemRole: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      final scopes = [
        ScopeTreeNode(
          id: 'scope-root',
          code: 'ROOT',
          name: 'Lincoln High Root',
          path: '/ROOT',
          depth: 0,
          children: [
            ScopeTreeNode(
              id: 'scope-science',
              code: 'SCIENCE',
              name: 'Science Dept',
              path: '/ROOT/SCIENCE',
              depth: 1,
              children: [],
            ),
          ],
        ),
      ];

      bool assigned = false;

      await tester.pumpWidget(
        buildTestHost(
          AssignRoleDialog(
            user: user,
            roles: roles,
            scopes: scopes,
            tenantId: 'tenant-lincoln-high-001',
            initialRoleId: 'role-teacher',
            initialScopeId: 'scope-science',
            onRoleAssigned: () => assigned = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign Role: Budi Santoso, S.Pd'), findsOneWidget);
      expect(find.text('Target Role:'), findsOneWidget);
      expect(find.text('Boundary Scope:'), findsOneWidget);

      // Tap Assign & Save
      final saveBtn =
          find.widgetWithText(ElevatedButton, 'Assign Role & Scope');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(assigned, isTrue);

      // Verify stored role assignment includes scope
      final userRoles = await iamService.getUserRoles(user.id);
      expect(userRoles.isNotEmpty, isTrue);
      expect(userRoles.first.scopeNodeId, equals('scope-science'));
    });

    testWidgets('IamUserTile displays assigned role and scope path badges',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final user = UserResponse(
        id: 'u-tile-test',
        email: 'guru.fisika@ilmiya.edu',
        fullName: 'Siti Aminah, M.Si',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        buildTestHost(
          IamUserTile(
            user: user,
            canUpdateStatus: true,
            canAssign: true,
            canDelete: true,
            assignedRole: 'Teacher',
            assignedScope: '/ROOT/SCIENCE/PHYSICS',
            onAssignRole: (_) {},
            onDataReload: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Siti Aminah, M.Si'), findsOneWidget);
      expect(find.text('Role: Teacher'), findsOneWidget);
      expect(find.text('Scope: /ROOT/SCIENCE/PHYSICS'), findsOneWidget);
    });
  });

  group('4. IAM Console -> Roles Management (Edit & Delete)', () {
    testWidgets(
        'EditRoleDialog allows updating role name, description, and permissions',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final createdRole = mockStorage.createRole(
        'tenant-lincoln-high-001',
        CreateRoleRequest(
          code: 'CURRICULUM_EDITOR',
          name: 'Curriculum Editor',
          description: 'Initial description',
          permissions: ['school:profile:read'],
        ),
      );

      bool updated = false;

      await tester.pumpWidget(
        buildTestHost(
          EditRoleDialog(
            role: createdRole,
            onRoleUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Role: CURRICULUM_EDITOR'), findsOneWidget);

      // Edit name
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Senior Curriculum Editor');

      // Tap Save Changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(updated, isTrue);

      // Verify mock storage updated
      final allRoles =
          await iamService.listRoles(tenantId: 'tenant-lincoln-high-001');
      final updatedRole =
          allRoles.firstWhere((r) => r.code == 'CURRICULUM_EDITOR');
      expect(updatedRole.name, equals('Senior Curriculum Editor'));
    });

    test('Custom role can be deleted but system role deletion throws exception',
        () async {
      // Create custom role
      final customRole = await iamService.createRole(
        CreateRoleRequest(
          code: 'CUSTOM_AUDITOR',
          name: 'Custom Auditor',
          description: 'Audits logs',
          permissions: ['audit:log:read'],
        ),
      );

      // Delete custom role
      await iamService.deleteRole(customRole.id);
      final rolesAfter = await iamService.listRoles();
      expect(rolesAfter.any((r) => r.id == customRole.id), isFalse);

      // Attempting to delete system role throws exception
      final systemRole = rolesAfter.firstWhere((r) => r.isSystemRole);
      expect(
        () => iamService.deleteRole(systemRole.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
