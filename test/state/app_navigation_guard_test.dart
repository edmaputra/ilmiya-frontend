import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/session_storage_service.dart';
import 'package:ilmiya_app/state/app_navigation_guard.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

class _ScopedIamService extends IamService {
  _ScopedIamService({
    required super.apiClient,
    required super.mockStorage,
    required List<String> permissions,
  }) : _permissions = permissions;

  final List<String> _permissions;

  @override
  Future<UserProfileResponse> getMe() async {
    return UserProfileResponse(
      id: 'u-scoped-nav',
      email: 'scoped@ilmiya.edu',
      fullName: 'Scoped User',
      tenantId: 'tenant-lincoln-high-001',
      roles: const ['USER'],
      permissions: _permissions,
      scopes: const ['/CAMPUS_MAIN'],
    );
  }
}

void main() {
  setUp(() {
    MockStorageService().reset();
    SessionStorageService().resetForTesting();
    ApiClient().isMockMode = true;
  });

  Future<AuthNotifier> scopedAuth(List<String> permissions) async {
    final client = ApiClient()..isMockMode = true;
    final auth = AuthNotifier(
      apiClient: client,
      iamService: _ScopedIamService(
        apiClient: client,
        mockStorage: MockStorageService(),
        permissions: permissions,
      ),
    );
    await auth.refreshProfile();
    return auth;
  }

  group('AppNavigationGuard', () {
    test('a single IAM permission opens only the IAM domain', () async {
      final auth = await scopedAuth(const ['iam:user:read']);

      expect(AppNavigationGuard.canAccessTab(AppNavigationGuard.iamTab, auth),
          isTrue);
      expect(
          AppNavigationGuard.canAccessTab(
              AppNavigationGuard.schoolProfileTab, auth),
          isFalse);
      expect(
          AppNavigationGuard.canAccessTab(
              AppNavigationGuard.academicYearsTab, auth),
          isFalse);
      expect(
          AppNavigationGuard.canAccessTab(
              AppNavigationGuard.tenantConsoleTab, auth),
          isFalse);
      expect(
          AppNavigationGuard.canAccessTab(AppNavigationGuard.messagesTab, auth),
          isTrue);
      expect(AppNavigationGuard.firstAccessibleTab(auth),
          equals(AppNavigationGuard.iamTab));
    });

    test('feature-flagged tabs stay out of primary navigation', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.superadmin);
      await auth.switchTenant('tenant-lincoln-high-001');

      expect(
          AppNavigationGuard.canAccessTab(
              AppNavigationGuard.dashboardTab, auth),
          isTrue);
      expect(
          AppNavigationGuard.canViewTab(AppNavigationGuard.dashboardTab, auth),
          isFalse);
      expect(AppNavigationGuard.canViewTab(AppNavigationGuard.gradesTab, auth),
          isFalse);
      expect(
          AppNavigationGuard.canViewTab(AppNavigationGuard.previewsTab, auth),
          isFalse);
      expect(
          AppNavigationGuard.canViewTab(
              AppNavigationGuard.schoolProfileTab, auth),
          isTrue);
    });

    test('platform sessions fall back to the Tenant Console', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.superadmin);

      expect(AppNavigationGuard.firstAccessibleTab(auth),
          equals(AppNavigationGuard.tenantConsoleTab));
      expect(
          AppNavigationGuard.canAccessTab(
              AppNavigationGuard.schoolProfileTab, auth),
          isFalse);
    });
  });

  group('AppState tab guard', () {
    test('navigating to an inaccessible tab redirects to the fallback',
        () async {
      final auth = await scopedAuth(const ['iam:user:read']);
      final state = AppState();
      state.setTabAccessGuard(
        (tab) => AppNavigationGuard.canAccessTab(tab, auth),
        fallbackTab: AppNavigationGuard.firstAccessibleTab(auth),
      );

      state.setTab(AppNavigationGuard.profileTab);
      state.setTab(AppNavigationGuard.schoolProfileTab);
      expect(state.currentTab, equals(AppNavigationGuard.iamTab));

      state.setTab(AppNavigationGuard.iamTab);
      expect(state.currentTab, equals(AppNavigationGuard.iamTab));

      state.setTab(AppNavigationGuard.messagesTab);
      expect(state.currentTab, equals(AppNavigationGuard.messagesTab));
    });
  });
}
