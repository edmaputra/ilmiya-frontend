import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';
import '../../../shared_widgets/ilmiya_logo.dart';
import '../../../state/app_state.dart';
import 'login_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = context.watch<AppState?>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.naturalParchment,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceWhite,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
              ),
            ),
          ),
          padding:
              EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 8),
          child: Row(
            children: [
              const IlmiyaLogo(size: 28),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ilmiya',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (!isMobile)
                    Text(
                      'School Information System & IAM Portal',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Mode Status Badge (Determined at Startup Profile)
              ListenableBuilder(
                listenable: apiClient,
                builder: (context, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: apiClient.isMockMode
                          ? (isDark
                              ? const Color(0xFF3B1D54)
                              : const Color(0xFFF3E8FF))
                          : (isDark
                              ? const Color(0xFF133820)
                              : const Color(0xFFE6F4EA)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: apiClient.isMockMode
                            ? (isDark
                                ? const Color(0xFF7E22CE)
                                : const Color(0xFFD8B4FE))
                            : (isDark
                                ? const Color(0xFF15803D)
                                : const Color(0xFFA8DAB5)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: apiClient.isMockMode
                                ? const Color(0xFF9333EA)
                                : const Color(0xFF137333),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          apiClient.isMockMode
                              ? 'Mock Simulation'
                              : 'Live REST API',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: apiClient.isMockMode
                                ? (isDark
                                    ? const Color(0xFFD8B4FE)
                                    : const Color(0xFF7E22CE))
                                : (isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF137333)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (appState != null) ...[
                const SizedBox(width: 8),
                // Dark/Light Theme toggle
                IconButton(
                  iconSize: 18,
                  tooltip: appState.themeMode == ThemeMode.dark
                      ? 'Light Mode'
                      : 'Dark Mode',
                  icon: Icon(
                    appState.themeMode == ThemeMode.dark
                        ? LucideIcons.sun
                        : LucideIcons.moon,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () => appState.toggleThemeMode(),
                ),
              ],
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: const LoginDialog(isStandalone: true),
          ),
        ),
      ),
    );
  }
}
