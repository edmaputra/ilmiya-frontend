import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';
import 'notification_item_card.dart';

class NotificationsFeedView extends StatelessWidget {
  final AppState state;
  final List<NotificationItem> items;
  final NotificationCategory? selectedCategory;
  final ValueChanged<NotificationCategory?> onSelectCategory;

  const NotificationsFeedView({
    super.key,
    required this.state,
    required this.items,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final isSelected = selectedCategory == category;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.forestSage : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        side: BorderSide(
          color: isSelected ? AppColors.forestSage : AppColors.borderLight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => onSelectCategory(category),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All (${state.notifications.length})', null),
              const SizedBox(width: 6),
              _buildFilterChip('Academic Grades', NotificationCategory.grade),
              const SizedBox(width: 6),
              _buildFilterChip('Messages', NotificationCategory.message),
              const SizedBox(width: 6),
              _buildFilterChip(
                  'Announcements', NotificationCategory.announcement),
              const SizedBox(width: 6),
              _buildFilterChip(
                  'Urgent & Emergency', NotificationCategory.emergency),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 36, color: AppColors.forestSage),
                SizedBox(height: 8),
                Text(
                  'No notifications in this category.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = items[index];
              return NotificationItemCard(
                notif: notif,
                onMarkRead: () => state.markNotificationRead(notif.id),
                onDelete: () => state.deleteNotification(notif.id),
              );
            },
          ),
      ],
    );
  }
}
