import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/assign_role_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/create_group_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/create_role_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/create_scope_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/create_user_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/edit_scope_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/edit_user_dialog.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/manage_group_dialog.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

Widget wrapWithTheme(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => AuthNotifier(),
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    apiClient.isMockMode = true;
    mockStorageService.reset();
  });

  group('ManageGroupDialog Tests', () {
    late GroupResponse sampleGroup;
    late List<UserResponse> sampleUsers;
    late List<RoleResponse> sampleRoles;
    late List<ScopeTreeNode> sampleScopes;

    setUp(() {
      sampleGroup = mockStorageService.createGroup(
        DEFAULT_TENANT_ID,
        CreateGroupRequest(
          tenantId: DEFAULT_TENANT_ID,
          code: 'MATH_DEPT',
          name: 'Mathematics Department',
          description: 'Faculty of Math',
          externalIdpGroupName: 'idp-math',
        ),
      );

      sampleUsers = mockStorageService.listUsers();
      sampleRoles = mockStorageService.listRoles(DEFAULT_TENANT_ID);
      sampleScopes = mockStorageService.getScopeTree(DEFAULT_TENANT_ID);
    });

    testWidgets('ManageGroupDialog renders and updates settings tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool groupChanged = false;

      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ManageGroupDialog.show(
                ctx,
                group: sampleGroup,
                allUsers: sampleUsers,
                allRoles: sampleRoles,
                allScopes: sampleScopes,
                onGroupChanged: () => groupChanged = true,
              ),
              child: const Text('Open Manage Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Manage Dialog'));
      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('Mathematics Department'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.textContaining('Members'), findsWidgets);
      expect(find.textContaining('Roles'), findsWidgets);

      // Edit name in Settings tab
      final nameField =
          find.widgetWithText(TextFormField, 'Mathematics Department');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Math & Stats Department');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(groupChanged, isTrue);
    });

    testWidgets('ManageGroupDialog switches to Members and Roles tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool groupChanged = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ManageGroupDialog(
            group: sampleGroup,
            allUsers: sampleUsers,
            allRoles: sampleRoles,
            allScopes: sampleScopes,
            onGroupChanged: () => groupChanged = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Members tab
      final membersTab = find.textContaining('Members');
      await tester.tap(membersTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Select User to Include in Group'), findsOneWidget);

      // Select a user from dropdown and add
      await tester.tap(find.text('Select User to Include in Group'));
      await tester.pumpAndSettle();

      final firstDropdownUser = find.byType(DropdownMenuItem<String>);
      if (firstDropdownUser.evaluate().isNotEmpty) {
        await tester.tap(firstDropdownUser.last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Member'));
        await tester.pumpAndSettle();
        expect(groupChanged, isTrue);
      }

      // Switch to Roles & Scopes tab
      final rolesTab = find.textContaining('Roles');
      await tester.tap(rolesTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Role to Attach'), findsOneWidget);

      // Select a role from dropdown and attach
      await tester.tap(find.text('Role to Attach'));
      await tester.pumpAndSettle();

      final firstDropdownRole = find.byType(DropdownMenuItem<String>);
      if (firstDropdownRole.evaluate().isNotEmpty) {
        await tester.tap(firstDropdownRole.last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Attach'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('ManageGroupDialog delete confirmation flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithTheme(
          ManageGroupDialog(
            group: sampleGroup,
            allUsers: sampleUsers,
            allRoles: sampleRoles,
            allScopes: sampleScopes,
            onGroupChanged: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Delete Group button (red outlined button)
      final deleteGroupBtn = find.text('Delete Group');
      expect(deleteGroupBtn, findsOneWidget);
      await tester.tap(deleteGroupBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Group'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);

      // Dismiss via Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('AssignRoleDialog Tests', () {
    late UserResponse sampleUser;
    late List<RoleResponse> sampleRoles;

    setUp(() {
      sampleUser = mockStorageService.listUsers().first;
      sampleRoles = mockStorageService.listRoles(DEFAULT_TENANT_ID);
    });

    testWidgets('AssignRoleDialog renders, selects scope, and submits',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool assigned = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AssignRoleDialog(
            user: sampleUser,
            roles: sampleRoles,
            scopes: [
              ScopeTreeNode(
                id: 'sc-1',
                code: 'CAMPUS',
                name: 'Main Campus',
                path: '/CAMPUS',
                depth: 0,
                children: [],
              ),
            ],
            onRoleAssigned: () => assigned = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assign Role & Scope: ${sampleUser.fullName}'),
          findsOneWidget);

      // Select Scope
      expect(find.text('Entire Tenant (Root Scope)'), findsOneWidget);
      await tester.tap(find.text('Entire Tenant (Root Scope)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Main Campus (/CAMPUS)').last);
      await tester.pumpAndSettle();

      // Tap Assign Role & Scope
      await tester
          .tap(find.widgetWithText(ElevatedButton, 'Assign Role & Scope'));
      await tester.pumpAndSettle();

      expect(assigned, isTrue);
    });

    testWidgets('AssignRoleDialog.show returns early when roles list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => AssignRoleDialog.show(
                ctx,
                user: sampleUser,
                roles: [],
              ),
              child: const Text('Open Empty'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Empty'));
      await tester.pumpAndSettle();

      expect(find.byType(AssignRoleDialog), findsNothing);
    });
  });

  group('CreateGroupDialog Tests', () {
    testWidgets('CreateGroupDialog validates input and creates group',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool created = false;

      await tester.pumpWidget(
        wrapWithTheme(
          CreateGroupDialog(
            onGroupCreated: () async => created = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create User Group'), findsOneWidget);

      // Attempt submit without filling
      await tester.tap(find.text('Save Group'));
      await tester.pumpAndSettle();

      expect(find.text('Group code is required'), findsOneWidget);

      // Fill form
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'SCIENCE_CLUB');
      await tester.enterText(textFields.at(1), 'Science Club');
      await tester.enterText(textFields.at(2), 'STEM Enthusiasts');
      await tester.enterText(textFields.at(3), 'idp-stem');

      await tester.tap(find.text('Save Group'));
      await tester.pumpAndSettle();

      expect(created, isTrue);
    });
  });

  group('CreateScopeDialog Tests', () {
    testWidgets('CreateScopeDialog validates input and creates scope',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool created = false;

      await tester.pumpWidget(
        wrapWithTheme(
          CreateScopeDialog(
            parentId: 'parent-01',
            onScopeCreated: () async => created = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Custom Scope'), findsOneWidget);

      // Attempt submit without filling
      await tester.tap(find.text('Save Scope'));
      await tester.pumpAndSettle();

      expect(find.text('Scope code is required'), findsOneWidget);

      // Fill form
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'LAB_101');
      await tester.enterText(textFields.at(1), 'Physics Lab 101');

      await tester.tap(find.text('Save Scope'));
      await tester.pumpAndSettle();

      expect(created, isTrue);
    });
  });

  group('CreateUserDialog Tests', () {
    testWidgets('CreateUserDialog validates input and creates user',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool created = false;

      await tester.pumpWidget(
        wrapWithTheme(
          CreateUserDialog(
            onUserCreated: () async => created = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New User'), findsOneWidget);

      // Attempt submit without filling
      await tester.tap(find.text('Create User'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      // Fill form with valid fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'fresh.user@ilmiya.edu');
      await tester.enterText(textFields.at(1), 'Fresh User');
      await tester.enterText(textFields.at(2), 'Pass1234!');

      await tester.tap(find.text('Create User'));
      await tester.pumpAndSettle();

      expect(created, isTrue);
    });
  });

  group('CreateRoleDialog Tests', () {
    testWidgets('CreateRoleDialog toggles permissions and creates custom role',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool created = false;

      await tester.pumpWidget(
        wrapWithTheme(
          CreateRoleDialog(
            onRoleCreated: () async => created = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Custom Role'), findsOneWidget);

      // Fill role code and name
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'DEPT_COORDINATOR');
      await tester.enterText(textFields.at(1), 'Department Coordinator');

      // Select All in the first category
      final selectAllBtn = find.text('Select All');
      expect(selectAllBtn, findsWidgets);
      await tester.tap(selectAllBtn.first);
      await tester.pumpAndSettle();

      // Submit role creation by tapping the ElevatedButton labeled Create Role
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Role'));
      await tester.pumpAndSettle();

      expect(created, isTrue);
    });
  });

  group('EditUserDialog Tests', () {
    testWidgets('EditUserDialog renders and updates user name',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final user = mockStorageService.listUsers().first;
      bool updated = false;

      await tester.pumpWidget(
        wrapWithTheme(
          EditUserDialog(
            user: user,
            onUserUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Edit User:'), findsOneWidget);
      expect(find.text(user.email), findsOneWidget);

      final nameField = find.widgetWithText(TextFormField, user.fullName);
      await tester.enterText(nameField, 'Updated User Name');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets('EditUserDialog validates password match and resets password',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final user = mockStorageService.listUsers().first;
      bool updated = false;

      await tester.pumpWidget(
        wrapWithTheme(
          EditUserDialog(
            user: user,
            onUserUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      // textFields.at(0) is Email Address (read-only)
      // textFields.at(1) is Full Name
      // textFields.at(2) is New Password
      // textFields.at(3) is Confirm Password
      await tester.enterText(textFields.at(2), 'NewPass123!');
      await tester.enterText(textFields.at(3), 'DifferentPass!');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(updated, isFalse);

      // Now match passwords
      await tester.enterText(textFields.at(3), 'NewPass123!');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });
  });

  group('EditScopeDialog Tests', () {
    testWidgets('EditScopeDialog populates existing data and updates scope',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final parentScope = ScopeTreeNode(
        id: 'scope-parent-1',
        code: 'CAMPUS_A',
        name: 'Campus A',
        path: '/tenant-1/CAMPUS_A',
        depth: 0,
        children: [],
      );

      final alternativeParent = ScopeTreeNode(
        id: 'scope-parent-2',
        code: 'CAMPUS_B',
        name: 'Campus B',
        path: '/tenant-1/CAMPUS_B',
        depth: 0,
        children: [],
      );

      final scope = ScopeTreeNode(
        id: 'scope-test-1',
        code: 'OLD_CODE',
        name: 'Old Scope Name',
        path: '/tenant-1/CAMPUS_A/OLD_CODE',
        depth: 1,
        parentId: 'scope-parent-1',
        children: [],
      );

      bool updated = false;

      await tester.pumpWidget(
        wrapWithTheme(
          EditScopeDialog(
            scope: scope,
            allScopes: [parentScope, alternativeParent],
            tenantId: DEFAULT_TENANT_ID,
            onScopeUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit & Reparent Scope'), findsOneWidget);
      expect(find.text('ID: scope-test-1'), findsOneWidget);
      expect(find.text('/tenant-1/CAMPUS_A/OLD_CODE'), findsOneWidget);

      final codeField = find.byKey(const ValueKey('edit_scope_code_field'));
      final nameField = find.byKey(const ValueKey('edit_scope_name_field'));
      expect(codeField, findsOneWidget);
      expect(nameField, findsOneWidget);

      // Reparent to alternative parent
      final parentDropdown =
          find.byKey(const ValueKey('edit_scope_parent_dropdown'));
      expect(parentDropdown, findsOneWidget);
      await tester.tap(parentDropdown);
      await tester.pumpAndSettle();

      expect(find.textContaining('Campus B'), findsWidgets);
      await tester.tap(find.textContaining('Campus B').last);
      await tester.pumpAndSettle();

      await tester.enterText(codeField, 'NEW_CODE');
      await tester.enterText(nameField, 'New Scope Name');
      await tester.pumpAndSettle();

      // Check preview path updated to Campus B
      expect(find.text('/tenant-1/CAMPUS_B/NEW_CODE'), findsOneWidget);

      final submitBtn = find.byKey(const ValueKey('edit_scope_submit_btn'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets('EditScopeDialog validates empty code or name',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final scope = ScopeTreeNode(
        id: 'scope-test-2',
        code: 'VALID_CODE',
        name: 'Valid Name',
        path: '/tenant-1/VALID_CODE',
        depth: 1,
        children: [],
      );

      bool updated = false;

      await tester.pumpWidget(
        wrapWithTheme(
          EditScopeDialog(
            scope: scope,
            tenantId: DEFAULT_TENANT_ID,
            onScopeUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final codeField = find.byKey(const ValueKey('edit_scope_code_field'));
      final nameField = find.byKey(const ValueKey('edit_scope_name_field'));

      await tester.enterText(codeField, '');
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const ValueKey('edit_scope_submit_btn'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Scope code is required'), findsOneWidget);
      expect(find.text('Scope name is required'), findsOneWidget);
      expect(updated, isFalse);
    });

    testWidgets(
        'EditScopeDialog allows reparenting root scope under another node',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final rootA = ScopeTreeNode(
        id: 'scope-root-a',
        code: 'ROOT_A',
        name: 'Root Scope A',
        path: '/tenant-1/scope-root-a/',
        depth: 0,
        children: [],
      );

      final rootB = ScopeTreeNode(
        id: 'scope-root-b',
        code: 'ROOT_B',
        name: 'Root Scope B',
        path: '/tenant-1/scope-root-b/',
        depth: 0,
        children: [],
      );

      bool updated = false;

      await tester.pumpWidget(
        wrapWithTheme(
          EditScopeDialog(
            scope: rootA,
            allScopes: [rootA, rootB],
            tenantId: DEFAULT_TENANT_ID,
            onScopeUpdated: () async => updated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final parentDropdown =
          find.byKey(const ValueKey('edit_scope_parent_dropdown'));
      expect(parentDropdown, findsOneWidget);

      await tester.tap(parentDropdown);
      await tester.pumpAndSettle();

      expect(find.textContaining('Root Scope B'), findsWidgets);
      await tester.tap(find.textContaining('Root Scope B').last);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const ValueKey('edit_scope_submit_btn'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets(
        'EditScopeDialog shows informative banner when no candidate parents exist',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final rootA = ScopeTreeNode(
        id: 'scope-root-a',
        code: 'ROOT_A',
        name: 'Root Scope A',
        path: '/tenant-1/scope-root-a/',
        depth: 0,
        children: [],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          EditScopeDialog(
            scope: rootA,
            allScopes: [rootA],
            tenantId: DEFAULT_TENANT_ID,
            onScopeUpdated: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
            'No eligible parent scopes available to move under in current scope boundary.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('edit_scope_parent_dropdown')),
          findsNothing);
    });
  });
}
