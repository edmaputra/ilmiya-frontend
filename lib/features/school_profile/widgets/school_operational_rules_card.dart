import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/school.dart';

class SchoolOperationalRulesCard extends StatelessWidget {
  static const List<String> _allDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

  final SchoolResponse profile;
  final bool canManageSettings;
  final VoidCallback onConfigure;

  const SchoolOperationalRulesCard({
    super.key,
    required this.profile,
    required this.canManageSettings,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.sliders, color: c.foreground, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Operational Rules',
                        overflow: TextOverflow.ellipsis,
                        style: t.large.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: canManageSettings ? onConfigure : null,
                icon: Icon(
                    canManageSettings ? LucideIcons.settings : LucideIcons.lock,
                    size: 14),
                label: const Text('Configure', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: c.primary),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          Text(
            'Active Working Days',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _allDays.map((d) {
              final active = profile.workingDays.contains(d);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? c.accent : c.muted.withOpacity(0.5),
                  borderRadius: KiteRadius.allMd,
                  border: Border.all(color: active ? c.primary : c.border),
                ),
                child: Text(
                  d.substring(0, 3),
                  style: t.small.copyWith(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: active ? c.foreground : c.mutedForeground,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Curriculum & Grading',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.gradingPreference.replaceAll('_', ' '),
            style: t.small.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Academic Term Layout',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.termLayout,
            style: t.small.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
