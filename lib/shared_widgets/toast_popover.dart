import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/notification_item.dart';
import '../state/app_state.dart';

class ToastPopover extends StatelessWidget {
  const ToastPopover({super.key});

  @override
  Widget build(BuildContext context) {
    final activeToast =
        context.select<AppState, NotificationItem?>((s) => s.activeToast);

    if (activeToast == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.forestSage.withOpacity(0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warmSand,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(
                  _getCategoryIcon(activeToast.category),
                  size: 18,
                  color: activeToast.category == NotificationCategory.emergency
                      ? AppColors.earthyTerra
                      : AppColors.forestSage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PUSH ALERT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.earthyTerra,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${activeToast.timestamp}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activeToast.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeToast.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.textMuted),
                onPressed: () => context.read<AppState>().dismissToast(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.grade:
        return Icons.emoji_events_outlined;
      case NotificationCategory.message:
        return Icons.chat_bubble_outline;
      case NotificationCategory.emergency:
        return Icons.warning_amber_rounded;
      case NotificationCategory.announcement:
        return Icons.notifications_none_rounded;
      case NotificationCategory.attendance:
        return Icons.check_circle_outline;
    }
  }
}
