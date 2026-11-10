import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/iam_management/widgets/iam_access_restricted_view.dart';
import 'package:ilmiya_app/features/iam_management/widgets/iam_roles_tab.dart';
import 'package:ilmiya_app/features/iam_management/widgets/iam_user_tile.dart';
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

  group('IamAccessRestrictedView Tests', () {
    testWidgets('IamAccessRestrictedView renders restricted state with roles',
        (WidgetTester tester) async {
      final auth = AuthNotifier();

      await tester.pumpWidget(
        wrapWithTheme(
          IamAccessRestrictedView(auth: auth),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IAM Console Restricted'), findsOneWidget);
      expect(
          find.textContaining('Identity & Access Management console requires'),
          findsOneWidget);
    });
  });

  group('IamUserTile Tests', () {
    late UserResponse sampleUser;

    setUp(() {
      sampleUser = mockStorageService.listUsers().first;
    });

    testWidgets('IamUserTile renders desktop layout, triggers actions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool reloaded = false;
      bool assigned = false;

      await tester.pumpWidget(
        wrapWithTheme(
          IamUserTile(
            user: sampleUser,
            canAssign: true,
            canUpdateStatus: true,
            canDelete: true,
            onAssignRole: (u) => assigned = true,
            onDataReload: () async => reloaded = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(sampleUser.fullName), findsWidgets);
      expect(find.text(sampleUser.email), findsWidgets);

      // Status dropdown change
      await tester.tap(find.text('ACTIVE'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SUSPENDED').last);
      await tester.pumpAndSettle();

      expect(reloaded, isTrue);

      // Assign Role button
      await tester.tap(find.text('Assign Role'));
      await tester.pumpAndSettle();
      expect(assigned, isTrue);

      // Delete user
      final trashBtn = find.byIcon(LucideIcons.trash2).first;
      await tester.tap(trashBtn, warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('IamUserTile renders mobile layout (< 600px width)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithTheme(
          IamUserTile(
            user: sampleUser,
            canAssign: true,
            canUpdateStatus: true,
            canDelete: true,
            onAssignRole: (_) {},
            onDataReload: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(sampleUser.fullName), findsWidgets);
    });
  });

  group('IamRolesTab Tests', () {
    final sampleRoles = [
      RoleResponse(
        id: 'r-sys-1',
        tenantId: 't-1',
        code: 'SUPERADMIN',
        name: 'Super Administrator',
        permissions: ['*'],
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      RoleResponse(
        id: 'r-cust-1',
        tenantId: 't-1',
        code: 'TEACHER',
        name: 'Teacher Role',
        permissions: ['grades:read', 'attendance:read', 'school:profile:read'],
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ];

    testWidgets(
        'IamRolesTab filters by search and chip, and inspects permissions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool createRoleCalled = false;

      await tester.pumpWidget(
        wrapWithTheme(
          IamRolesTab(
            roles: sampleRoles,
            canCreateRole: true,
            onCreateRole: () => createRoleCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Super Administrator'), findsOneWidget);
      expect(find.text('Teacher Role'), findsOneWidget);

      // Test Search query filter
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Teacher');
      await tester.pumpAndSettle();

      expect(find.text('Teacher Role'), findsOneWidget);
      expect(find.text('Super Administrator'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Filter chip System
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      // Filter chip All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Open Inspect Permissions Dialog
      final viewPermsBtn = find.text('1 Perms').first;
      await tester.tap(viewPermsBtn);
      await tester.pumpAndSettle();

      expect(find.text('Code: SUPERADMIN • 1 permissions configured'),
          findsOneWidget);

      // Close Dialog
      final closeBtn = find.byIcon(LucideIcons.x).first;
      await tester.tap(closeBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Tap Create Custom Role button
      await tester.tap(find.text('Create Custom Role'));
      await tester.pumpAndSettle();
      expect(createRoleCalled, isTrue);
    });
  });
}
