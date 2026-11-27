import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_version.dart';
import '../../state/app_navigation_guard.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';
import '../ilmiya_logo.dart';
import 'app_shell_nav_tile.dart';
import 'app_shell_sidebar_footer.dart';
import 'app_shell_tenant_dialog.dart';

class AppShellSidebar extends StatelessWidget {
  const AppShellSidebar({super.key});

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
            : (auth.tenantName.isNotEmpty ? auth.tenantName : auth.schoolName));

    final tenantSubtitle = auth.isPlatformSession
        ? 'Manage Tenants (Global)'
        : (auth.tenantId.isEmpty ? 'Select tenant' : 'Active Tenant Context');

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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'School Information System',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: t.muted.copyWith(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              key: const Key('sidebar_header_version_badge'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkSurface
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: c.border,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                AppVersion.tag,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: c.mutedForeground,
                                ),
                              ),
                            ),
                          ],
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
                      tabIndex: AppNavigationGuard.tenantConsoleTab,
                      isActive: state.currentTab ==
                          AppNavigationGuard.tenantConsoleTab,
                      badgeText: 'Admin',
                    ),
                  ],
                );
              }

              // Navigation visibility is centralized in AppNavigationGuard.
              bool canView(int tab) => AppNavigationGuard.canViewTab(tab, auth);

              final showInstitutionSection =
                  canView(AppNavigationGuard.schoolProfileTab) ||
                      canView(AppNavigationGuard.schoolsCampusesTab) ||
                      canView(AppNavigationGuard.dashboardTab);
              final showAcademicsSection =
                  canView(AppNavigationGuard.academicYearsTab) ||
                      canView(AppNavigationGuard.gradesTab);
              final showAdminSection = canView(AppNavigationGuard.iamTab) ||
                  canView(AppNavigationGuard.tenantConsoleTab);
              final showCommSection = canView(AppNavigationGuard.previewsTab) ||
                  canView(AppNavigationGuard.messagesTab) ||
                  canView(AppNavigationGuard.notificationsTab);

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (showInstitutionSection) ...[
                    _buildSectionHeader('Institution & Control'),
                    if (canView(AppNavigationGuard.schoolProfileTab))
                      AppShellNavTile(
                        title: 'School Profile',
                        icon: LucideIcons.school,
                        tabIndex: AppNavigationGuard.schoolProfileTab,
                        isActive: state.currentTab ==
                            AppNavigationGuard.schoolProfileTab,
                      ),
                    if (canView(AppNavigationGuard.schoolsCampusesTab))
                      AppShellNavTile(
                        title: 'Schools & Campuses',
                        icon: LucideIcons.building,
                        tabIndex: AppNavigationGuard.schoolsCampusesTab,
                        isActive: state.currentTab ==
                            AppNavigationGuard.schoolsCampusesTab,
                      ),
                    if (canView(AppNavigationGuard.dashboardTab))
                      AppShellNavTile(
                        title: 'Executive Dashboard',
                        icon: LucideIcons.layoutDashboard,
                        tabIndex: AppNavigationGuard.dashboardTab,
                        isActive:
                            state.currentTab == AppNavigationGuard.dashboardTab,
                      ),
                  ],
                  if (showAcademicsSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Academics'),
                    if (canView(AppNavigationGuard.academicYearsTab))
                      AppShellNavTile(
                        title: 'Academic Years',
                        icon: LucideIcons.calendarDays,
                        tabIndex: AppNavigationGuard.academicYearsTab,
                        isActive: state.currentTab ==
                            AppNavigationGuard.academicYearsTab,
                      ),
                    if (canView(AppNavigationGuard.gradesTab))
                      AppShellNavTile(
                        title: 'Courses & Grades',
                        icon: LucideIcons.graduationCap,
                        tabIndex: AppNavigationGuard.gradesTab,
                        isActive:
                            state.currentTab == AppNavigationGuard.gradesTab,
                      ),
                  ],
                  if (showAdminSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Administration'),
                    if (canView(AppNavigationGuard.iamTab))
                      AppShellNavTile(
                        title: 'IAM Console',
                        icon: LucideIcons.shieldCheck,
                        tabIndex: AppNavigationGuard.iamTab,
                        isActive: state.currentTab == AppNavigationGuard.iamTab,
                      ),
                    if (canView(AppNavigationGuard.tenantConsoleTab))
                      AppShellNavTile(
                        title: 'Tenant Console',
                        icon: LucideIcons.building2,
                        tabIndex: AppNavigationGuard.tenantConsoleTab,
                        isActive: state.currentTab ==
                            AppNavigationGuard.tenantConsoleTab,
                        badgeText: 'Admin',
                      )
                  ],
                  if (showCommSection) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Communications & Labs'),
                    if (canView(AppNavigationGuard.previewsTab))
                      AppShellNavTile(
                        title: 'Feature Previews',
                        icon: LucideIcons.flaskConical,
                        tabIndex: AppNavigationGuard.previewsTab,
                        isActive:
                            state.currentTab == AppNavigationGuard.previewsTab,
                        badgeText: 'Labs',
                      ),
                    if (canView(AppNavigationGuard.messagesTab))
                      AppShellNavTile(
                        title: 'Messages',
                        icon: LucideIcons.messageSquare,
                        tabIndex: AppNavigationGuard.messagesTab,
                        isActive:
                            state.currentTab == AppNavigationGuard.messagesTab,
                        unreadCount: state.unreadMessagesCount,
                      ),
                    if (canView(AppNavigationGuard.notificationsTab))
                      AppShellNavTile(
                        title: 'Notifications',
                        icon: LucideIcons.bell,
                        tabIndex: AppNavigationGuard.notificationsTab,
                        isActive: state.currentTab ==
                            AppNavigationGuard.notificationsTab,
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
