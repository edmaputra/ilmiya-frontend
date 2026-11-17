import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/iam_management/dialogs/assign_role_dialog.dart';
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

  group('AssignRoleDialog Batch Endpoint Tests', () {
    late UserResponse sampleUser;
    late List<RoleResponse> sampleRoles;
    late List<ScopeTreeNode> sampleScopes;

    setUp(() {
      sampleUser = mockStorageService.listUsers().first;
      sampleRoles = [
        RoleResponse(
          id: 'role-teacher',
          tenantId: DEFAULT_TENANT_ID,
          code: 'TEACHER',
          name: 'Teacher',
          isSystemRole: false,
          permissions: ['grade:write'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        RoleResponse(
          id: 'role-proctor',
          tenantId: DEFAULT_TENANT_ID,
          code: 'PROCTOR',
          name: 'Exam Proctor',
          isSystemRole: false,
          permissions: ['exam:proctor'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        RoleResponse(
          id: 'role-head',
          tenantId: DEFAULT_TENANT_ID,
          code: 'DEPT_HEAD',
          name: 'Department Head',
          isSystemRole: false,
          permissions: ['dept:manage'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
      sampleScopes = [
        ScopeTreeNode(
          id: 'sc-campus',
          code: 'CAMPUS',
          name: 'Main Campus',
          path: '/CAMPUS',
          depth: 0,
          children: [
            ScopeTreeNode(
              id: 'sc-science',
              code: 'SCIENCE',
              name: 'Science Dept',
              path: '/CAMPUS/SCIENCE',
              depth: 1,
              children: [],
            ),
          ],
        ),
      ];
    });

    testWidgets('renders batch role assignment UI and tag',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithTheme(
          AssignRoleDialog(
            user: sampleUser,
            roles: sampleRoles,
            scopes: sampleScopes,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Batch Role Assignment'), findsOneWidget);
      expect(find.text('POST /roles/batch'), findsOneWidget);
      expect(find.text('Add to Batch'), findsOneWidget);
      expect(find.text('Assign Role & Scope'), findsOneWidget);
      expect(find.text('Teacher'), findsWidgets);
      expect(find.text('Exam Proctor'), findsWidgets);
    });

    testWidgets('stages multiple roles into queue and submits batch endpoint',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool assignedTriggered = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AssignRoleDialog(
            user: sampleUser,
            roles: sampleRoles,
            scopes: sampleScopes,
            onRoleAssigned: () => assignedTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Add to Batch" to stage the first role (Teacher at Entire Tenant)
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Staged for Batch (1)'), findsOneWidget);
      expect(find.text('Assign 1 Roles (Batch)'), findsOneWidget);

      // Select Exam Proctor by tapping the chip
      await tester.tap(find.widgetWithText(ActionChip, 'Exam Proctor'));
      await tester.pumpAndSettle();

      // Select Scope 'Science Dept (/CAMPUS/SCIENCE)'
      await tester.tap(find.text('Entire Tenant (Root Scope)').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Science Dept').last);
      await tester.pumpAndSettle();

      // Stage the second role
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Staged for Batch (2)'), findsOneWidget);
      expect(find.text('Assign 2 Roles (Batch)'), findsOneWidget);

      // Submit the batch!
      final submitBtn =
          find.widgetWithText(ElevatedButton, 'Assign 2 Roles (Batch)');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(assignedTriggered, isTrue);

      // Verify that user now has both roles
      final roles = mockStorageService.getUserRoles(sampleUser.id);
      expect(roles.any((r) => r.roleId == 'role-teacher'), isTrue);
      expect(roles.any((r) => r.roleId == 'role-proctor'), isTrue);
    });

    testWidgets('unstage item and clear queue work as expected',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithTheme(
          AssignRoleDialog(
            user: sampleUser,
            roles: sampleRoles,
            scopes: sampleScopes,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Stage Teacher
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Staged for Batch (1)'), findsOneWidget);

      // Stage Department Head
      await tester.tap(find.widgetWithText(ActionChip, 'Department Head'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Staged for Batch (2)'), findsOneWidget);

      // Unstage first item
      final removeButtons = find.byIcon(LucideIcons.x);
      expect(removeButtons, findsWidgets);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Staged for Batch (1)'), findsOneWidget);

      // Clear remaining queue
      await tester.tap(find.text('Clear Queue'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Staged for Batch'), findsNothing);
      expect(find.text('Assign Role & Scope'), findsOneWidget);
    });

    testWidgets('duplicate prevention blocks adding same role & scope twice',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithTheme(
          AssignRoleDialog(
            user: sampleUser,
            roles: sampleRoles,
            scopes: sampleScopes,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Stage Teacher once
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Staged for Batch (1)'), findsOneWidget);

      // Try staging Teacher again at same scope
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Batch'));
      await tester.pumpAndSettle();

      // Still only 1 item in batch
      expect(find.textContaining('Staged for Batch (1)'), findsOneWidget);
    });
  });
}
