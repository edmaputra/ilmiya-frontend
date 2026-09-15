import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class TeacherGradebookEditor extends StatefulWidget {
  const TeacherGradebookEditor({super.key});

  @override
  State<TeacherGradebookEditor> createState() => _TeacherGradebookEditorState();
}

class _TeacherGradebookEditorState extends State<TeacherGradebookEditor> {
  final List<Map<String, dynamic>> _roster = [
    {
      'name': 'Alex Rivera (You)',
      'id': 'STU-2026-8941',
      'project4': '98',
      'midterm2': '94',
      'pct': '96.4%',
      'grade': 'A',
    },
    {
      'name': 'Jordan Hayes',
      'id': 'STU-2026-8942',
      'project4': '92',
      'midterm2': '88',
      'pct': '90.2%',
      'grade': 'A-',
    },
    {
      'name': 'Samantha Lee',
      'id': 'STU-2026-8943',
      'project4': '100',
      'midterm2': '96',
      'pct': '98.0%',
      'grade': 'A+',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

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
                    'Teacher Gradebook & Roster Editor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Class: AP Computer Science A • Period 1 • 28 Enrolled Students',
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
                icon: const Icon(Icons.save_outlined, size: 14, color: AppColors.warmSand),
                label: const Text('Publish Grades & Notify', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () {
                  state.simulateNotification('grade');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.forestSage,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      content: const Text(
                        '📢 Scores published and push notifications dispatched to 28 students!',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Table
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: AppColors.naturalParchment,
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('STUDENT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        Expanded(flex: 2, child: Text('STUDENT ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        Expanded(flex: 2, child: Text('PROJECT 4 (100)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        Expanded(flex: 2, child: Text('MIDTERM 2 (100)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        Expanded(flex: 2, child: Text('OVERALL PCT', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                        Expanded(flex: 1, child: Text('GRADE', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _roster.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = _roster[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            Expanded(flex: 2, child: Text(item['id'], style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: SizedBox(
                                  width: 60,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(text: item['project4']),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: SizedBox(
                                  width: 60,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(text: item['midterm2']),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: Text(item['pct'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.forestSage))),
                            Expanded(flex: 1, child: Text(item['grade'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.forestSage))),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
