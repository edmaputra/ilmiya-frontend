import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';

class EditFoundationDialog extends StatefulWidget {
  final TenantResponse tenant;
  final VoidCallback onUpdated;

  const EditFoundationDialog({
    super.key,
    required this.tenant,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required TenantResponse tenant,
    required VoidCallback onUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditFoundationDialog(
        tenant: tenant,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<EditFoundationDialog> createState() => _EditFoundationDialogState();
}

class _EditFoundationDialogState extends State<EditFoundationDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _entityNumberCtrl;
  late final TextEditingController _regTypeCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tenant.name);
    _entityNumberCtrl =
        TextEditingController(text: widget.tenant.legalEntityNumber ?? '');
    _regTypeCtrl =
        TextEditingController(text: widget.tenant.registrationType ?? '');
    _addrCtrl = TextEditingController(text: widget.tenant.address);
    _emailCtrl = TextEditingController(text: widget.tenant.contactEmail);
    _phoneCtrl = TextEditingController(text: widget.tenant.contactPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entityNumberCtrl.dispose();
    _regTypeCtrl.dispose();
    _addrCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.showError(context, 'Foundation Name cannot be empty.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await tenantService.updateTenant(
        widget.tenant.id,
        UpdateTenantRequest(
          name: name,
          legalEntityNumber: _entityNumberCtrl.text.trim().isNotEmpty
              ? _entityNumberCtrl.text.trim()
              : null,
          registrationType: _regTypeCtrl.text.trim().isNotEmpty
              ? _regTypeCtrl.text.trim()
              : widget.tenant.registrationType,
          address: _addrCtrl.text.trim().isNotEmpty
              ? _addrCtrl.text.trim()
              : widget.tenant.address,
          contactEmail: _emailCtrl.text.trim().isNotEmpty
              ? _emailCtrl.text.trim()
              : widget.tenant.contactEmail,
          contactPhone: _phoneCtrl.text.trim().isNotEmpty
              ? _phoneCtrl.text.trim()
              : widget.tenant.contactPhone,
          status: widget.tenant.status,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated();
        AppToast.showSuccess(context, 'Foundation updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppToast.showError(context, 'Failed to update foundation: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.landmark, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Foundation: ${widget.tenant.id}',
              style: const TextStyle(fontFamily: 'serif', fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
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
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Foundation Name (Yayasan) *',
                ),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Official Phone',
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
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
