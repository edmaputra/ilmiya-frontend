import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../core/utils/app_toast.dart';

class EditTenantDialog extends StatefulWidget {
  final SchoolResponse school;
  final VoidCallback onUpdated;

  const EditTenantDialog({
    super.key,
    required this.school,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SchoolResponse school,
    required VoidCallback onUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditTenantDialog(
        school: school,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<EditTenantDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _npsnCtrl;
  late String _accredStatus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.school.name);
    _addrCtrl = TextEditingController(text: widget.school.address);
    _emailCtrl = TextEditingController(text: widget.school.contactEmail);
    _phoneCtrl = TextEditingController(text: widget.school.contactPhone);
    _npsnCtrl = TextEditingController(
        text: widget.school.governmentRegistrationNumber ?? '');
    _accredStatus = widget.school.accreditationStatus ?? 'ACCREDITED_A';
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

  Future<void> _save() async {
    try {
      await schoolService.updateProfile(
        UpdateSchoolRequest(
          name: _nameCtrl.text.trim(),
          address: _addrCtrl.text.trim(),
          contactEmail: _emailCtrl.text.trim(),
          contactPhone: _phoneCtrl.text.trim(),
          governmentRegistrationNumber:
              _npsnCtrl.text.trim().isNotEmpty ? _npsnCtrl.text.trim() : null,
          accreditationStatus: _accredStatus,
        ),
        tenantId: widget.school.tenantId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated();
        AppToast.showSuccess(context, 'Tenant profile successfully updated.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update tenant profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Tenant: ${widget.school.institutionCode}',
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
                isExpanded: true,
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
                      value: 'ACCREDITED_C',
                      child: Text('Accredited C (Baik)')),
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
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
