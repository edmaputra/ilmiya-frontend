import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';

class AcademicTermCard extends StatelessWidget {
  final AcademicTermResponse term;
  final bool canWrite;
  final VoidCallback onActivate;

  const AcademicTermCard({
    super.key,
    required this.term,
    required this.canWrite,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isTermActive = term.status == 'ACTIVE';

    return Container(
      width: 240,
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTermActive ? c.accent : c.card,
        borderRadius: KiteRadius.allMd,
        border: Border.all(
          color: isTermActive ? c.primary : c.border,
          width: isTermActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      term.name,
                      overflow: TextOverflow.ellipsis,
                      style: t.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: c.foreground,
                      ),
                    ),
                  ),
                  KiteBadge(
                    term.status,
                    tone: isTermActive ? KiteTone.success : KiteTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${term.startDate} → ${term.endDate}',
                style: t.small.copyWith(
                  fontSize: 10,
                  color: c.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: isTermActive
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.forestSage.withOpacity(0.12),
                      borderRadius: KiteRadius.allSm,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.check,
                            size: 12, color: AppColors.forestSage),
                        SizedBox(width: 4),
                        Text(
                          'Active Term',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    ),
                  )
                : (term.status == 'CONCLUDED'
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.muted.withOpacity(0.35),
                          borderRadius: KiteRadius.allSm,
                        ),
                        child: Text(
                          'Term Concluded',
                          style: TextStyle(
                            fontSize: 10,
                            color: c.mutedForeground,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: canWrite ? onActivate : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: c.primary,
                          side: BorderSide(color: c.border),
                          shape: const RoundedRectangleBorder(
                            borderRadius: KiteRadius.allSm,
                          ),
                        ),
                        child: const Text('Activate Term',
                            style: TextStyle(fontSize: 10)),
                      )),
          ),
        ],
      ),
    );
  }
}
