import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/api_client.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';
import 'app_shell_user_menu.dart';

class AppShellSidebarFooter extends StatelessWidget {
  final AppState state;
  final AuthNotifier auth;

  const AppShellSidebarFooter({
    super.key,
    required this.state,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final user = auth.user;
    final userName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : state.currentUser.name;
    final userRole = auth.roles.isNotEmpty
        ? auth.roles.first
        : state.currentUser.role.displayName;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Backend Mode Pill
          ListenableBuilder(
            listenable: apiClient,
            builder: (context, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  apiClient.toggleMockMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        apiClient.isMockMode
                            ? 'Switched to Mock In-Memory Simulation'
                            : 'Switched to Live REST Backend Mode (${apiClient.baseUrl})',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: apiClient.isMockMode
                        ? const Color(0xFFFAF5FF)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: apiClient.isMockMode
                          ? const Color(0xFFE9D5FF)
                          : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: apiClient.isMockMode
                              ? const Color(0xFF9333EA)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          apiClient.isMockMode
                              ? 'Mock Simulation'
                              : 'Live REST API',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: apiClient.isMockMode
                                ? const Color(0xFF7E22CE)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.refreshCw,
                        size: 11,
                        color: apiClient.isMockMode
                            ? const Color(0xFF7E22CE)
                            : const Color(0xFF15803D),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // User Profile Row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.forestSage.withOpacity(0.15),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestSage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.small.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      userRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.muted.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),

              // Theme Toggle
              IconButton(
                iconSize: 16,
                tooltip: state.themeMode == ThemeMode.dark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? LucideIcons.sun
                      : LucideIcons.moon,
                  color: c.mutedForeground,
                ),
                onPressed: () => state.toggleThemeMode(),
              ),

              // Logout / Switch Persona Menu
              AppShellUserMenu(auth: auth),
            ],
          ),
        ],
      ),
    );
  }
}
