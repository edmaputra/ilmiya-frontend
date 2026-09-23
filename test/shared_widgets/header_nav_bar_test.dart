import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/shared_widgets/header_nav_bar.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

Widget _buildHeaderHost({
  required AppState appState,
  required AuthNotifier auth,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: appState),
      ChangeNotifierProvider<AuthNotifier>.value(value: auth),
    ],
    child: ShadTheme(
      data: AppTheme.shadLightTheme,
      child: const MaterialApp(
        home: Scaffold(
          appBar: HeaderNavBar(),
          body: SizedBox.expand(),
        ),
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
  testWidgets('HeaderNavBar renders brand logo and title on desktop',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    expect(find.byType(HeaderNavBar), findsOneWidget);
    expect(find.text('Ilmiya'), findsOneWidget);
    expect(find.text('SIS'), findsOneWidget);
  });

  testWidgets('HeaderNavBar switches tabs via nav pills',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Nav pills: School Profile, Academic Years, IAM Console, Feature Previews
    expect(find.text('School Profile'), findsOneWidget);
    expect(find.text('Academic Years'), findsOneWidget);

    await tester.tap(find.text('Academic Years'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(1));

    await tester.tap(find.text('IAM Console'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(2));

    await tester.tap(find.text('Feature Previews'));
    await tester.pumpAndSettle();
    expect(appState.currentTab, equals(3));
  });

  testWidgets('HeaderNavBar toggles mock / live API mode button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    final modeFinder = find.text('Mock Simulation');
    expect(modeFinder, findsOneWidget);

    await tester.tap(modeFinder);
    await tester.pumpAndSettle();

    expect(find.text('Live REST API'), findsOneWidget);

    // Toggle back
    await tester.tap(find.text('Live REST API'));
    await tester.pumpAndSettle();
    expect(find.text('Mock Simulation'), findsOneWidget);
  });

  testWidgets('HeaderNavBar opens tenant switcher dialog and switches tenant',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Tap the tenant badge
    await tester.tap(find.byIcon(Icons.domain_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Switch Multi-Tenant Context'), findsOneWidget);

    // Dismiss dialog via Cancel button
    final cancelButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Cancel'),
    );
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('HeaderNavBar opens persona switcher menu',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    // Tap account/persona avatar button
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('1-CLICK PERSONAS (RBAC)'), findsOneWidget);
    expect(find.text('Sign In with Custom Credentials...'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Select Sign Out
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(auth.isAuthenticated, isFalse);
  });

  testWidgets('HeaderNavBar renders in mobile viewport (compact layout)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = _makeAppState();
    final auth = _makeAuth();

    await tester.pumpWidget(_buildHeaderHost(appState: appState, auth: auth));
    await tester.pumpAndSettle();

    expect(find.byType(HeaderNavBar), findsOneWidget);
    expect(find.text('Ilmiya'), findsOneWidget);
  });
}
