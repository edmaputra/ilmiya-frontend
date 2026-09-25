import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/academic_year.dart';
import 'academic_term_card.dart';

class ActiveAcademicYearCard extends StatelessWidget {
  final AcademicYearResponse activeYear;
  final bool canWrite;
  final VoidCallback onAddTerm;
  final ValueChanged<String> onActivateTerm;

  const ActiveAcademicYearCard({
    super.key,
    required this.activeYear,
    required this.canWrite,
    required this.onAddTerm,
    required this.onActivateTerm,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: KiteRadius.allMd,
                    ),
                    child: Icon(LucideIcons.star, color: c.primary, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const KiteBadge(
                            'CURRENTLY ACTIVE',
                            tone: KiteTone.success,
                          ),
                          Text(
                            '${activeYear.startDate} to ${activeYear.endDate}',
                            style: t.small.copyWith(color: c.mutedForeground),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeYear.name,
                        style: t.large.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: canWrite ? onAddTerm : null,
                icon: Icon(canWrite ? LucideIcons.plus : LucideIcons.lock,
                    size: 14),
                label: const Text('Add Term'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.foreground,
                  side: BorderSide(color: c.border),
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          Text(
            'Terms & Semesters Breakdown',
            style: t.small
                .copyWith(fontWeight: FontWeight.bold, color: c.foreground),
          ),
          const SizedBox(height: 12),
          if (activeYear.terms.isEmpty)
            Text('No terms configured yet.',
                style: t.small.copyWith(color: c.mutedForeground))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: activeYear.terms.map((term) {
                return AcademicTermCard(
                  term: term,
                  canWrite: canWrite,
                  onActivate: () => onActivateTerm(term.id),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
