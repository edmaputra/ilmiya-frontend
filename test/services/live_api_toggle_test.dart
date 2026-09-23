import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/shared_widgets/header_nav_bar.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  group('Live API Toggle & Reactivity Tests', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient();
      client.isMockMode = true;
    });

    tearDown(() {
      client.isMockMode = true;
    });

    test('ApiClient.toggleMockMode flips state and notifies listeners', () {
      var notified = false;
      client.addListener(() {
        notified = true;
      });

      expect(client.isMockMode, isTrue);
      client.toggleMockMode();
      expect(client.isMockMode, isFalse);
      expect(notified, isTrue);

      notified = false;
      client.toggleMockMode();
      expect(client.isMockMode, isTrue);
      expect(notified, isTrue);
    });

    test('AuthNotifier reacts to ApiClient mode changes', () async {
      final auth = AuthNotifier(apiClient: client);
      await auth.refreshProfile();
      expect(auth.isAuthenticated, isTrue);

      // Switch to live mode without token
      client.token = null;
      client.isMockMode = false;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(client.isMockMode, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);

      // Switch back to mock mode
      client.isMockMode = true;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user, isNotNull);

      auth.dispose();
    });

    testWidgets('HeaderNavBar mode pill re-renders immediately on tap',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = AppState();
      final authNotifier = AuthNotifier(apiClient: client);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: client),
            ChangeNotifierProvider.value(value: appState),
            ChangeNotifierProvider.value(value: authNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: HeaderNavBar(),
            ),
          ),
        ),
      );

      // Initial state: Mock Simulation
      expect(find.text('Mock Simulation'), findsOneWidget);
      expect(find.text('Live REST API'), findsNothing);

      // Tap the mode pill
      await tester.tap(find.text('Mock Simulation'));
      await tester.pumpAndSettle();

      // Verified: UI immediately re-rendered to Live REST API
      expect(client.isMockMode, isFalse);
      expect(find.text('Live REST API'), findsOneWidget);
      expect(find.text('Mock Simulation'), findsNothing);

      // Tap again to switch back
      await tester.tap(find.text('Live REST API'));
      await tester.pumpAndSettle();

      expect(client.isMockMode, isTrue);
      expect(find.text('Mock Simulation'), findsOneWidget);
      expect(find.text('Live REST API'), findsNothing);
    });
  });
}
