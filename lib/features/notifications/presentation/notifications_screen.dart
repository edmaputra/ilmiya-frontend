import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';
import '../widgets/push_simulator_panel.dart';
import '../widgets/broadcast_composer_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _selectedCategory; // null = all

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final filteredList = state.notifications.where((n) {
      if (_selectedCategory == null) return true;
      return n.category == _selectedCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner & Chime Controls
          Container(
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
                              Text('• APNs & FCM Push Bridge', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: state.soundEnabled ? AppColors.forestSage : AppColors.textMuted,
                            side: const BorderSide(color: AppColors.borderLight),
                            backgroundColor: state.soundEnabled ? AppColors.warmSand : AppColors.naturalParchment,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: Icon(state.soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined, size: 16),
                          label: Text(state.soundEnabled ? 'Chime ON' : 'Muted', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          onPressed: () => state.toggleSound(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naturalParchment,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            side: const BorderSide(color: AppColors.borderMedium),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.done_all, size: 16, color: AppColors.forestSage),
                          label: const Text('Mark All Read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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
          ),

          const SizedBox(height: 20),

          // 2. Split Layout: Feed (Left) & Broadcast Composer (Right)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildNotificationsFeed(context, state, filteredList),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  flex: 5,
                  child: BroadcastComposerCard(),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildNotificationsFeed(context, state, filteredList),
                const SizedBox(height: 20),
                const BroadcastComposerCard(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsFeed(
    BuildContext context,
    AppState state,
    List<NotificationItem> items,
  ) {
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
              _buildFilterChip('Announcements', NotificationCategory.announcement),
              const SizedBox(width: 6),
              _buildFilterChip('Urgent & Emergency', NotificationCategory.emergency),
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
                Icon(Icons.check_circle_outline, size: 36, color: AppColors.forestSage),
                SizedBox(height: 8),
                Text('No notifications in this category.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
              return _buildNotificationCard(context, state, notif);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final isSelected = _selectedCategory == category;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.forestSage : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        side: BorderSide(color: isSelected ? AppColors.forestSage : AppColors.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => setState(() => _selectedCategory = category),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppState state,
    NotificationItem notif,
  ) {
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
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    if (notif.courseCode != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notif.courseCode!,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.message,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(notif.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    if (notif.senderName != null) ...[
                      const SizedBox(width: 10),
                      Text('From: ${notif.senderName}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
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
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.forestSage),
                  tooltip: 'Mark as read',
                  onPressed: () => state.markNotificationRead(notif.id),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.earthyTerra),
                tooltip: 'Delete notification',
                onPressed: () => state.deleteNotification(notif.id),
              ),
            ],
          ),
        ],
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
