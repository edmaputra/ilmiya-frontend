import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';
import 'push_simulator_panel.dart';

class NotificationsHeaderBanner extends StatelessWidget {
  final AppState state;

  const NotificationsHeaderBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'LIVE WEBSOCKET STREAM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.forestSage,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• APNs & FCM Push Bridge',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Real-Time Notification Center',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Multiplatform event dispatcher for academic grades, emergency notices, and teacher DMs',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: state.soundEnabled
                          ? AppColors.forestSage
                          : AppColors.textMuted,
                      side: const BorderSide(color: AppColors.borderLight),
                      backgroundColor: state.soundEnabled
                          ? AppColors.warmSand
                          : AppColors.naturalParchment,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(
                      state.soundEnabled
                          ? Icons.volume_up_outlined
                          : Icons.volume_off_outlined,
                      size: 16,
                    ),
                    label: Text(
                      state.soundEnabled ? 'Chime ON' : 'Muted',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.toggleSound(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naturalParchment,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.borderMedium),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.done_all,
                        size: 16, color: AppColors.forestSage),
                    label: const Text(
                      'Mark All Read',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.markAllNotificationsRead(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Push simulator
          const PushSimulatorPanel(),
        ],
      ),
    );
  }
}
