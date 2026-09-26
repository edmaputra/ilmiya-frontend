import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationItem notif;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationItemCard({
    super.key,
    required this.notif,
    required this.onMarkRead,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: !notif.read ? AppColors.warmSand.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: !notif.read
              ? notif.priority == NotificationPriority.urgent
                  ? AppColors.earthyTerra
                  : AppColors.forestSage.withOpacity(0.4)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warmSand,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(
              _getCategoryIcon(notif.category),
              size: 18,
              color: notif.category == NotificationCategory.emergency
                  ? AppColors.earthyTerra
                  : AppColors.forestSage,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        notif.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (notif.courseCode != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notif.courseCode!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text(
                      notif.timestamp,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (notif.senderName != null)
                      Text(
                        'From: ${notif.senderName}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              if (!notif.read)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.forestSage),
                  tooltip: 'Mark as read',
                  onPressed: onMarkRead,
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.earthyTerra),
                tooltip: 'Delete notification',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
