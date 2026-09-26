import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/academic_year.dart';
import '../../../core/services/academic_year_service.dart';

class CreateAcademicYearDialog extends StatefulWidget {
  final Future<void> Function() onYearCreated;

  const CreateAcademicYearDialog({
    super.key,
    required this.onYearCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onYearCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateAcademicYearDialog(onYearCreated: onYearCreated),
    );
  }

  @override
  State<CreateAcademicYearDialog> createState() =>
      _CreateAcademicYearDialogState();
}

class _CreateAcademicYearDialogState extends State<CreateAcademicYearDialog> {
  final _nameCtrl = TextEditingController(text: 'Tahun Ajaran 2027/2028');
  final _startCtrl = TextEditingController(text: '2027-07-15');
  final _endCtrl = TextEditingController(text: '2028-06-25');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await academicYearService.createAcademicYear(CreateAcademicYearRequest(
      name: _nameCtrl.text.trim(),
      startDate: _startCtrl.text.trim(),
      endDate: _endCtrl.text.trim(),
    ));

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onYearCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('New Academic Year',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Academic Year Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _startCtrl,
            decoration:
                const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _endCtrl,
            decoration:
                const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
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
          child: const Text('Create Calendar Year'),
        ),
      ],
    );
  }
}
