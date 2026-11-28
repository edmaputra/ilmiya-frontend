import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/constants/app_permissions.dart';
import 'package:ilmiya_app/state/action_permissions.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

/// Scoped auth stub: only the explicitly granted codes and roles resolve.
/// Internal hydrated profile state is intentionally ignored.
class _ScopedAuth extends AuthNotifier {
  final Set<String> granted;
  final Set<String> assignedRoles;
  final bool platformSuperAdmin;

  _ScopedAuth({
    this.granted = const {},
    this.assignedRoles = const {},
    this.platformSuperAdmin = false,
  });

  @override
  bool get isSuperAdmin => platformSuperAdmin;

  @override
  bool hasPermission(String permission) =>
      platformSuperAdmin || granted.contains(permission);

  @override
  bool hasRole(String role) =>
      platformSuperAdmin ||
      assignedRoles.map((r) => r.toUpperCase()).contains(role.toUpperCase());
}

void main() {
  group('ActionPermissions.can', () {
    test('grants only the explicitly held permission', () {
      final auth = _ScopedAuth(granted: {AppPermissions.schoolProfileWrite});

      expect(
        ActionPermissions.can(auth, AppPermissions.schoolProfileWrite),
        isTrue,
      );
      expect(
        ActionPermissions.can(auth, AppPermissions.schoolSettingsManage),
        isFalse,
      );
      expect(ActionPermissions.can(auth, AppPermissions.tenantWrite), isFalse);
    });

    test('denies every action for a user with no permissions', () {
      final auth = _ScopedAuth();

      expect(
          ActionPermissions.can(auth, AppPermissions.iamUserCreate), isFalse);
      expect(
        ActionPermissions.can(auth, AppPermissions.schoolStatusManage),
        isFalse,
      );
    });

    test('platform superadmin passes every action', () {
      final auth = _ScopedAuth(platformSuperAdmin: true);

      expect(
          ActionPermissions.can(auth, AppPermissions.iamScopeDelete), isTrue);
      expect(
        ActionPermissions.can(auth, AppPermissions.tenantPasswordPolicyWrite),
        isTrue,
      );
    });

    test('TENANT_ADMIN fallback is opt-in', () {
      final auth = _ScopedAuth(assignedRoles: {'TENANT_ADMIN'});

      expect(
        ActionPermissions.can(
          auth,
          AppPermissions.iamUserCreate,
          allowTenantAdmin: true,
        ),
        isTrue,
      );
      expect(
        ActionPermissions.can(
          auth,
          AppPermissions.iamUserCreate,
          allowTenantAdmin: false,
        ),
        isFalse,
      );
    });
  });
}
