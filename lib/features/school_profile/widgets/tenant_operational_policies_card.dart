import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';

class TenantOperationalPoliciesCard extends StatelessWidget {
  static const List<String> _allDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

  final SchoolResponse school;
  final ValueChanged<SchoolResponse> onSettings;

  const TenantOperationalPoliciesCard({
    super.key,
    required this.school,
    required this.onSettings,
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
            children: [
              const Icon(LucideIcons.sliders,
                  color: AppColors.forestSage, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Operational Policies',
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => onSettings(school),
                icon: const Icon(LucideIcons.settings, size: 13),
                label: const Text('Configure', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          Text(
            'Working Days',
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
              final active = school.workingDays.contains(d);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: active ? c.accent : c.muted.withOpacity(0.5),
                  borderRadius: KiteRadius.allMd,
                  border: Border.all(color: active ? c.primary : c.border),
                ),
                child: Text(
                  d.substring(0, 3),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: active ? c.foreground : c.mutedForeground,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Grading Preference',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            school.gradingPreference.replaceAll('_', ' '),
            style: t.small.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Academic Term Layout',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            school.termLayout,
            style: t.small.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tenant Status',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 4),
          KiteBadge(
            school.status,
            tone:
                school.status == 'ACTIVE' ? KiteTone.success : KiteTone.danger,
          ),
        ],
      ),
    );
  }
}
