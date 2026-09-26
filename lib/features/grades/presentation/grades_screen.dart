import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/course.dart';
import '../../../core/models/user_profile.dart';
import '../../../state/app_state.dart';
import '../widgets/course_detail_panel.dart';
import '../widgets/course_sidebar.dart';
import '../widgets/grades_header_card.dart';
import '../widgets/teacher_gradebook_editor.dart';
import '../widgets/transcript_view.dart';
import '../widgets/what_if_calculator_view.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _subTabIndex =
      0; // 0: Roster, 1: Calculator, 2: Transcript, 3: Teacher Gradebook
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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top GPA Header & Sub-nav
          GradesHeaderCard(
            state: state,
            subTabIndex: _subTabIndex,
            onSubTabChanged: (index) => setState(() => _subTabIndex = index),
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
                    child: CourseSidebar(
                      state: state,
                      selectedCourse: _selectedCourse,
                      onSelectCourse: (c) =>
                          setState(() => _selectedCourse = c),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right Detailed Panel
                  Expanded(
                    flex: 8,
                    child: CourseDetailPanel(
                      selectedCourse: _selectedCourse,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  CourseSidebar(
                    state: state,
                    selectedCourse: _selectedCourse,
                    onSelectCourse: (c) => setState(() => _selectedCourse = c),
                  ),
                  const SizedBox(height: 20),
                  CourseDetailPanel(
                    selectedCourse: _selectedCourse,
                  ),
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
}
