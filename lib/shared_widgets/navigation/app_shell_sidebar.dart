import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';
import '../ilmiya_logo.dart';
import 'app_shell_nav_tile.dart';
import 'app_shell_sidebar_footer.dart';
import 'app_shell_tenant_dialog.dart';

class AppShellSidebar extends StatelessWidget {
  const AppShellSidebar({super.key});

  /// Feature visibility toggles - preserved for future feature reuse
  static bool get showExecutiveDashboard => false;
  static bool get showCoursesAndGrades => false;
  static bool get showCommunicationsAndLabs => false;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();

    final tenantDisplayName = auth.isPlatformSession
        ? 'Platform Management'
        : (auth.tenantId.isEmpty
            ? 'No Tenant Selected'
            : (auth.schoolName.isNotEmpty ? auth.schoolName : auth.tenantName));

    final tenantSubtitle = auth.isPlatformSession
        ? 'Manage Tenants (Global)'
        : (auth.tenantId.isEmpty
            ? 'Select school tenant'
            : 'Active Institution');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IlmiyaLogo(size: 34, isSquircle: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ilmiya',
                              style: t.h4.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.forestSage.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SIS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.forestSage,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'School Information System',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: t.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Active Tenant Selector Card
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: (auth.isPlatformSession || auth.isTenantAdmin)
                    ? null
                    : () => AppShellTenantDialog.show(context, auth),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.building,
                        size: 14,
                        color: AppColors.forestSage,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenantDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: c.foreground,
                              ),
                            ),
                            Text(
                              tenantSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: c.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!auth.isPlatformSession && !auth.isTenantAdmin)
                        Icon(
                          LucideIcons.chevronsUpDown,
                          size: 14,
                          color: c.mutedForeground,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Navigation Sections
        Expanded(
          child: AnimatedBuilder(
            animation: auth,
            builder: (context, _) {
              if (auth.isSuperAdmin && auth.isPlatformSession) {
                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _buildSectionHeader('Platform Operations'),
                    AppShellNavTile(
                      title: 'Tenant Console',
                      icon: LucideIcons.building2,
                      tabIndex: 8,
                      isActive: state.currentTab == 8,
                      badgeText: 'Admin',
                    ),
                  ],
                );
              }

              final canViewSchoolProfile = auth.hasPermission('school:read') ||
                  auth.hasPermission('*') ||
                  auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('TENANT_ADMIN') ||
                  auth.hasRole('SCHOOL_ADMIN');
              final canViewDashboard = auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('TENANT_ADMIN') ||
                  auth.hasRole('PRINCIPAL') ||
                  auth.hasRole('SCHOOL_ADMIN');
              final canViewAcademicYears =
                  auth.hasPermission('academic-year:read') ||
                      auth.hasPermission('*') ||
                      auth.hasRole('SUPERADMIN') ||
                      auth.hasRole('TENANT_ADMIN') ||
                      auth.hasRole('SCHOOL_ADMIN');
              final canViewGrades = auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('TENANT_ADMIN') ||
                  auth.hasRole('TEACHER') ||
                  auth.hasRole('STUDENT');
              final canViewIam = auth.hasPermission('iam:user:read') ||
                  auth.hasPermission('iam:role:read') ||
                  auth.hasPermission('iam:group:read') ||
                  auth.hasPermission('iam:scope:read') ||
                  auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('TENANT_ADMIN');
              final canViewTenants = auth.isSuperAdmin;
              final canViewPreviews = auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('TENANT_ADMIN') ||
                  auth.hasRole('SCHOOL_ADMIN') ||
                  !auth.isAuthenticated;

              final showInstitutionSection = canViewSchoolProfile ||
                  (showExecutiveDashboard && canViewDashboard);
              final showAcademicsSection = canViewAcademicYears ||
                  (showCoursesAndGrades && canViewGrades);
              final showAdminSection = canViewIam || canViewTenants;
              final showCommSection = showCommunicationsAndLabs;

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (showInstitutionSection) ...[
                    _buildSectionHeader('Institution & Control'),
                    if (canViewSchoolProfile) ...[
                      AppShellNavTile(
                        title: 'School Profile',
                        icon: LucideIcons.school,
                        tabIndex: 0,
                        isActive: state.currentTab == 0,
                      ),
                      AppShellNavTile(
                        title: 'Schools & Campuses',
                        icon: LucideIcons.building,
                        tabIndex: 9,
                        isActive: state.currentTab == 9,
                      ),
                    ],
                    if (showExecutiveDashboard && canViewDashboard)
                      AppShellNavTile(
                        title: 'Executive Dashboard',
                        icon: LucideIcons.layoutDashboard,
                        tabIndex: 4,
                        isActive: state.currentTab == 4,
                      ),
                  ],
                  if (showAcademicsSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Academics'),
                    if (canViewAcademicYears)
                      AppShellNavTile(
                        title: 'Academic Years',
                        icon: LucideIcons.calendarDays,
                        tabIndex: 1,
                        isActive: state.currentTab == 1,
                      ),
                    if (showCoursesAndGrades && canViewGrades)
                      AppShellNavTile(
                        title: 'Courses & Grades',
                        icon: LucideIcons.graduationCap,
                        tabIndex: 5,
                        isActive: state.currentTab == 5,
                      ),
                  ],
                  if (showAdminSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Administration'),
                    if (canViewIam)
                      AppShellNavTile(
                        title: 'IAM Console',
                        icon: LucideIcons.shieldCheck,
                        tabIndex: 2,
                        isActive: state.currentTab == 2,
                      ),
                    if (canViewTenants)
                      AppShellNavTile(
                        title: 'Tenant Console',
                        icon: LucideIcons.building2,
                        tabIndex: 8,
                        isActive: state.currentTab == 8,
                        badgeText: 'Admin',
                      ),
                  ],
                  if (showCommSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Communications & Labs'),
                    if (canViewPreviews)
                      AppShellNavTile(
                        title: 'Feature Previews',
                        icon: LucideIcons.flaskConical,
                        tabIndex: 3,
                        isActive: state.currentTab == 3,
                        badgeText: 'Labs',
                      ),
                    AppShellNavTile(
                      title: 'Messages',
                      icon: LucideIcons.messageSquare,
                      tabIndex: 6,
                      isActive: state.currentTab == 6,
                      unreadCount: state.unreadMessagesCount,
                    ),
                    AppShellNavTile(
                      title: 'Notifications',
                      icon: LucideIcons.bell,
                      tabIndex: 7,
                      isActive: state.currentTab == 7,
                      unreadCount: state.unreadNotifsCount,
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        // Bottom Footer: Mode pill & User tile
        const Divider(height: 1),
        AppShellSidebarFooter(state: state, auth: auth),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
