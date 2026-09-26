import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';
import '../widgets/broadcast_composer_card.dart';
import '../widgets/notifications_feed_view.dart';
import '../widgets/notifications_header_banner.dart';

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
          NotificationsHeaderBanner(state: state),

          const SizedBox(height: 20),

          // 2. Split Layout: Feed (Left) & Broadcast Composer (Right)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: NotificationsFeedView(
                    state: state,
                    items: filteredList,
                    selectedCategory: _selectedCategory,
                    onSelectCategory: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
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
                NotificationsFeedView(
                  state: state,
                  items: filteredList,
                  selectedCategory: _selectedCategory,
                  onSelectCategory: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: 20),
                const BroadcastComposerCard(),
              ],
            ),
        ],
      ),
    );
  }
}
