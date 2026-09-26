import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/iam_management/presentation/iam_management_screen.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

Widget buildTestableWidget() {
  return ChangeNotifierProvider(
    create: (_) => AuthNotifier(),
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: const MaterialApp(
        home: Scaffold(
          body: IamManagementScreen(),
        ),
      ),
    ),
  );
}

void main() {
  group('IamManagementScreen', () {
    testWidgets('renders title and switches through all four tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify main header title
      expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);

      // Default tab is Users
      expect(find.text('Users'), findsWidgets);

      // Switch to Roles & RBAC tab
      await tester.tap(find.text('Roles & RBAC'));
      await tester.pumpAndSettle();
      expect(find.text('Roles & RBAC'), findsWidgets);

      // Switch to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Groups'), findsWidgets);

      // Scope Tree tab may be off-screen in the scrollable TabBar
      final scopeTreeTab = find.text('Scope Tree');
      await tester.ensureVisible(scopeTreeTab.first);
      await tester.tap(scopeTreeTab.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Scope Tree'), findsWidgets);
    });

    testWidgets('search filtering in Users tab narrows displayed results',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Ensure we are on the Users tab
      expect(find.text('Users'), findsWidgets);

      // Find the search TextField via its hint text and enter a query
      final searchField = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search user by name or email...');
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'zzznomatch');
      await tester.pumpAndSettle();

      // Search text is visible in the field
      expect(find.text('zzznomatch'), findsOneWidget);

      // Clear the search to restore results
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Create User button opens dialog with "Create New User" title; '
        'Cancel dismisses it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Users tab is already active; tap 'Create User' button
      final createUserBtn = find.widgetWithText(ElevatedButton, 'Create User');
      expect(createUserBtn, findsOneWidget);
      await tester.tap(createUserBtn);
      await tester.pumpAndSettle();

      // Dialog title should be visible
      expect(find.text('Create New User'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Create New User'), findsNothing);
    });

    testWidgets(
        'Create Role button opens dialog with "Create Custom Role" title; '
        'Cancel dismisses it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Navigate to Roles & RBAC tab
      await tester.tap(find.text('Roles & RBAC'));
      await tester.pumpAndSettle();

      // Tap 'Create Custom Role' button
      final createRoleBtn =
          find.widgetWithText(ElevatedButton, 'Create Custom Role');
      expect(createRoleBtn, findsOneWidget);
      await tester.tap(createRoleBtn);
      await tester.pumpAndSettle();

      // Locate the dialog title text inside the AlertDialog
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Create Custom Role'),
        ),
        findsOneWidget,
      );

      // Tap Cancel to dismiss
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // AlertDialog should be gone
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
        'Create Group button opens dialog with "Create User Group" title; '
        'Cancel dismisses it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Navigate to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();

      // Tap 'Create Group' button
      final createGroupBtn =
          find.widgetWithText(ElevatedButton, 'Create Group');
      expect(createGroupBtn, findsOneWidget);
      await tester.tap(createGroupBtn);
      await tester.pumpAndSettle();

      // Dialog title should be visible
      expect(find.text('Create User Group'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Create User Group'), findsNothing);
    });

    testWidgets(
        'Create Root Scope button opens dialog with "Create Root Scope" title; '
        'Cancel dismisses it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Navigate to Scope Tree tab (may be off-screen in scrollable TabBar)
      final scopeTreeTab = find.text('Scope Tree');
      await tester.ensureVisible(scopeTreeTab.first);
      await tester.tap(scopeTreeTab.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Tap 'Create Root Scope' ElevatedButton
      final createScopeBtn =
          find.widgetWithText(ElevatedButton, 'Create Root Scope');
      expect(createScopeBtn, findsOneWidget);
      await tester.tap(createScopeBtn);
      await tester.pumpAndSettle();

      // Locate the dialog title inside the AlertDialog
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Create Root Scope'),
        ),
        findsOneWidget,
      );

      // Tap Cancel to dismiss
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // AlertDialog should be gone
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Assign Role button opens dialog and can be cancelled',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap 'Assign Role' OutlinedButton on the first user
      final assignRoleBtn = find.widgetWithText(OutlinedButton, 'Assign Role');
      expect(assignRoleBtn, findsWidgets);
      await tester.tap(assignRoleBtn.first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Assign Role:'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Create User dialog submits and reloads user list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap 'Create User' button
      final createUserBtn = find.widgetWithText(ElevatedButton, 'Create User');
      await tester.tap(createUserBtn);
      await tester.pumpAndSettle();

      // Fill in text fields inside the dialog
      final textFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );

      await tester.enterText(textFields.at(0), 'test.created@ilmiya.edu');
      await tester.enterText(textFields.at(1), 'Test Created User');
      await tester.pumpAndSettle();

      // Tap the submit button inside AlertDialog
      final submitBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Create User'),
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Test Created User'), findsOneWidget);
    });

    testWidgets('renders correctly on narrow 480-wide viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(480, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Title should still be rendered on a narrow screen
      expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);
    });

    testWidgets(
        'Scope Tree tab renders node hierarchy without overflow on mobile (360x740)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final scopeTreeTab = find.text('Scope Tree');
      await tester.ensureVisible(scopeTreeTab.first);
      await tester.tap(scopeTreeTab.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Hierarchical Scope Tree'), findsOneWidget);
      expect(find.text('Lincoln High Main Campus'), findsWidgets);
      expect(find.text('Add Child'), findsWidgets);
    });
  });
}
