import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../state/app_state.dart';

class DashboardHeaderBanner extends StatelessWidget {
  final UserProfile user;
  final String schoolName;
  final AppState state;

  const DashboardHeaderBanner({
    super.key,
    required this.user,
    required this.schoolName,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 500
          ? KiteSpace.md
          : KiteSpace.xl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262925) : Colors.white,
        borderRadius: KiteRadius.allLg,
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final isMobile = constraints.maxWidth < 500;

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: KiteSpace.sm,
                runSpacing: KiteSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const KiteBadge('2025/2026 Term 2 Active',
                      tone: KiteTone.success),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.muted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.shieldCheck,
                            size: 12, color: AppColors.forestSage),
                        const SizedBox(width: 4),
                        Text(
                          'FERPA & RBAC Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KiteSpace.sm),
              Text(
                'Welcome back, ${user.name}',
                style: (isMobile ? t.h4 : t.h3)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '$schoolName • Administrative Portal & Student Information Control',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.muted.copyWith(fontSize: isMobile ? 11 : 13),
              ),
            ],
          );
          final actions = Wrap(
            spacing: KiteSpace.sm,
            runSpacing: KiteSpace.sm,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: c.border),
                ),
                icon: const Icon(LucideIcons.calendar, size: 15),
                label: const Text('Academic Terms',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => state.setTab(1),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: c.border),
                ),
                icon: const Icon(LucideIcons.graduationCap, size: 15),
                label: const Text('Gradebook',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => state.setTab(5),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(LucideIcons.userPlus, size: 15),
                label: const Text('IAM Console',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () => state.setTab(2),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: textContent),
                const SizedBox(width: KiteSpace.md),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textContent,
              const SizedBox(height: KiteSpace.md),
              actions,
            ],
          );
        },
      ),
    );
  }
}
