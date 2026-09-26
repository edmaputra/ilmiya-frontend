import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../state/app_state.dart';
import 'transcript_table.dart';

class TranscriptDocumentCard extends StatelessWidget {
  final AppState state;
  final UserProfile user;
  final Map<String, String> gpa;

  const TranscriptDocumentCard({
    super.key,
    required this.state,
    required this.user,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.all(MediaQuery.of(context).size.width < 500 ? 16 : 24),
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
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Text(
                    'Official Student Academic Record • Accredited WASC',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              );

              final honorPill = Column(
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  schoolInfo,
                  honorPill,
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Student Info Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;
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
                              _buildInfoColumn('STUDENT ID', user.schoolId),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoColumn(
                                  'GRADE LEVEL', user.gradeLevel ?? 'Grade 11'),
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
                          _buildInfoColumn(
                              'GRADE LEVEL', user.gradeLevel ?? 'Grade 11'),
                          _buildInfoColumn('ACADEMIC TERM', 'Spring 2026 (Q3)'),
                        ],
                      ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Grades Table
          TranscriptTable(courses: state.courses),

          const SizedBox(height: 20),

          // Transcript Summary Footer
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;
              const leftCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cumulative Credits Earned: 48.0',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Attendance: 98.5% • Conduct: Exemplary',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              );

              final rightCol = Column(
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    'Unweighted GPA: ${gpa['unweighted']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Weighted GPA: ${gpa['weighted']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.forestSage,
                    ),
                  ),
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
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
