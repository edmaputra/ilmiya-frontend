import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../core/utils/app_toast.dart';

class OperationalSettingsDialog extends StatefulWidget {
  final SchoolResponse profile;
  final ValueChanged<SchoolResponse> onSettingsUpdated;

  const OperationalSettingsDialog({
    super.key,
    required this.profile,
    required this.onSettingsUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SchoolResponse profile,
    required ValueChanged<SchoolResponse> onSettingsUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => OperationalSettingsDialog(
        profile: profile,
        onSettingsUpdated: onSettingsUpdated,
      ),
    );
  }

  @override
  State<OperationalSettingsDialog> createState() =>
      _OperationalSettingsDialogState();
}

class _OperationalSettingsDialogState extends State<OperationalSettingsDialog> {
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
    _selectedDays = List<String>.from(widget.profile.workingDays);
    _grading = widget.profile.gradingPreference;
    _termLayout = widget.profile.termLayout;
  }

  Future<void> _submit() async {
    try {
      final updated =
          await schoolService.configureSettings(ConfigureSchoolSettingsRequest(
        workingDays: _selectedDays,
        gradingPreference: _grading,
        termLayout: _termLayout,
      ));

      if (mounted) {
        widget.onSettingsUpdated(updated);
        Navigator.of(context).pop();
        AppToast.showSuccess(
            context, 'Operational settings updated successfully');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to save operational settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.tune_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Operational Settings',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('School Working Days:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
              value: _grading,
              decoration: const InputDecoration(labelText: 'Grading Framework'),
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
              value: _termLayout,
              decoration:
                  const InputDecoration(labelText: 'Academic Term Layout'),
              items: const [
                DropdownMenuItem(
                    value: 'SEMESTER',
                    child: Text('Semester (2 Terms / Year)')),
                DropdownMenuItem(
                    value: 'TRIMESTER',
                    child: Text('Trimester (3 Terms / Year)')),
                DropdownMenuItem(
                    value: 'QUARTER', child: Text('Quarter (4 Terms / Year)')),
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
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}
