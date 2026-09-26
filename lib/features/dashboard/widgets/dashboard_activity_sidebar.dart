import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';
import 'schedule_widget.dart';

class DashboardActivitySidebar extends StatelessWidget {
  final AppState state;

  const DashboardActivitySidebar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isMobile = KiteBreak.isMobile(context);

    return Column(
      children: [
        // 1. Weekly Schedule & Timetable
        const ScheduleWidget(),

        const SizedBox(height: KiteSpace.xl),

        // 2. Kite-styled Live Stream Feed Card
        KiteCard(
          padding: EdgeInsets.all(isMobile ? KiteSpace.md : KiteSpace.xl),
          title: 'Live Activity & Notifications',
          trailing: InkWell(
            onTap: () => state.simulateNotification('grade'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.sparkles,
                    size: 12, color: AppColors.earthyTerra),
                const SizedBox(width: 4),
                Text(
                  'Simulate',
                  style: t.small.copyWith(
                    color: AppColors.forestSage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.notifications.take(3).length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: KiteSpace.sm),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  final isMsg = notif.category == NotificationCategory.message;

                  return InkWell(
                    borderRadius: KiteRadius.allMd,
                    onTap: () => state.setTab(isMsg ? 6 : 7),
                    child: Container(
                      padding: const EdgeInsets.all(KiteSpace.md),
                      decoration: BoxDecoration(
                        color: notif.read
                            ? c.background
                            : c.muted.withOpacity(0.5),
                        borderRadius: KiteRadius.allMd,
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: t.small
                                      .copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                notif.timestamp,
                                style: t.muted.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.muted.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: KiteSpace.sm),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => state.setTab(7),
                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                  label: const Text('View All Notifications',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
