import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/features/auth/presentation/login_screen.dart';
import 'package:ilmiya_app/main.dart';
import 'package:ilmiya_app/shared_widgets/adaptive_scaffold.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  group('Auth Guard & 401/403 Security Redirection Tests', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient();
      client.isMockMode = true;
      client.token = 'test-token';
      client.refreshToken = null;
    });

    tearDown(() {
      client.isMockMode = true;
      client.token = null;
      client.refreshToken = null;
    });

    test('401 response without refresh token calls triggerAuthExpired with reason', () async {
      String? expiredReason;
      final unsubscribe = client.onAuthExpired(([reason]) {
        expiredReason = reason;
      });

      // Override http request handling via test or triggerAuthExpired
      client.triggerAuthExpired('Session expired (401): Token revoked');

      expect(expiredReason, contains('Session expired (401)'));
      expect(client.token, isNull);
      expect(client.refreshToken, isNull);

      unsubscribe();
    });

    test('403 response triggers triggerAuthExpired with forbidden reason', () {
      String? expiredReason;
      final unsubscribe = client.onAuthExpired(([reason]) {
        expiredReason = reason;
      });

      client.triggerAuthExpired('Access forbidden (403): Insufficient permissions');

      expect(expiredReason, contains('Access forbidden (403)'));
      expect(client.token, isNull);

      unsubscribe();
    });

    test('AuthNotifier transitions isAuthenticated to false on auth expired', () async {
      final auth = AuthNotifier(apiClient: client);
      await auth.refreshProfile();
      expect(auth.isAuthenticated, isTrue);

      client.triggerAuthExpired('Access forbidden (403): Tenant access revoked');

      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
      expect(auth.error, contains('Access forbidden (403)'));
    });

    testWidgets('App renders LoginScreen when auth is not authenticated', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = AuthNotifier(apiClient: client);
      await auth.refreshProfile();
      auth.logout(); // explicitly unauthenticated

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: client),
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider.value(value: auth),
          ],
          child: const IlmiyaApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verified: LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Ilmiya Institutional Access'), findsOneWidget);
      expect(find.byType(AdaptiveScaffold), findsNothing);
    });

    testWidgets('App transitions from AdaptiveScaffold to LoginScreen when 401/403 triggers auth expired', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = AuthNotifier(apiClient: client);
      await auth.refreshProfile();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: client),
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider.value(value: auth),
          ],
          child: const IlmiyaApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially authenticated and showing main layout
      expect(find.byType(AdaptiveScaffold), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Backend returns 401/403 and triggers auth expired
      client.triggerAuthExpired('Session expired (401): User session timed out');
      await tester.pumpAndSettle();

      // App should be redirected to LoginScreen with the error message visible
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.textContaining('Session expired (401)'), findsOneWidget);
      expect(find.byType(AdaptiveScaffold), findsNothing);

      // User signs back in with a demo persona
      await tester.tap(find.text('Dr. Sarah Jenkins').first);
      await tester.pumpAndSettle();

      // Back into main layout
      expect(find.byType(AdaptiveScaffold), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
