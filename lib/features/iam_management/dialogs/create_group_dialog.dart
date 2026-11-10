import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class CreateGroupDialog extends StatefulWidget {
  final Future<void> Function() onGroupCreated;

  const CreateGroupDialog({
    super.key,
    required this.onGroupCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onGroupCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateGroupDialog(
        onGroupCreated: onGroupCreated,
      ),
    );
  }

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _idpCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _idpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final groupName = _nameCtrl.text.trim();
    try {
      await iamService.createGroup(CreateGroupRequest(
        tenantId: apiClient.tenantId,
        code: _codeCtrl.text.trim().toUpperCase(),
        name: groupName,
        description:
            _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        externalIdpGroupName:
            _idpCtrl.text.trim().isNotEmpty ? _idpCtrl.text.trim() : null,
      ));

      if (mounted) {
        AppToast.showSuccess(
            context, "Group '$groupName' created successfully");
        Navigator.of(context).pop();
        await widget.onGroupCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to create group: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.group_add_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Create User Group',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Group Code'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Group code is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Group name is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _idpCtrl,
                decoration: const InputDecoration(
                  labelText: 'External IdP Mapping (Optional)',
                ),
              ),
            ],
          ),
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
              : const Text('Save Group'),
        ),
      ],
    );
  }
}
