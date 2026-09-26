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
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width < 500 ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              const titleSection = Column(
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
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              );

              final printButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.print_outlined,
                    size: 14, color: AppColors.warmSand),
                label: const Text('Print / Save PDF',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.forestSage,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      content: const Text(
                        '📄 Official Transcript PDF prepared for export.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 12),
                    printButton,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: titleSection),
                  const SizedBox(width: 12),
                  printButton,
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Official Document Box
          Container(
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 500 ? 16 : 24),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 600;
                    final schoolInfo = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LINCOLN HIGH STEM ACADEMY',
                          style: TextStyle(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '1200 Innovation Parkway, Silicon Valley, CA 94025',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Text(
                          'Official Student Academic Record • Accredited WASC',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    );

                    final honorPill = Column(
                      crossAxisAlignment: isCompact
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          schoolInfo,
                          const SizedBox(height: 10),
                          honorPill,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: schoolInfo),
                        const SizedBox(width: 12),
                        honorPill,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Student Info Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 600;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: isCompact
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    _buildInfoColumn('STUDENT NAME', user.name),
                                    _buildInfoColumn(
                                        'STUDENT ID', user.schoolId),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildInfoColumn('GRADE LEVEL',
                                        user.gradeLevel ?? 'Grade 11'),
                                    _buildInfoColumn(
                                        'ACADEMIC TERM', 'Spring 2026 (Q3)'),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildInfoColumn('STUDENT NAME', user.name),
                                _buildInfoColumn('STUDENT ID', user.schoolId),
                                _buildInfoColumn('GRADE LEVEL',
                                    user.gradeLevel ?? 'Grade 11'),
                                _buildInfoColumn(
                                    'ACADEMIC TERM', 'Spring 2026 (Q3)'),
                              ],
                            ),
                    );
                  },
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tableWidth = constraints.maxWidth < 550
                            ? 550.0
                            : constraints.maxWidth;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  color: AppColors.borderLight,
                                  child: const Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('COURSE CODE',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Expanded(
                                          flex: 4,
                                          child: Text('COURSE TITLE',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('INSTRUCTOR',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Expanded(
                                          flex: 1,
                                          child: Text('CREDITS',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Expanded(
                                          flex: 1,
                                          child: Text('PCT',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Expanded(
                                          flex: 1,
                                          child: Text('GRADE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                    ],
                                  ),
                                ),

                                // Table Rows
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.courses.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, color: AppColors.borderLight),
                                  itemBuilder: (context, index) {
                                    final course = state.courses[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: Text(course.code,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700))),
                                          Expanded(
                                              flex: 4,
                                              child: Text(course.name,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600))),
                                          Expanded(
                                              flex: 3,
                                              child: Text(course.teacherName,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary))),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                  course.credits
                                                      .toStringAsFixed(1),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 11))),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                  '${course.currentPercentage}%',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary))),
                                          Expanded(
                                              flex: 1,
                                              child: Text(course.letterGrade,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors
                                                          .forestSage))),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Transcript Summary Footer
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 500;
                    const leftCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cumulative Credits Earned: 48.0',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                        Text('Attendance: 98.5% • Conduct: Exemplary',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    );

                    final rightCol = Column(
                      crossAxisAlignment: isCompact
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text('Unweighted GPA: ${gpa['unweighted']}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('Weighted GPA: ${gpa['weighted']}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.forestSage)),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leftCol,
                          const SizedBox(height: 12),
                          rightCol,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        leftCol,
                        rightCol,
                      ],
                    );
                  },
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
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
