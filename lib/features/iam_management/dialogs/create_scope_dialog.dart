import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class CreateScopeDialog extends StatefulWidget {
  final String? parentId;
  final Future<void> Function() onScopeCreated;

  const CreateScopeDialog({
    super.key,
    this.parentId,
    required this.onScopeCreated,
  });

  static Future<void> show(
    BuildContext context, {
    String? parentId,
    required Future<void> Function() onScopeCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateScopeDialog(
        parentId: parentId,
        onScopeCreated: onScopeCreated,
      ),
    );
  }

  @override
  State<CreateScopeDialog> createState() => _CreateScopeDialogState();
}

class _CreateScopeDialogState extends State<CreateScopeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final scopeName = _nameCtrl.text.trim();
    try {
      await iamService.createScope(CreateScopeRequest(
        tenantId: apiClient.tenantId,
        code: _codeCtrl.text.trim().toUpperCase(),
        name: scopeName,
        parentId: widget.parentId,
      ));

      if (mounted) {
        AppToast.showSuccess(
            context, "Scope '$scopeName' created successfully");
        Navigator.of(context).pop();
        await widget.onScopeCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to create scope: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.account_tree_outlined, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Text(
            widget.parentId == null ? 'Create Root Scope' : 'Add Child Scope',
            style: const TextStyle(fontFamily: 'serif', fontSize: 18),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Scope Code (e.g. DEPT_SCIENCE)',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Scope code is required'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Scope Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Scope name is required'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Scope'),
        ),
      ],
    );
  }
}
