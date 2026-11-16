import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../core/utils/app_toast.dart';

class TenantSettingsDialog extends StatefulWidget {
  final SchoolResponse school;
  final VoidCallback onSaved;

  const TenantSettingsDialog({
    super.key,
    required this.school,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required SchoolResponse school,
    required VoidCallback onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => TenantSettingsDialog(
        school: school,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<TenantSettingsDialog> createState() => _TenantSettingsDialogState();
}

class _TenantSettingsDialogState extends State<TenantSettingsDialog> {
  static const List<String> _allDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

  late final List<String> _selectedDays;
  late String _grading;
  late String _termLayout;

  @override
  void initState() {
    super.initState();
    _selectedDays = List<String>.from(widget.school.workingDays);
    _grading = widget.school.gradingPreference;
    _termLayout = widget.school.termLayout;
  }

  Future<void> _save() async {
    try {
      await schoolService.configureSettings(
        ConfigureSchoolSettingsRequest(
          workingDays: _selectedDays,
          gradingPreference: _grading,
          termLayout: _termLayout,
        ),
        tenantId: widget.school.tenantId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        AppToast.showSuccess(context, 'Operational rules successfully saved.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to save operational rules: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Operational Rules: ${widget.school.name}',
              style: const TextStyle(fontFamily: 'serif', fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'School Working Days:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allDays.map((day) {
                  final isSel = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: isSel,
                    selectedColor: AppColors.warmSand,
                    checkmarkColor: AppColors.forestSage,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedDays.add(day);
                        } else {
                          if (_selectedDays.length > 1) {
                            _selectedDays.remove(day);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _grading,
                decoration:
                    const InputDecoration(labelText: 'Grading Framework'),
                items: const [
                  DropdownMenuItem(
                    value: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
                    child: Text('Kurikulum Merdeka (Capaian Pembelajaran)'),
                  ),
                  DropdownMenuItem(
                    value: 'STANDARD_LETTER_GRADE',
                    child: Text('Standard Letter Grade (A-F GPA)'),
                  ),
                  DropdownMenuItem(
                    value: 'NUMERIC_100_POINT',
                    child: Text('100-Point Numeric Scale'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _grading = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _termLayout,
                decoration:
                    const InputDecoration(labelText: 'Academic Term Layout'),
                items: const [
                  DropdownMenuItem(
                    value: 'SEMESTER',
                    child: Text('Semester (2 Terms / Year)'),
                  ),
                  DropdownMenuItem(
                    value: 'TRIMESTER',
                    child: Text('Trimester (3 Terms / Year)'),
                  ),
                  DropdownMenuItem(
                    value: 'QUARTER',
                    child: Text('Quarter (4 Terms / Year)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _termLayout = v);
                  }
                },
              ),
            ],
          ),
        ),
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
          onPressed: _save,
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}
