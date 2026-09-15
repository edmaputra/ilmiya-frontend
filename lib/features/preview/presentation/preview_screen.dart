import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../grades/presentation/grades_screen.dart';
import '../../messaging/presentation/messaging_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../flutter_code/presentation/flutter_code_screen.dart';

enum PreviewSubTab {
  grades,
  messaging,
  notifications,
  dashboard,
  flutterCode,
}

class PreviewScreen extends StatefulWidget {
  final PreviewSubTab initialTab;

  const PreviewScreen({
    super.key,
    this.initialTab = PreviewSubTab.grades,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PreviewSubTab _currentSubTab;

  @override
  void initState() {
    super.initState();
    _currentSubTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Roadmap & Feature Preview Notice Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmSand.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.forestSage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.explore_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Feature Preview & Prototype Labs',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'ROADMAP PREVIEW',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'These interactive prototype components represent upcoming modules in subsequent roadmap phases (Curriculum, Student PPDB, Timetables, and Grading). They are preserved here for user experience testing and design validation.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Sub-tabs switcher
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSubTabItem(
                          label: 'Grades & GPA',
                          icon: Icons.military_tech_outlined,
                          tab: PreviewSubTab.grades,
                        ),
                        _buildSubTabItem(
                          label: 'Messaging',
                          icon: Icons.chat_bubble_outline,
                          tab: PreviewSubTab.messaging,
                          badgeCount: appState.unreadMessagesCount,
                        ),
                        _buildSubTabItem(
                          label: 'Alerts',
                          icon: Icons.notifications_none_rounded,
                          tab: PreviewSubTab.notifications,
                          badgeCount: appState.unreadNotifsCount,
                        ),
                        _buildSubTabItem(
                          label: 'Role Portal',
                          icon: Icons.dashboard_outlined,
                          tab: PreviewSubTab.dashboard,
                        ),
                        _buildSubTabItem(
                          label: 'Flutter Code',
                          icon: Icons.code,
                          tab: PreviewSubTab.flutterCode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Sub-tab Screen
          _buildActiveScreen(),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required String label,
    required IconData icon,
    required PreviewSubTab tab,
    int? badgeCount,
  }) {
    final isActive = _currentSubTab == tab;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _currentSubTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.naturalParchment : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.forestSage : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
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

  Widget _buildActiveScreen() {
    switch (_currentSubTab) {
      case PreviewSubTab.grades:
        return const GradesScreen();
      case PreviewSubTab.messaging:
        return const MessagingScreen();
      case PreviewSubTab.notifications:
        return const NotificationsScreen();
      case PreviewSubTab.dashboard:
        return const DashboardScreen();
      case PreviewSubTab.flutterCode:
        return const FlutterCodeScreen();
    }
  }
}
