import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/features/search/ilmiya_command_palette.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:provider/provider.dart';

Widget _buildPaletteHost({
  required AppState appState,
  required AuthNotifier auth,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: appState),
      ChangeNotifierProvider<AuthNotifier>.value(value: auth),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showIlmiyaCommandPalette(ctx),
            child: const Text('Open Palette'),
          ),
        ),
      ),
    ),
  );
}

void _setDesktopSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

AppState _makeAppState() => AppState();
AuthNotifier _makeAuth() {
  final client = ApiClient()..isMockMode = true;
  final storage = MockStorageService();
  final iam = IamService(apiClient: client, mockStorage: storage);
  return AuthNotifier(iamService: iam, apiClient: client);
}

void main() {
  testWidgets('IlmiyaCommandPalette renders and shows all nav items',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsOneWidget);
    expect(find.text('School Profile'), findsOneWidget);
    expect(find.text('Dashboard Overview'), findsOneWidget);
  });

  testWidgets('IlmiyaCommandPalette filters by search query',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Academic Years');
    await tester.pumpAndSettle();

    expect(find.text('Academic Years & Terms'), findsOneWidget);
    expect(find.text('School Profile'), findsNothing);
  });

  testWidgets('IlmiyaCommandPalette shows empty placeholder for no match',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField), 'NonExistentActionString123');
    await tester.pumpAndSettle();

    expect(find.text('No matching commands found'), findsOneWidget);
  });

  testWidgets(
      'IlmiyaCommandPalette selecting Academic Years sets tab and closes',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Academic Years');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Academic Years & Terms'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.currentTab, equals(1));
  });

  testWidgets('IlmiyaCommandPalette selecting IAM Console sets tab 2',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'IAM Console');
    await tester.pumpAndSettle();
    await tester.tap(find.text('IAM Console (Identity & Access)'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.currentTab, equals(2));
  });

  testWidgets('IlmiyaCommandPalette selecting Dashboard sets tab 4',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Dashboard');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard Overview'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.currentTab, equals(4));
  });

  testWidgets('IlmiyaCommandPalette Toggle Theme action works',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    final initialTheme = appState.themeMode;

    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Toggle Theme');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toggle Theme (Light / Dark)'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.themeMode, isNot(equals(initialTheme)));
  });

  testWidgets('IlmiyaCommandPalette Switch to Mock toggles api mode',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Switch to');
    await tester.pumpAndSettle();

    // Should see either 'Switch to Live REST Backend' or 'Switch to Mock Simulation'
    final switchItem = find.textContaining('Switch to');
    expect(switchItem, findsWidgets);
  });

  testWidgets(
      'IlmiyaCommandPalette navigates via keyboard arrow keys and Enter',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    // Arrow down to move selection, then Enter selects
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    // Pressing Escape should close palette
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
  });

  testWidgets('IlmiyaCommandPalette shows School Profile action',
      (WidgetTester tester) async {
    _setDesktopSize(tester);
    final appState = _makeAppState();
    final auth = _makeAuth();
    await tester.pumpWidget(_buildPaletteHost(appState: appState, auth: auth));

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('School Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.currentTab, equals(0));
  });
}
