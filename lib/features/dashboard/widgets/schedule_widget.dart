import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class ScheduleWidget extends StatelessWidget {
  const ScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.watch<AppState>();
    final schedule = state.schedule;

    return KiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendar, size: 16, color: c.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Today's Schedule",
                        style: t.small.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const KiteBadge(
                'Period 3 Active',
                tone: KiteTone.info,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = schedule[index];
              final isActive = index == 2; // Simulated active period

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? c.accent : c.card,
                  borderRadius: KiteRadius.allMd,
                  border: Border.all(
                    color: isActive ? c.primary : c.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.courseName,
                            style: t.small.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isActive ? c.primary : c.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.time} • ${item.room}',
                            style: t.small.copyWith(
                              fontSize: 10,
                              color: c.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.teacher,
                      style: t.small.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
