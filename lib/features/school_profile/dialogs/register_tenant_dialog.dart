import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/school_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';

class RegisterTenantDialog extends StatefulWidget {
  final VoidCallback onTenantRegistered;

  const RegisterTenantDialog({
    super.key,
    required this.onTenantRegistered,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onTenantRegistered,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => RegisterTenantDialog(
        onTenantRegistered: onTenantRegistered,
      ),
    );
  }

  @override
  State<RegisterTenantDialog> createState() => _RegisterTenantDialogState();
}

class _RegisterTenantDialogState extends State<RegisterTenantDialog> {
  final _tenantIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _npsnCtrl = TextEditingController();
  String _accredStatus = 'ACCREDITED_A';
  String _grading = 'STANDARD_LETTER_GRADE';
  String _termLayout = 'SEMESTER';

  @override
  void dispose() {
    _tenantIdCtrl.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addrCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _npsnCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tId = _tenantIdCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (tId.isEmpty || name.isEmpty || code.isEmpty) {
      AppToast.showError(
        context,
        'Please complete Tenant ID, Name, and Institution Code.',
      );
      return;
    }

    try {
      try {
        await tenantService.createTenant(CreateTenantRequest(
          tenantId: tId,
          name: name,
          address: addr.isNotEmpty ? addr : 'Campus Address',
          contactEmail: email.isNotEmpty ? email : 'admin@$tId.edu',
          contactPhone: _phoneCtrl.text.trim().isNotEmpty
              ? _phoneCtrl.text.trim()
              : '+1 555 0100',
        ));
      } catch (_) {}

      await schoolService.registerSchool(RegisterSchoolRequest(
        tenantId: tId,
        name: name,
        institutionCode: code,
        address: addr.isNotEmpty ? addr : 'Campus Address',
        contactEmail: email.isNotEmpty ? email : 'admin@$tId.edu',
        contactPhone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : '+1 555 0100',
      ));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTenantRegistered();
        AppToast.showSuccess(
          context,
          'School tenant "$name" successfully registered!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to register tenant: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(LucideIcons.building2, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text(
            'Register School Tenant',
            style: TextStyle(fontFamily: 'serif', fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provision a new institutional partition with isolated databases, academic calendar, and IAM scope tree.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tenantIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tenant ID *',
                        hintText: 'e.g. tenant-crest-006',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Institution Code *',
                        hintText: 'e.g. CREST-006',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'School / Institution Name *',
                  hintText: 'e.g. Crescent International Academy',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Campus Address *',
                  hintText: '100 Campus Way, City, State',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email *',
                        hintText: 'admin@crescent.edu',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                        hintText: '+1 555 0199',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _npsnCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Govt Reg Number (NPSN)',
                        hintText: 'NPSN-50119283',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _accredStatus,
                      decoration:
                          const InputDecoration(labelText: 'Accreditation'),
                      items: const [
                        DropdownMenuItem(
                            value: 'ACCREDITED_A', child: Text('Accredited A')),
                        DropdownMenuItem(
                            value: 'ACCREDITED_B', child: Text('Accredited B')),
                        DropdownMenuItem(
                            value: 'ACCREDITED_C', child: Text('Accredited C')),
                        DropdownMenuItem(
                            value: 'UNACCREDITED', child: Text('Unaccredited')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _accredStatus = v);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _grading,
                      decoration:
                          const InputDecoration(labelText: 'Grading Framework'),
                      items: const [
                        DropdownMenuItem(
                          value: 'STANDARD_LETTER_GRADE',
                          child: Text('Standard Letter (GPA)'),
                        ),
                        DropdownMenuItem(
                          value: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
                          child: Text('Kurikulum Merdeka'),
                        ),
                        DropdownMenuItem(
                          value: 'NUMERIC_100_POINT',
                          child: Text('100-Point Numeric'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _grading = v);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _termLayout,
                      decoration:
                          const InputDecoration(labelText: 'Term Layout'),
                      items: const [
                        DropdownMenuItem(
                            value: 'SEMESTER', child: Text('Semester')),
                        DropdownMenuItem(
                            value: 'TRIMESTER', child: Text('Trimester')),
                        DropdownMenuItem(
                            value: 'QUARTER', child: Text('Quarter')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _termLayout = v);
                        }
                      },
                    ),
                  ),
                ],
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
          onPressed: _submit,
          child: const Text('Register Tenant'),
        ),
      ],
    );
  }
}
