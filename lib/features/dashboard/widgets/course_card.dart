import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:provider/provider.dart';
import '../../../core/models/course.dart';
import '../../../state/app_state.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        context.read<AppState>().setTab(1); // Go to Grades
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      course.code.split('-')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: t.small.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.teacherName} • ${course.period.split(' ')[0]}',
                        style: t.small.copyWith(
                          fontSize: 11,
                          color: c.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: course.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: course.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        course.letterGrade,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: course.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${course.currentPercentage}%',
                      style: t.small.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (course.currentPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: c.border,
                valueColor: AlwaysStoppedAnimation<Color>(course.color),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Room: ${course.room}',
                      style: t.small.copyWith(
                        fontSize: 11,
                        color: c.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.assignments.length} assignments',
                    style: t.small.copyWith(
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
      ),
    );
  }
}
