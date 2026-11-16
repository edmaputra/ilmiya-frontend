import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/school_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';

class RegisterSchoolDialog extends StatefulWidget {
  final String? initialTenantId;
  final VoidCallback onSchoolRegistered;

  const RegisterSchoolDialog({
    super.key,
    this.initialTenantId,
    required this.onSchoolRegistered,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialTenantId,
    required VoidCallback onSchoolRegistered,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => RegisterSchoolDialog(
        initialTenantId: initialTenantId,
        onSchoolRegistered: onSchoolRegistered,
      ),
    );
  }

  @override
  State<RegisterSchoolDialog> createState() => _RegisterSchoolDialogState();
}

class _RegisterSchoolDialogState extends State<RegisterSchoolDialog> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _npsnCtrl = TextEditingController();

  List<TenantResponse> _availableTenants = [];
  String? _selectedTenantId;
  bool _isLoadingTenants = true;

  @override
  void initState() {
    super.initState();
    _selectedTenantId = widget.initialTenantId;
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      final tenants = await tenantService.listTenants();
      if (mounted) {
        setState(() {
          _availableTenants = tenants;
          if (_selectedTenantId == null && tenants.isNotEmpty) {
            _selectedTenantId = tenants.first.id;
          }
          _isLoadingTenants = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTenants = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addrCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _npsnCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tenantId = _selectedTenantId;
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (tenantId == null || tenantId.isEmpty) {
      AppToast.showError(
          context, 'Please select a parent foundation / tenant.');
      return;
    }

    if (name.isEmpty || code.isEmpty) {
      AppToast.showError(
          context, 'Please complete School Name and Institution Code.');
      return;
    }

    try {
      await schoolService.registerSchool(RegisterSchoolRequest(
        tenantId: tenantId,
        name: name,
        institutionCode: code,
        address: addr.isNotEmpty ? addr : 'Campus Address',
        contactEmail: email.isNotEmpty ? email : 'admin@$code.sch.id',
        contactPhone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : '+62 21 555 0100',
      ));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSchoolRegistered();
        AppToast.showSuccess(
          context,
          'School campus "$name" registered successfully under tenant $tenantId!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to register school: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(LucideIcons.school, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text(
            'Register School Campus / Unit',
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
                'Register an institutional campus (e.g. SD, SMP, SMA) under a parent Foundation (Yayasan).',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Foundation Selector
              if (_isLoadingTenants)
                const LinearProgressIndicator()
              else ...[
                const Text(
                  'Parent Foundation (Yayasan) *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTenantId,
                      items: _availableTenants
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text('${t.name} (${t.id})'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTenantId = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'School Campus Name *',
                        hintText: 'e.g. SMA Islam Al-Azhar 1',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Institution Code *',
                        hintText: 'e.g. AZHAR-SMA-01',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Campus Address',
                  hintText: 'e.g. Jl. Sisingamangaraja No. 1, Jakarta Selatan',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        hintText: 'office@alazhar.sch.id',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                        hintText: '+62 21 7278 8900',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _npsnCtrl,
                decoration: const InputDecoration(
                  labelText: 'Govt Reg Number (NPSN)',
                  hintText: 'NPSN-20104432',
                ),
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
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Register Campus'),
        ),
      ],
    );
  }
}
