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

      expect(find.text('Assign Role: ${sampleUser.fullName}'), findsOneWidget);

      // Select Scope
      expect(find.text('Entire Tenant (Root Scope)'), findsOneWidget);
      await tester.tap(find.text('Entire Tenant (Root Scope)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Main Campus (/CAMPUS)').last);
      await tester.pumpAndSettle();

      // Tap Assign Role
      await tester.tap(find.widgetWithText(ElevatedButton, 'Assign Role'));
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

      expect(find.text('Add Child Scope'), findsOneWidget);

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
}
