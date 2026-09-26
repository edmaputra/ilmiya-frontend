import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';
import 'course_card.dart';

class DashboardCoursesSection extends StatelessWidget {
  final AppState state;

  const DashboardCoursesSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.bookOpen,
                    size: 18, color: AppColors.forestSage),
                const SizedBox(width: KiteSpace.sm),
                Text('Active Academic Courses', style: t.h4),
              ],
            ),
            TextButton.icon(
              onPressed: () => state.setTab(5),
              icon: const Text(
                'Full Coursework & Grades',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestSage,
                ),
              ),
              label: const Icon(LucideIcons.arrowUpRight,
                  size: 14, color: AppColors.forestSage),
            ),
          ],
        ),
        const SizedBox(height: KiteSpace.md),

        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 550 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: KiteSpace.md,
                mainAxisSpacing: KiteSpace.md,
                childAspectRatio: count == 1 ? 2.3 : 1.7,
              ),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                return CourseCard(course: state.courses[index]);
              },
            );
          },
        ),

        const SizedBox(height: KiteSpace.lg),

        // Upcoming Submission Alert Card
        Container(
          padding: const EdgeInsets.all(KiteSpace.lg),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3).withOpacity(0.5),
            borderRadius: KiteRadius.allLg,
            border: Border.all(color: const Color(0xFFFDE047)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.clock,
                    color: Color(0xFF854D0E), size: 18),
              ),
              const SizedBox(width: KiteSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPCOMING SUBMISSION PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF854D0E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Final Term Capstone: Distributed State Machine (CS-301) • Due Friday',
                      style: t.small.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => state.setTab(5),
                child: const Text('View Rubric',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
