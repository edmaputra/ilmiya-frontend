import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';
import '../../../core/services/academic_year_service.dart';

class AddAcademicTermDialog extends StatefulWidget {
  final String yearId;
  final Future<void> Function() onTermAdded;

  const AddAcademicTermDialog({
    super.key,
    required this.yearId,
    required this.onTermAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required String yearId,
    required Future<void> Function() onTermAdded,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddAcademicTermDialog(
        yearId: yearId,
        onTermAdded: onTermAdded,
      ),
    );
  }

  @override
  State<AddAcademicTermDialog> createState() => _AddAcademicTermDialogState();
}

class _AddAcademicTermDialogState extends State<AddAcademicTermDialog> {
  final _nameCtrl = TextEditingController(text: 'Semester 1 (Ganjil)');
  final _displayCtrl = TextEditingController(text: 'Ganjil Term');
  final _startCtrl = TextEditingController(text: '2026-07-15');
  final _endCtrl = TextEditingController(text: '2026-12-20');
  String _termType = 'SEMESTER_1';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _displayCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await academicYearService.addTerm(
      widget.yearId,
      AddAcademicTermRequest(
        name: _nameCtrl.text.trim(),
        displayName: _displayCtrl.text.trim(),
        type: _termType,
        startDate: _startCtrl.text.trim(),
        endDate: _endCtrl.text.trim(),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onTermAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.date_range_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Add Academic Term',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Term Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _displayCtrl,
            decoration: const InputDecoration(labelText: 'Display Label'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _termType,
            decoration: const InputDecoration(labelText: 'Term Type'),
            items: const [
              DropdownMenuItem(
                  value: 'SEMESTER_1', child: Text('Semester 1 (Ganjil)')),
              DropdownMenuItem(
                  value: 'SEMESTER_2', child: Text('Semester 2 (Genap)')),
              DropdownMenuItem(
                  value: 'TRIMESTER_1', child: Text('Trimester 1')),
              DropdownMenuItem(value: 'QUARTER_1', child: Text('Quarter 1')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _termType = v);
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _startCtrl,
            decoration: const InputDecoration(labelText: 'Start Date'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _endCtrl,
            decoration: const InputDecoration(labelText: 'End Date'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text('Add Term'),
        ),
      ],
    );
  }
}
