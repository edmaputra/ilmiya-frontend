import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';

class EditInstitutionalProfileDialog extends StatefulWidget {
  final SchoolResponse profile;
  final ValueChanged<SchoolResponse> onProfileUpdated;

  const EditInstitutionalProfileDialog({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SchoolResponse profile,
    required ValueChanged<SchoolResponse> onProfileUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditInstitutionalProfileDialog(
        profile: profile,
        onProfileUpdated: onProfileUpdated,
      ),
    );
  }

  @override
  State<EditInstitutionalProfileDialog> createState() =>
      _EditInstitutionalProfileDialogState();
}

class _EditInstitutionalProfileDialogState
    extends State<EditInstitutionalProfileDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _npsnCtrl;
  late String _accredStatus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _addrCtrl = TextEditingController(text: widget.profile.address);
    _emailCtrl = TextEditingController(text: widget.profile.contactEmail);
    _phoneCtrl = TextEditingController(text: widget.profile.contactPhone);
    _npsnCtrl = TextEditingController(
        text: widget.profile.governmentRegistrationNumber ?? '');
    _accredStatus = widget.profile.accreditationStatus ?? 'ACCREDITED_A';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _npsnCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final updated = await schoolService.updateProfile(UpdateSchoolRequest(
      name: _nameCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      governmentRegistrationNumber:
          _npsnCtrl.text.trim().isNotEmpty ? _npsnCtrl.text.trim() : null,
      accreditationStatus: _accredStatus,
    ));

    if (mounted) {
      widget.onProfileUpdated(updated);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Edit Institutional Profile',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'School Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addrCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Contact Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Contact Phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _npsnCtrl,
              decoration:
                  const InputDecoration(labelText: 'Govt Reg Number (NPSN)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _accredStatus,
              decoration:
                  const InputDecoration(labelText: 'Accreditation Status'),
              items: const [
                DropdownMenuItem(
                    value: 'ACCREDITED_A',
                    child: Text('Accredited A (Unggul)')),
                DropdownMenuItem(
                    value: 'ACCREDITED_B',
                    child: Text('Accredited B (Baik Sekali)')),
                DropdownMenuItem(
                    value: 'ACCREDITED_C', child: Text('Accredited C (Baik)')),
                DropdownMenuItem(
                    value: 'UNACCREDITED', child: Text('Unaccredited')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => _accredStatus = v);
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
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
