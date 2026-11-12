import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/session_storage_service.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStorageService storage;

  setUp(() async {
    storage = SessionStorageService();
    await storage.init();
    storage.resetForTesting();
  });

  tearDown(() {
    storage.resetForTesting();
  });

  group('SessionStorageService Tests', () {
    test('Saves, retrieves, and clears auth session credentials', () async {
      final user = UserProfileResponse(
        id: 'usr-web-01',
        email: 'web.admin@ilmiya.edu',
        fullName: 'Web Admin',
        tenantId: 'tenant-web-001',
        roles: ['SUPERADMIN'],
        permissions: ['*'],
        scopes: ['/CAMPUS_MAIN'],
      );

      await storage.saveAuthSession(
        accessToken: 'access-token-123',
        refreshToken: 'refresh-token-456',
        tenantId: 'tenant-web-001',
        user: user,
        schoolName: 'Lincoln High Online',
      );

      expect(storage.accessToken, equals('access-token-123'));
      expect(storage.refreshToken, equals('refresh-token-456'));
      expect(storage.tenantId, equals('tenant-web-001'));
      expect(storage.schoolName, equals('Lincoln High Online'));
      expect(storage.userProfile?.email, equals('web.admin@ilmiya.edu'));
      expect(storage.userProfile?.roles, equals(['SUPERADMIN']));

      await storage.clearAuthSession();

      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.tenantId, isNull);
      expect(storage.userProfile, isNull);
      expect(storage.schoolName, isNull);
    });

    test('Saves and restores ThemeMode and currentTab', () async {
      await storage.saveThemeMode(ThemeMode.dark);
      expect(storage.themeMode, equals(ThemeMode.dark));

      await storage.saveThemeMode(ThemeMode.light);
      expect(storage.themeMode, equals(ThemeMode.light));

      await storage.saveCurrentTab(3);
      expect(storage.currentTab, equals(3));
    });
  });

  group('Auth Session Restoration on Web / App Refresh Tests', () {
    test('AuthNotifier immediately restores authenticated state from storage',
        () async {
      final cachedUser = UserProfileResponse(
        id: 'u-cached-99',
        email: 'saved.user@ilmiya.edu',
        fullName: 'Saved User',
        tenantId: 'tenant-saved-001',
        roles: ['TEACHER'],
        permissions: ['academic:course:read'],
        scopes: ['/CAMPUS_MAIN'],
      );

      await storage.saveAuthSession(
        accessToken: 'jwt-persisted-token',
        refreshToken: 'refresh-persisted-token',
        tenantId: 'tenant-saved-001',
        user: cachedUser,
        schoolName: 'Saved High School',
      );

      final client = ApiClient();
      final auth = AuthNotifier(apiClient: client, sessionStorage: storage);

      // Verify that even before any network request completes, state is authenticated
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.email, equals('saved.user@ilmiya.edu'));
      expect(auth.hasRole('TEACHER'), isTrue);
      expect(auth.schoolName, equals('Saved High School'));
      expect(client.token, equals('jwt-persisted-token'));
      expect(client.refreshToken, equals('refresh-persisted-token'));
    });

    test('Logout purges persisted session from storage', () async {
      await storage.saveAuthSession(
        accessToken: 'jwt-persisted-token',
        refreshToken: 'refresh-persisted-token',
        tenantId: 'tenant-saved-001',
      );

      final client = ApiClient();
      final iam = IamService(apiClient: client, sessionStorage: storage);
      final auth = AuthNotifier(
        apiClient: client,
        iamService: iam,
        sessionStorage: storage,
      );

      auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(client.token, isNull);
    });

    test('triggerAuthExpired purges persisted session from storage', () async {
      await storage.saveAuthSession(
        accessToken: 'jwt-persisted-token',
        refreshToken: 'refresh-persisted-token',
      );

      final client = ApiClient();
      final auth = AuthNotifier(apiClient: client, sessionStorage: storage);

      client.triggerAuthExpired('Session timed out');

      expect(auth.isAuthenticated, isFalse);
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
    });
  });

  group('AppState Persistence Tests', () {
    test(
        'AppState initializes with saved theme from storage and persists toggles',
        () async {
      await storage.saveThemeMode(ThemeMode.dark);

      final appState = AppState(sessionStorage: storage);

      expect(appState.themeMode, equals(ThemeMode.dark));

      appState.toggleThemeMode();
      expect(appState.themeMode, equals(ThemeMode.light));
      expect(storage.themeMode, equals(ThemeMode.light));

      appState.setThemeMode(ThemeMode.dark);
      expect(appState.themeMode, equals(ThemeMode.dark));
      expect(storage.themeMode, equals(ThemeMode.dark));
    });
  });
}
