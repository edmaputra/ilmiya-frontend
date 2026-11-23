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
import 'package:ilmiya_app/features/iam_management/widgets/iam_scopes_tab.dart';
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
      expect(find.text('Academic Years'), findsOneWidget);
      expect(find.text('IAM Console'), findsOneWidget);
    });

    testWidgets(
        'Superadmin switched to specific tenant only sees users under that tenant in IAM Console',
        (WidgetTester tester) async {
      setUpViewport(tester);

      // Login as Superadmin persona
      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);

      // Switch to tenant-sma1-ilmiya-002
      await authNotifier.switchTenant('tenant-sma1-ilmiya-002');
      await tester.pumpAndSettle();

      // Render IAM Management Screen
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();

      // User List tab should only show users for tenant-sma1-ilmiya-002
      expect(
          find.text('Dra. Nurhayati (Kepala SMAN 1 Ilmiya)'), findsOneWidget);
      expect(find.text('Prof. Marcus Chen (School Principal)'), findsNothing);
      expect(find.text('Dr. Eleanor Vance (Computer Science Faculty)'),
          findsNothing);
      expect(find.text('Alex Rivera (Class 10-A)'), findsNothing);

      // Now switch session to tenant-lincoln-high-001
      await authNotifier.switchTenant('tenant-lincoln-high-001');
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();

      // User List tab should now show Lincoln High users and NOT Dra. Nurhayati
      expect(find.text('Prof. Marcus Chen (School Principal)'), findsOneWidget);
      expect(find.text('Dr. Eleanor Vance (Computer Science Faculty)'),
          findsOneWidget);
      expect(find.text('Dra. Nurhayati (Kepala SMAN 1 Ilmiya)'), findsNothing);
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

      expect(
          find.text('Assign Role & Scope: Budi Santoso, S.Pd'), findsOneWidget);
      expect(find.text('Role *'), findsOneWidget);
      expect(find.text('Target Scope (Hierarchy)'), findsOneWidget);

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
      expect(find.text('Teacher'), findsOneWidget);
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
          tenantId: 'tenant-lincoln-high-001',
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
      final nameField = find.widgetWithText(TextFormField, 'Role Name *');
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'Senior Curriculum Editor');
      } else {
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Senior Curriculum Editor');
      }

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
          tenantId: 'tenant-lincoln-high-001',
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

    testWidgets('Scope removal deletes node from tree and calls deleteScope',
        (WidgetTester tester) async {
      // Create a scope
      await iamService.createScope(CreateScopeRequest(
        tenantId: 'tenant-lincoln-high-001',
        code: 'TEMPORARY_SCOPE',
        name: 'Temporary Scope',
      ));

      final scopesBefore = await iamService.getScopeTree();
      expect(scopesBefore.any((s) => s.code == 'TEMPORARY_SCOPE'), isTrue);

      final targetNode =
          scopesBefore.firstWhere((s) => s.code == 'TEMPORARY_SCOPE');

      // Verify service deletion
      await iamService.deleteScope(targetNode.id);

      final scopesAfter = await iamService.getScopeTree();
      expect(scopesAfter.any((s) => s.code == 'TEMPORARY_SCOPE'), isFalse);
    });
  });

  group('5. School-Anchored IAM Scope & Multi-Role/Group Assignment', () {
    testWidgets(
        'IamScopesTab displays school required notice and disables root scope button when schools list is empty',
        (WidgetTester tester) async {
      setUpViewport(tester);

      bool createTapped = false;

      await tester.pumpWidget(
        buildTestHost(
          IamScopesTab(
            scopes: const [],
            schools: const [],
            tenantId: 'tenant-test-001',
            canCreateScope: true,
            onCreateRootScope: (_) => createTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hierarchical Scope Tree'), findsOneWidget);
      expect(find.text('School Required to Manage Scopes'), findsOneWidget);

      final createBtn = find.byKey(const ValueKey('create_root_scope_btn'));
      expect(createBtn, findsOneWidget);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      expect(createTapped, isFalse);
    });

    testWidgets(
        'IamScopesTab shows school selector and displays school-scoped root path when schools are present',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final sampleSchools = <SchoolResponse>[
        SchoolResponse(
          id: 'school-sma-01',
          tenantId: 'tenant-test-001',
          name: 'SMA Al-Hikmah Primary',
          institutionCode: 'SMA01',
          status: 'ACTIVE',
          address: 'Jl. Merdeka 10',
          contactEmail: 'sma01@ilmiya.edu',
          contactPhone: '08123456789',
          workingDays: const ['MONDAY', 'TUESDAY'],
          gradingPreference: 'PERCENTAGE',
          termLayout: 'SEMESTER',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      SchoolResponse? createdForSchool;

      await tester.pumpWidget(
        buildTestHost(
          IamScopesTab(
            scopes: [
              ScopeTreeNode(
                id: 'scope-root-sma',
                code: 'SMA01',
                name: 'SMA Al-Hikmah Primary Root',
                path: '/tenant-test-001/school-sma-01',
                depth: 0,
                children: [],
              ),
            ],
            schools: sampleSchools,
            tenantId: 'tenant-test-001',
            canCreateScope: true,
            onCreateRootScope: (s) => createdForSchool = s,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('School Required to Manage Scopes'), findsNothing);
      expect(find.text('Select School:'), findsOneWidget);
      expect(find.textContaining('/tenant-test-001/school-sma-01/'),
          findsOneWidget);

      final createBtn = find.byKey(const ValueKey('create_root_scope_btn'));
      expect(createBtn, findsOneWidget);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      expect(createdForSchool, isNotNull);
      expect(createdForSchool!.id, equals('school-sma-01'));
    });

    testWidgets(
        'AssignRoleDialog supports multi-role listing, revoking, and groups tab',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final user = UserResponse(
        id: 'u-multi-test',
        email: 'multi.user@ilmiya.edu',
        fullName: 'Dr. Multi Role',
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
          isSystemRole: false,
          permissions: ['grade:write'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      // Assign initial role
      await iamService.assignRole(
        userId: user.id,
        roleId: 'role-teacher',
        tenantId: 'tenant-lincoln-high-001',
      );

      await tester.pumpWidget(
        buildTestHost(
          AssignRoleDialog(
            user: user,
            roles: roles,
            scopes: const [],
            tenantId: 'tenant-lincoln-high-001',
            iamService: iamService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Tabs
      expect(find.text('Roles & Scopes'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);

      // Check current assigned role is listed
      expect(find.textContaining('Teacher'), findsAtLeastNWidgets(1));

      // Switch to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Group Memberships'), findsOneWidget);
      expect(find.textContaining('Add to Group'), findsAtLeastNWidgets(1));
    });
  });

  group(
      '6. Role Boundaries, Visual Badges, Search & Protection in IamScopesTab',
      () {
    final sampleSchools = <SchoolResponse>[
      SchoolResponse(
        id: 'school-sma-01',
        tenantId: 'tenant-test-001',
        name: 'SMA Al-Hikmah Primary',
        institutionCode: 'SMA01',
        status: 'ACTIVE',
        address: 'Jl. Merdeka 10',
        contactEmail: 'sma01@ilmiya.edu',
        contactPhone: '08123456789',
        workingDays: const ['MONDAY', 'TUESDAY'],
        gradingPreference: 'PERCENTAGE',
        termLayout: 'SEMESTER',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];

    testWidgets(
        'IamScopesTab restricts campus admin: locks school dropdown, shows Campus Jailed badge, and disables Create Root Scope button',
        (WidgetTester tester) async {
      setUpViewport(tester);

      bool createTapped = false;

      await tester.pumpWidget(
        buildTestHost(
          IamScopesTab(
            scopes: [
              ScopeTreeNode(
                id: 'scope-root-sma',
                code: 'SMA01',
                name: 'SMA Al-Hikmah Primary Root',
                path: '/tenant-test-001/school-sma-01',
                depth: 0,
                children: [],
              ),
            ],
            schools: sampleSchools,
            tenantId: 'tenant-test-001',
            canCreateScope: true,
            canCreateRootScope: false,
            isTenantWideAdmin: false,
            lockedSchoolId: 'school-sma-01',
            onCreateRootScope: (_) => createTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campus Jailed'), findsOneWidget);
      expect(find.text('Assigned Campus:'), findsOneWidget);
      expect(find.text('Select School:'), findsNothing);

      final createBtn = find.byKey(const ValueKey('create_root_scope_btn'));
      expect(createBtn, findsOneWidget);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      expect(createTapped, isFalse);
    });

    testWidgets(
        'IamScopesTab renders badges, search filtering, expand/collapse, copy path, and deletion protection',
        (WidgetTester tester) async {
      setUpViewport(tester);

      ScopeTreeNode? deletedScope;

      final testScopes = [
        ScopeTreeNode(
          id: 'scope-tenant-root',
          code: 'ROOT',
          name: 'Global Tenant Root',
          path: '/tenant-test-001',
          depth: 0,
          children: [],
        ),
        ScopeTreeNode(
          id: 'scope-root-sma',
          code: 'SMA01',
          name: 'SMA Al-Hikmah Primary Root',
          path: '/tenant-test-001/school-sma-01',
          depth: 0,
          children: [
            ScopeTreeNode(
              id: 'scope-dept-cs',
              code: 'DEPT_CS',
              name: 'Computer Science Dept',
              path: '/tenant-test-001/school-sma-01/DEPT_CS',
              depth: 1,
              parentId: 'scope-root-sma',
              children: [
                ScopeTreeNode(
                  id: 'scope-lab-01',
                  code: 'LAB_01',
                  name: 'Lab 01',
                  path: '/tenant-test-001/school-sma-01/DEPT_CS/LAB_01',
                  depth: 2,
                  parentId: 'scope-dept-cs',
                  children: [],
                ),
              ],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestHost(
          IamScopesTab(
            scopes: testScopes,
            schools: sampleSchools,
            tenantId: 'tenant-test-001',
            canCreateScope: true,
            canDeleteScope: true,
            canCreateRootScope: true,
            isTenantWideAdmin: true,
            onDeleteScope: (s) => deletedScope = s,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Badges
      expect(find.text('TENANT ROOT'), findsOneWidget);
      expect(find.text('CAMPUS ANCHOR'), findsOneWidget);
      expect(find.text('L1'), findsOneWidget);
      expect(find.text('L2'), findsOneWidget);

      // Copy path button exists
      final copyBtn =
          find.byKey(const ValueKey('copy_scope_path_scope-root-sma'));
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();

      // Expand/Collapse
      expect(find.text('Computer Science Dept'), findsOneWidget);
      final toggleCollapseBtn =
          find.byKey(const ValueKey('toggle_collapse_scope-root-sma'));
      expect(toggleCollapseBtn, findsOneWidget);
      await tester.tap(toggleCollapseBtn);
      await tester.pumpAndSettle();

      // After collapse, child should be hidden
      expect(find.text('Computer Science Dept'), findsNothing);

      // Re-expand
      await tester.tap(toggleCollapseBtn);
      await tester.pumpAndSettle();
      expect(find.text('Computer Science Dept'), findsOneWidget);

      // Search Filtering
      final searchField = find.byKey(const ValueKey('scope_search_field'));
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Computer');
      await tester.pumpAndSettle();

      expect(find.text('Computer Science Dept'), findsOneWidget);
      expect(find.text('Global Tenant Root'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('Global Tenant Root'), findsOneWidget);

      // Deletion Protection: Campus anchor delete button is disabled
      final anchorDeleteBtn =
          find.byKey(const ValueKey('delete_scope_scope-root-sma'));
      expect(anchorDeleteBtn, findsOneWidget);
      await tester.tap(anchorDeleteBtn);
      await tester.pumpAndSettle();
      expect(deletedScope, isNull);

      // Deletion confirmation for node with children
      final childWithChildrenDeleteBtn =
          find.byKey(const ValueKey('delete_scope_scope-dept-cs'));
      expect(childWithChildrenDeleteBtn, findsOneWidget);
      await tester.tap(childWithChildrenDeleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delete Scope Hierarchy?'), findsOneWidget);
      expect(find.text('Delete Scope and Subtree'), findsOneWidget);

      // Confirm deletion in dialog
      await tester.tap(find.text('Delete Scope and Subtree'));
      await tester.pumpAndSettle();

      expect(deletedScope, isNotNull);
      expect(deletedScope!.id, equals('scope-dept-cs'));
    });

    testWidgets(
        'AssignRoleDialog lists campus anchor and nested child scopes with badges',
        (WidgetTester tester) async {
      setUpViewport(tester);

      final user = UserResponse(
        id: 'u-scope-select-test',
        email: 'scope.select@ilmiya.edu',
        fullName: 'Scope Select Tester',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final testRoles = [
        RoleResponse(
          id: 'role-teacher',
          tenantId: 'tenant-test-001',
          code: 'TEACHER',
          name: 'Teacher',
          description: '',
          permissions: [],
          isSystemRole: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      final testScopes = [
        ScopeTreeNode(
          id: 'scope-root-sma',
          code: 'SMA01',
          name: 'SMA Al-Hikmah Primary Root',
          path: '/tenant-test-001/school-sma-01',
          depth: 0,
          children: [
            ScopeTreeNode(
              id: 'scope-dept-cs',
              code: 'DEPT_CS',
              name: 'Computer Science Dept',
              path: '/tenant-test-001/school-sma-01/DEPT_CS',
              depth: 1,
              parentId: 'scope-root-sma',
              children: [],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestHost(
          AssignRoleDialog(
            user: user,
            roles: testRoles,
            scopes: testScopes,
            schools: sampleSchools,
            tenantId: 'tenant-test-001',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open target scope dropdown
      expect(find.text('Entire Tenant (Root Scope)'), findsOneWidget);
      await tester.tap(find.text('Entire Tenant (Root Scope)'));
      await tester.pumpAndSettle();

      // Verify Campus badge and child scope L1 badge exist in the dropdown
      expect(find.text('CAMPUS'), findsOneWidget);
      expect(find.text('L1'), findsOneWidget);
      expect(find.textContaining('SMA Al-Hikmah Primary Root'), findsWidgets);
      expect(find.textContaining('Computer Science Dept'), findsWidgets);

      // Select child scope
      await tester.tap(find.textContaining('Computer Science Dept').last);
      await tester.pumpAndSettle();

      // Scope is selected and closed field displays target scope
      expect(find.textContaining('Computer Science Dept'), findsOneWidget);
    });
  });
}
