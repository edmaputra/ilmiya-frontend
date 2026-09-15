import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/course.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/data/mock_data.dart';
import '../../../state/app_state.dart';
import '../widgets/assignment_rubric_card.dart';
import '../widgets/what_if_calculator_view.dart';
import '../widgets/transcript_view.dart';
import '../widgets/teacher_gradebook_editor.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _subTabIndex = 0; // 0: Roster, 1: Calculator, 2: Transcript, 3: Teacher Gradebook
  late Course _selectedCourse;

  @override
  void initState() {
    super.initState();
    final courses = context.read<AppState>().courses;
    _selectedCourse = courses.isNotEmpty ? courses.first : initialCourses.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final gpa = state.cumulativeGpa;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top GPA Header & Sub-nav
          Container(
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
                              Text('• Spring 2026 Academic Term', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.naturalParchment,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Text('UNWEIGHTED GPA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                              Text(gpa['unweighted'] ?? '3.88', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(width: 1, height: 32, color: AppColors.borderLight),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              const Text('WEIGHTED GPA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                              Text(gpa['weighted'] ?? '4.12', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.forestSage)),
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
                      _buildSubTabButton(1, 'GPA What-If Simulator', Icons.calculate_outlined),
                      const SizedBox(width: 8),
                      _buildSubTabButton(2, 'Report Card & Transcript', Icons.picture_as_pdf_outlined),
                      if (state.currentRole == UserRole.teacher) ...[
                        const SizedBox(width: 8),
                        _buildSubTabButton(3, 'Teacher Gradebook Editor', Icons.edit_note_outlined),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Active Sub-Tab View
          if (_subTabIndex == 0)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Course Sidebar
                  Expanded(
                    flex: 4,
                    child: _buildCourseSidebar(state),
                  ),
                  const SizedBox(width: 20),
                  // Right Detailed Panel
                  Expanded(
                    flex: 8,
                    child: _buildCourseDetailPanel(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildCourseSidebar(state),
                  const SizedBox(height: 20),
                  _buildCourseDetailPanel(),
                ],
              )
          else if (_subTabIndex == 1)
            const WhatIfCalculatorView()
          else if (_subTabIndex == 2)
            const TranscriptView()
          else if (_subTabIndex == 3 && state.currentRole == UserRole.teacher)
            const TeacherGradebookEditor(),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(int index, String label, IconData? icon) {
    final isActive = _subTabIndex == index;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.forestSage : AppColors.borderLight,
        foregroundColor: isActive ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: icon != null ? Icon(icon, size: 14) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      onPressed: () => setState(() => _subTabIndex = index),
    );
  }

  Widget _buildCourseSidebar(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENROLLED COURSES (${state.courses.length})',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.courses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final course = state.courses[index];
            final isSelected = course.id == _selectedCourse.id;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _selectedCourse = course),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.warmSand : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.forestSage.withOpacity(0.5) : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: course.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                course.code.split('-')[0],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  course.teacherName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          course.letterGrade,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${course.currentPercentage}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.forestSage),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCourseDetailPanel() {
    return Column(
      children: [
        // Course Header Box
        Container(
          padding: const EdgeInsets.all(22),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _selectedCourse.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedCourse.code,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_selectedCourse.period, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedCourse.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instructor: ${_selectedCourse.teacherName} • Room: ${_selectedCourse.room} • Office Hours: ${_selectedCourse.officeHours}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedCourse.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _selectedCourse.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      _selectedCourse.letterGrade,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _selectedCourse.color),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 12),

              const Text(
                'WEIGHTED CATEGORY BREAKDOWN',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedCourse.categoryWeights.map((cat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.naturalParchment,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Text(cat.category, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        Text('${cat.currentAvg}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('Weight: ${cat.weight.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.forestSage)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Assignments List Card
        Container(
          padding: const EdgeInsets.all(22),
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
                  const Text(
                    'Graded Assignments & Tasks',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${_selectedCourse.assignments.length} total entries',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedCourse.assignments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return AssignmentRubricCard(
                    course: _selectedCourse,
                    assignment: _selectedCourse.assignments[index],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
