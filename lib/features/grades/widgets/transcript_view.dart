import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class TranscriptView extends StatelessWidget {
  const TranscriptView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final gpa = state.cumulativeGpa;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Official Academic Transcript & Q3 Report Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lincoln High School • Office of the Registrar & Academic Advising',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.print_outlined, size: 14, color: AppColors.warmSand),
                label: const Text('Print / Save PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.forestSage,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      content: const Text(
                        '📄 Official Transcript PDF prepared for export.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Official Document Box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.naturalParchment,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // School Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LINCOLN HIGH STEM ACADEMY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '1200 Innovation Parkway, Silicon Valley, CA 94025',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Official Student Academic Record • Accredited WASC',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warmSand,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Text(
                            'HONOR ROLL • DEAN\'S LIST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Date Issued: March 30, 2026',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Student Info Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      _buildInfoColumn('STUDENT NAME', user.name),
                      _buildInfoColumn('STUDENT ID', user.schoolId),
                      _buildInfoColumn('GRADE LEVEL', user.gradeLevel ?? 'Grade 11'),
                      _buildInfoColumn('ACADEMIC TERM', 'Spring 2026 (Q3)'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Grades Table
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: AppColors.borderLight,
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text('COURSE CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                              Expanded(flex: 4, child: Text('COURSE TITLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                              Expanded(flex: 3, child: Text('INSTRUCTOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                              Expanded(flex: 1, child: Text('CREDITS', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                              Expanded(flex: 1, child: Text('PCT', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                              Expanded(flex: 1, child: Text('GRADE', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                            ],
                          ),
                        ),

                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.courses.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final course = state.courses[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(course.code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 4, child: Text(course.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 3, child: Text(course.teacherName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                                  Expanded(flex: 1, child: Text(course.credits.toStringAsFixed(1), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                                  Expanded(flex: 1, child: Text('${course.currentPercentage}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                                  Expanded(flex: 1, child: Text(course.letterGrade, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.forestSage))),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Transcript Summary Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cumulative Credits Earned: 48.0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        Text('Attendance: 98.5% • Conduct: Exemplary', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Unweighted GPA: ${gpa['unweighted']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('Weighted GPA: ${gpa['weighted']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.forestSage)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
