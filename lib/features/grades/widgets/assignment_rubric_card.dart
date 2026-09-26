import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/course.dart';
import '../../../state/app_state.dart';

class AssignmentRubricCard extends StatelessWidget {
  final Course course;
  final Assignment assignment;

  const AssignmentRubricCard({
    super.key,
    required this.course,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context) {
    final isGraded = assignment.status == 'graded';
    final percentage = assignment.percentage.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 440;

              final metaTags = Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Text(
                      assignment.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Due: ${assignment.dueDate}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (assignment.submittedDate != null)
                    Text(
                      '• Submitted on ${assignment.submittedDate}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestSage,
                      ),
                    ),
                ],
              );

              final scoreWidget = isGraded
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${assignment.score.toStringAsFixed(0)} / ${assignment.maxScore.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($percentage%)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warmSand,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: const Text(
                        'Pending Grading',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.earthyTerra,
                        ),
                      ),
                    );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: metaTags),
                        const SizedBox(width: 8),
                        scoreWidget,
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        metaTags,
                        const SizedBox(height: 6),
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  scoreWidget,
                ],
              );
            },
          ),

          // Instructor Feedback & Rubric
          if (assignment.feedback != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmSand.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                          height: 1.4),
                      children: [
                        const TextSpan(
                          text: 'Instructor Feedback: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestSage),
                        ),
                        TextSpan(text: '"${assignment.feedback}"'),
                      ],
                    ),
                  ),

                  // Rubric Scores Breakdown
                  if (assignment.rubricScores != null &&
                      assignment.rubricScores!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 6),
                    const Text(
                      'SCORING RUBRIC BREAKDOWN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: assignment.rubricScores!.map((rubric) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                rubric.criterion,
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textMuted),
                              ),
                              Text(
                                '${rubric.score.toStringAsFixed(0)} / ${rubric.max.toStringAsFixed(0)} pts',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forestSage,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Inquire button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.forestSage,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 14),
              label: Text(
                'Inquire with ${course.teacherName.split(' ')[0]}',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                context.read<AppState>().inquireAssignment(course, assignment);
              },
            ),
          ),
        ],
      ),
    );
  }
}
