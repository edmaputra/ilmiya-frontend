import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../state/app_state.dart';

class GradesHeaderCard extends StatelessWidget {
  final AppState state;
  final int subTabIndex;
  final ValueChanged<int> onSubTabChanged;

  const GradesHeaderCard({
    super.key,
    required this.state,
    required this.subTabIndex,
    required this.onSubTabChanged,
  });

  Widget _buildSubTabButton(int index, String label, IconData? icon) {
    final isActive = subTabIndex == index;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? AppColors.forestSage : AppColors.borderLight,
        foregroundColor: isActive ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: icon != null ? Icon(icon, size: 14) : const SizedBox.shrink(),
      label: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      onPressed: () => onSubTabChanged(index),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'OFFICIAL RECORDS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.forestSage,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• Spring 2026 Academic Term',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Grade Tracking & Academic Performance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time GPA computation, weighted category breakdowns, and feedback rubrics',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.naturalParchment,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        const Text(
                          'UNWEIGHTED GPA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          gpa['unweighted'] ?? '3.88',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                        width: 1, height: 32, color: AppColors.borderLight),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const Text(
                          'WEIGHTED GPA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          gpa['weighted'] ?? '4.12',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Sub-tab pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubTabButton(0, 'Course Grades & Rubrics', null),
                const SizedBox(width: 8),
                _buildSubTabButton(
                    1, 'GPA What-If Simulator', Icons.calculate_outlined),
                const SizedBox(width: 8),
                _buildSubTabButton(2, 'Report Card & Transcript',
                    Icons.picture_as_pdf_outlined),
                if (state.currentRole == UserRole.teacher) ...[
                  const SizedBox(width: 8),
                  _buildSubTabButton(
                      3, 'Teacher Gradebook Editor', Icons.edit_note_outlined),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
