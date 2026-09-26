import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';

class AcademicYearCatalogCard extends StatelessWidget {
  final List<AcademicYearResponse> academicYears;
  final bool canWrite;
  final ValueChanged<String> onAddTerm;
  final ValueChanged<String> onActivateYear;

  const AcademicYearCatalogCard({
    super.key,
    required this.academicYears,
    required this.canWrite,
    required this.onAddTerm,
    required this.onActivateYear,
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
              Icon(LucideIcons.calendarDays, color: c.foreground, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All Institutional Calendars',
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          ...academicYears.map((ay) {
            final isActive = ay.status == 'ACTIVE';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isActive ? c.accent.withOpacity(0.4) : c.card,
                borderRadius: KiteRadius.allMd,
                border: Border.all(color: isActive ? c.primary : c.border),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            ay.name,
                            style: t.small.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: c.foreground,
                            ),
                          ),
                          KiteBadge(
                            ay.status,
                            tone:
                                isActive ? KiteTone.success : KiteTone.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration: ${ay.startDate} to ${ay.endDate} • ${ay.terms.length} Terms',
                        style: t.small.copyWith(
                          fontSize: 11,
                          color: c.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: canWrite ? () => onAddTerm(ay.id) : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          foregroundColor: c.foreground,
                          side: BorderSide(color: c.border),
                          shape: const RoundedRectangleBorder(
                              borderRadius: KiteRadius.allSm),
                        ),
                        child: const Text('+ Add Term',
                            style: TextStyle(fontSize: 11)),
                      ),
                      if (!isActive)
                        ElevatedButton(
                          onPressed:
                              canWrite ? () => onActivateYear(ay.id) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: c.primaryForeground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: const RoundedRectangleBorder(
                                borderRadius: KiteRadius.allSm),
                          ),
                          child: const Text('Activate',
                              style: TextStyle(fontSize: 11)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.forestSage.withOpacity(0.12),
                            borderRadius: KiteRadius.allSm,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.check,
                                  size: 12, color: AppColors.forestSage),
                              SizedBox(width: 4),
                              Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestSage,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
