import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';

class RegisterFoundationDialog extends StatefulWidget {
  final VoidCallback onFoundationRegistered;

  const RegisterFoundationDialog({
    super.key,
    required this.onFoundationRegistered,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onFoundationRegistered,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => RegisterFoundationDialog(
        onFoundationRegistered: onFoundationRegistered,
      ),
    );
  }

  @override
  State<RegisterFoundationDialog> createState() =>
      _RegisterFoundationDialogState();
}

class _RegisterFoundationDialogState extends State<RegisterFoundationDialog> {
  final _tenantIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _entityNumberCtrl = TextEditingController();
  final _regTypeCtrl = TextEditingController(text: 'PRIVATE_FOUNDATION');
  final _addrCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _tenantIdCtrl.dispose();
    _nameCtrl.dispose();
    _entityNumberCtrl.dispose();
    _regTypeCtrl.dispose();
    _addrCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tId = _tenantIdCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final entityNumber = _entityNumberCtrl.text.trim();
    final regType = _regTypeCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (tId.isEmpty || name.isEmpty) {
      AppToast.showError(
        context,
        'Please complete Tenant ID and Foundation Name.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await tenantService.createTenant(CreateTenantRequest(
        tenantId: tId,
        name: name,
        legalEntityNumber: entityNumber.isNotEmpty ? entityNumber : null,
        registrationType: regType.isNotEmpty ? regType : 'PRIVATE_FOUNDATION',
        address: addr.isNotEmpty ? addr : 'Headquarters Address',
        contactEmail: email.isNotEmpty ? email : 'admin@$tId.or.id',
        contactPhone: phone.isNotEmpty ? phone : '+62 21 555 0100',
      ));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onFoundationRegistered();
        AppToast.showSuccess(
          context,
          'Foundation / Tenant "$name" registered successfully.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppToast.showError(context, 'Failed to register foundation: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.landmark, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text(
            'Register Foundation / Tenant',
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
                'Provision a parent Foundation (Yayasan) organization to govern multiple school campuses and centralize administrative oversight.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tenantIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Foundation / Tenant ID *',
                        hintText: 'e.g. tenant-alazhar-001',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Foundation Name (Yayasan) *',
                        hintText: 'e.g. Yayasan Pesantren Islam',
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
                      controller: _entityNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Legal Entity / AHU Number',
                        hintText: 'e.g. AHU-0012345.AH.01.04',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _regTypeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Registration Type',
                        hintText: 'e.g. PRIVATE_FOUNDATION',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Headquarters Address',
                  hintText: 'e.g. Jl. Sisingamangaraja, Jakarta Selatan',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Official Email',
                        hintText: 'sekretariat@alazhar.or.id',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Official Phone',
                        hintText: '+62 21 7278368',
                      ),
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
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Register Foundation'),
        ),
      ],
    );
  }
}
