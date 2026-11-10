import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/search/ilmiya_command_palette.dart';
import 'package:ilmiya_app/shared_widgets/ilmiya_app_shell.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

Widget _buildShellHost({
  required AppState appState,
  required AuthNotifier auth,
  Widget body = const Text('Main Body Content'),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: appState),
      ChangeNotifierProvider<AuthNotifier>.value(value: auth),
    ],
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: MaterialApp(
        home: IlmiyaAppShell(body: body),
      ),
    ),
  );
}

AppState _makeAppState() => AppState();
AuthNotifier _makeAuth() {
  final client = ApiClient()..isMockMode = true;
  final storage = MockStorageService();
  final iam = IamService(apiClient: client, mockStorage: storage);
  return AuthNotifier(iamService: iam, apiClient: client);
}

void main() {
  testWidgets('IlmiyaAppShell renders desktop sidebar, top bar, and body',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaAppShell), findsOneWidget);
    expect(find.text('Main Body Content'), findsOneWidget);
    expect(find.text('School Information System'), findsOneWidget);
    expect(find.text('INSTITUTION & CONTROL'), findsOneWidget);
  });

  testWidgets('IlmiyaAppShell sidebar switches tabs on nav tile tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Tap Academic Years (tab 1)
    await tester.tap(find.text('Academic Years'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(1));

    // Tap Executive Dashboard (tab 4)
    await tester.tap(find.text('Executive Dashboard'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(4));

    // Tap IAM Console (tab 2)
    await tester.tap(find.text('IAM Console'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(2));
  });

  testWidgets('IlmiyaAppShell top bar buttons trigger actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();
    final initialTheme = appState.themeMode;

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Theme toggle button in top bar
    final themeToggleFinder = find.byTooltip('Dark Mode');
    if (themeToggleFinder.evaluate().isNotEmpty) {
      await tester.tap(themeToggleFinder);
      await tester.pumpAndSettle();
      expect(appState.themeMode, isNot(equals(initialTheme)));
    }

    // Notifications button in top bar
    final notifsBtn = find.byTooltip('Notifications');
    if (notifsBtn.evaluate().isNotEmpty) {
      await tester.tap(notifsBtn);
      await tester.pumpAndSettle();
      expect(appState.currentTab, equals(7));
    }
  });

  testWidgets('IlmiyaAppShell search bar opens command palette',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Search bar container in desktop top bar
    final searchTrigger = find.text('Search... ⌘K');
    expect(searchTrigger, findsOneWidget);

    await tester.tap(searchTrigger);
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsOneWidget);

    // Press Escape to dismiss
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });

  testWidgets('IlmiyaAppShell renders mobile layout with bottom navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);

    // Tap destination in NavigationBar
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(1));
  });

  testWidgets(
      'IlmiyaAppShell sidebar displays startup mode badge and switches tenant',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildShellHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Mode status badge in sidebar footer
    final mockBadge = find.text('Mock Simulation');
    expect(mockBadge, findsOneWidget);

    // Open tenant dialog in sidebar
    final tenantSelector = find.text(auth.schoolName);
    expect(tenantSelector, findsWidgets);

    await tester.tap(tenantSelector.first);
    await tester.pumpAndSettle();

    expect(find.text('Switch School Tenant'), findsOneWidget);

    // Cancel tenant dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Switch School Tenant'), findsNothing);
  });
}
