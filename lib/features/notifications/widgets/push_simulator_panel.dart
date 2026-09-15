import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class PushSimulatorPanel extends StatelessWidget {
  const PushSimulatorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: AppColors.forestSage),
                  SizedBox(width: 6),
                  Text(
                    'INTERACTIVE PUSH DISPATCH SIMULATOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Click to trigger instant live notification',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 700 ? 4 : 2;

              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _buildSimulatorCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: AppColors.forestSage,
                    title: 'Grade Posted',
                    subtitle: 'AP Physics Exam (94/100)',
                    onTap: () => state.simulateNotification('grade'),
                  ),
                  _buildSimulatorCard(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.forestSage,
                    title: 'Class Notice',
                    subtitle: 'Study Session Added',
                    onTap: () => state.simulateNotification('announcement'),
                  ),
                  _buildSimulatorCard(
                    icon: Icons.chat_bubble_outline,
                    iconColor: AppColors.forestSage,
                    title: 'Teacher DM',
                    subtitle: 'Office hours follow-up',
                    onTap: () => state.simulateNotification('message'),
                  ),
                  _buildSimulatorCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.earthyTerra,
                    title: 'Urgent Alert',
                    subtitle: 'Weather Warning Notice',
                    onTap: () => state.simulateNotification('emergency'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
