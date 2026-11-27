import '../core/constants/app_permissions.dart';
import 'auth_notifier.dart';

/// Single source of truth for which tabs a user may open and which tabs are
/// shown in the primary navigation surfaces.
///
/// [canAccessTab] enforces permissions/roles/session rules. [canViewTab]
/// additionally respects the feature flags for not-yet-launched features.
class AppNavigationGuard {
  const AppNavigationGuard._();

  static const int schoolProfileTab = 0;
  static const int academicYearsTab = 1;
  static const int iamTab = 2;
  static const int previewsTab = 3;
  static const int dashboardTab = 4;
  static const int gradesTab = 5;
  static const int messagesTab = 6;
  static const int notificationsTab = 7;
  static const int tenantConsoleTab = 8;
  static const int schoolsCampusesTab = 9;
  static const int profileTab = 10;

  static const bool showExecutiveDashboard = false;
  static const bool showCoursesAndGrades = false;
  static const bool showCommunicationsAndLabs = false;

  /// Permission/role-based access to a tab, independent of feature flags.
  static bool canAccessTab(int tab, AuthNotifier auth) {
    if (tab == profileTab) return true;
    if (auth.isPlatformSession) {
      return tab == tenantConsoleTab;
    }
    if (tab == messagesTab || tab == notificationsTab) return true;

    switch (tab) {
      case schoolProfileTab:
        return auth.hasAnyPermission(AppPermissions.schoolProfileView) ||
            auth.hasRole('TENANT_ADMIN');
      case academicYearsTab:
        return auth.hasAnyPermission(AppPermissions.academicYearsView) ||
            auth.hasRole('TENANT_ADMIN');
      case iamTab:
        return auth.hasAnyPermission(AppPermissions.iamView) ||
            auth.hasRole('TENANT_ADMIN');
      case previewsTab:
        return auth.hasRole('SUPERADMIN') ||
            auth.hasRole('TENANT_ADMIN') ||
            auth.hasRole('SCHOOL_ADMIN') ||
            !auth.isAuthenticated;
      case dashboardTab:
        return auth.hasRole('SUPERADMIN') ||
            auth.hasRole('TENANT_ADMIN') ||
            auth.hasRole('PRINCIPAL') ||
            auth.hasRole('SCHOOL_ADMIN');
      case gradesTab:
        return auth.hasAnyPermission(AppPermissions.coursesAndGradesView) ||
            auth.hasRole('TEACHER') ||
            auth.hasRole('STUDENT');
      case tenantConsoleTab:
        return auth.isSuperAdmin;
      case schoolsCampusesTab:
        return auth.hasAnyPermission(AppPermissions.schoolsCampusesView) ||
            auth.hasRole('TENANT_ADMIN');
      default:
        return false;
    }
  }

  /// Visibility in the sidebar / bottom navigation: access plus feature flags.
  static bool canViewTab(int tab, AuthNotifier auth) {
    if (!canAccessTab(tab, auth)) return false;
    switch (tab) {
      case previewsTab:
      case messagesTab:
      case notificationsTab:
        return showCommunicationsAndLabs;
      case dashboardTab:
        return showExecutiveDashboard;
      case gradesTab:
        return showCoursesAndGrades;
      default:
        return true;
    }
  }

  /// First tab the user can open with the current session.
  static int firstAccessibleTab(AuthNotifier auth) {
    for (var tab = schoolProfileTab; tab <= profileTab; tab++) {
      if (canAccessTab(tab, auth)) return tab;
    }
    return profileTab;
  }
}
