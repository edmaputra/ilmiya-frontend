import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/features/search/ilmiya_command_palette.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  testWidgets(
      'IlmiyaCommandPalette renders, filters commands, and selects action',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    final client = ApiClient();
    client.isMockMode = true;
    final storage = MockStorageService();
    final iam = IamService(apiClient: client, mockStorage: storage);
    final auth = AuthNotifier(iamService: iam, apiClient: client);

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );

    // Open palette
    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    expect(find.byType(IlmiyaCommandPalette), findsOneWidget);
    expect(find.text('School Profile'), findsOneWidget);

    // Enter a search query
    await tester.enterText(find.byType(TextField), 'Academic Years');
    await tester.pumpAndSettle();

    expect(find.text('Academic Years & Terms'), findsOneWidget);

    // Tap the filtered item
    await tester.tap(find.text('Academic Years & Terms'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and tab switched to 1
    expect(find.byType(IlmiyaCommandPalette), findsNothing);
    expect(appState.currentTab, equals(1));
  });

  testWidgets('IlmiyaCommandPalette empty search results display placeholder',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    final client = ApiClient();
    client.isMockMode = true;
    final storage = MockStorageService();
    final iam = IamService(apiClient: client, mockStorage: storage);
    final auth = AuthNotifier(iamService: iam, apiClient: client);

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );

    await tester.tap(find.text('Open Palette'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField), 'NonExistentActionString123');
    await tester.pumpAndSettle();

    expect(find.text('No matching commands found'), findsOneWidget);
  });
}
