import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/user_profile.dart';
import '../state/app_state.dart';
import 'ilmiya_logo.dart';

class HeaderNavBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF2FAF9F6),
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            // Brand Logo & Title
            Row(
              children: [
                const IlmiyaLogo(size: 38, isSquircle: true),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Ilmiya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Text(
                            'SIS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestSage,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isTablet)
                      const Text(
                        'School Information System',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 20),

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
                        _buildNavPill(
                          context,
                          label: 'Dashboard',
                          tabIndex: 0,
                          isActive: state.currentTab == 0,
                        ),
                        _buildNavPill(
                          context,
                          label: 'Grade Tracking',
                          tabIndex: 1,
                          isActive: state.currentTab == 1,
                        ),
                        _buildNavPill(
                          context,
                          label: 'Messaging',
                          tabIndex: 2,
                          badgeCount: state.unreadMessagesCount,
                          icon: Icons.chat_bubble_outline,
                          isActive: state.currentTab == 2,
                        ),
                        _buildNavPill(
                          context,
                          label: 'Notifications',
                          tabIndex: 3,
                          badgeCount: state.unreadNotifsCount,
                          icon: Icons.notifications_none_rounded,
                          isActive: state.currentTab == 3,
                        ),
                        _buildNavPill(
                          context,
                          label: 'Flutter Code',
                          tabIndex: 4,
                          icon: Icons.code,
                          isActive: state.currentTab == 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              )
            else
              const Spacer(),

            // Right Controls: Quick Simulator & Role Switcher
            Row(
              children: [
                if (isTablet)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forestSage,
                      side: const BorderSide(color: AppColors.borderMedium),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.tune, size: 14, color: AppColors.earthyTerra),
                    label: const Text(
                      'Simulate Alert',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.simulateNotification('grade'),
                  ),

                const SizedBox(width: 8),

                // Role Switcher Dropdown Button
                PopupMenuButton<UserRole>(
                  tooltip: 'Switch Campus Role',
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  onSelected: (role) => state.setRole(role),
                  itemBuilder: (context) => [
                    _buildRoleMenuItem(UserRole.student, 'Alex Rivera (Grade 11)'),
                    _buildRoleMenuItem(UserRole.teacher, 'Dr. Eleanor Vance (STEM)'),
                    _buildRoleMenuItem(UserRole.parent, 'Marco Rivera (Parent)'),
                    _buildRoleMenuItem(UserRole.admin, 'Principal Martinez (Admin)'),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(user.avatar),
                          backgroundColor: AppColors.borderMedium,
                        ),
                        if (isTablet) ...[
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                user.role.displayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestSage,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill(
    BuildContext context, {
    required String label,
    required int tabIndex,
    required bool isActive,
    IconData? icon,
    int? badgeCount,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setTab(tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.naturalParchment : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? AppColors.forestSage : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? AppColors.forestSage : AppColors.textSecondary,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.earthyTerra,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PopupMenuItem<UserRole> _buildRoleMenuItem(UserRole role, String subtitle) {
    return PopupMenuItem<UserRole>(
      value: role,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
