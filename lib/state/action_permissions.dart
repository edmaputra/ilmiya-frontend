import '../core/constants/app_permissions.dart';
import 'auth_notifier.dart';

/// Authorization for buttons/actions inside a screen.
///
/// Screen entry follows the "at least one permission in the domain" rule
/// (handled by the navigation guard); every individual action requires its own
/// concrete permission code from [AppPermissions]. SUPERADMIN roles and
/// wildcard permissions resolve through [AuthNotifier.hasPermission].
///
/// [allowTenantAdmin] preserves the documented TENANT_ADMIN fallback used by
/// the administrative consoles.
class ActionPermissions {
  const ActionPermissions._();

  static bool can(
    AuthNotifier auth,
    String permission, {
    bool allowTenantAdmin = false,
  }) {
    if (auth.hasPermission(permission)) return true;
    return allowTenantAdmin && auth.hasRole('TENANT_ADMIN');
  }
}
