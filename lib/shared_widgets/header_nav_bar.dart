import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../state/app_state.dart';
import '../state/auth_notifier.dart';
import 'navigation/header_brand_title.dart';
import 'navigation/header_mode_pill.dart';
import 'navigation/header_nav_pill.dart';
import 'navigation/header_persona_menu.dart';
import 'navigation/header_tenant_switcher_dialog.dart';

class HeaderNavBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final isTablet = MediaQuery.of(context).size.width >= 640;

    final currentUser = auth.user;
    final actorName = currentUser?.fullName.isNotEmpty == true
        ? currentUser!.fullName
        : appState.currentUser.name;
    final primaryRole = auth.roles.isNotEmpty
        ? auth.roles.first
        : appState.currentUser.role.displayName;

    final tenantDisplayName = auth.tenantId == 'tenant-lincoln-high-001'
        ? 'Lincoln High School'
        : auth.tenantId == 'tenant-sma1-ilmiya-002'
            ? 'SMA Negeri 1 Ilmiya'
            : auth.tenantId
                .replaceAll('tenant-', '')
                .replaceAll('-', ' ')
                .toUpperCase();

    final shortTenantName = auth.tenantId == 'tenant-lincoln-high-001'
        ? 'Lincoln High'
        : auth.tenantId == 'tenant-sma1-ilmiya-002'
            ? 'SMAN 1 Ilmiya'
            : auth.tenantId;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF2FAF9F6),
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            HeaderBrandTitle(
              isDesktop: isDesktop,
              tenantDisplayName: tenantDisplayName,
            ),
            const SizedBox(width: 8),

            // Navigation Tabs (Desktop Web)
            if (isDesktop)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HeaderNavPill(
                            label: 'School Profile',
                            tabIndex: 0,
                            icon: Icons.account_balance_outlined,
                            isActive: appState.currentTab == 0,
                          ),
                          HeaderNavPill(
                            label: 'Academic Years',
                            tabIndex: 1,
                            icon: Icons.calendar_month_outlined,
                            isActive: appState.currentTab == 1,
                          ),
                          HeaderNavPill(
                            label: 'IAM Console',
                            tabIndex: 2,
                            icon: Icons.admin_panel_settings_outlined,
                            isActive: appState.currentTab == 2,
                          ),
                          HeaderNavPill(
                            label: 'Feature Previews',
                            tabIndex: 3,
                            icon: Icons.science_outlined,
                            isActive: appState.currentTab == 3,
                            tag: 'Labs',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Right Controls: Mode Toggle, Tenant Badge, Actor Profile
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTablet) ...[
                  const HeaderModePill(),
                  const SizedBox(width: 8),
                ],

                // Tenant Badge / Switcher
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => HeaderTenantSwitcherDialog.show(context, auth),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.domain_rounded,
                          size: 13,
                          color: AppColors.forestSage,
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: isTablet ? 120 : 75),
                          child: Text(
                            shortTenantName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.swap_vert,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Actor Profile & Persona Switcher Menu
                HeaderPersonaMenu(
                  auth: auth,
                  actorName: actorName,
                  primaryRole: primaryRole,
                  isTablet: isTablet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
