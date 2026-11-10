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

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();

    final tenantDisplayName = auth.schoolName;

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
                onTap: () => AppShellTenantDialog.show(context, auth),
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
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Active Institution',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: c.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          child: Builder(
            builder: (context) {
              final canViewSchoolProfile =
                  auth.hasPermission('school:profile:read') ||
                      auth.hasRole('SUPERADMIN') ||
                      auth.hasRole('SCHOOL_ADMIN');
              const canViewDashboard = true;
              final canViewAcademicYears =
                  auth.hasPermission('academic:year:read') ||
                      auth.hasRole('SUPERADMIN') ||
                      auth.hasRole('SCHOOL_ADMIN');
              final canViewGrades =
                  auth.hasPermission('academic:course:read') ||
                      auth.hasPermission('attendance:record:read') ||
                      auth.hasPermission('student:profile:read') ||
                      auth.roles.any((r) => [
                            'TEACHER',
                            'STUDENT',
                            'PARENT',
                            'SUPERADMIN',
                            'SCHOOL_ADMIN'
                          ].contains(r.toUpperCase()));
              final canViewIam = auth.hasPermission('iam:user:read') ||
                  auth.hasPermission('iam:role:read') ||
                  auth.hasPermission('iam:group:read') ||
                  auth.hasPermission('iam:scope:read') ||
                  auth.hasRole('SUPERADMIN');
              final canViewTenants =
                  auth.hasRole('SUPERADMIN') || auth.hasPermission('*');
              final canViewPreviews = auth.hasRole('SUPERADMIN') ||
                  auth.hasRole('SCHOOL_ADMIN') ||
                  !auth.isAuthenticated;

              final showInstitutionSection =
                  canViewSchoolProfile || canViewDashboard;
              final showAcademicsSection =
                  canViewAcademicYears || canViewGrades;
              final showAdminSection = canViewIam || canViewTenants;
              const showCommSection = true;

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (showInstitutionSection) ...[
                    _buildSectionHeader('Institution & Control'),
                    if (canViewSchoolProfile)
                      AppShellNavTile(
                        title: 'School Profile',
                        icon: LucideIcons.school,
                        tabIndex: 0,
                        isActive: state.currentTab == 0,
                      ),
                    if (canViewDashboard)
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
                    if (canViewGrades)
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
