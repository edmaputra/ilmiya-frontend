import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

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
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await iamService.createScope(CreateScopeRequest(
      code: _codeCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      parentId: widget.parentId,
    ));

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onScopeCreated();
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(
              labelText: 'Scope Code (e.g. DEPT_SCIENCE)',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Scope Name'),
          ),
        ],
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
          child: const Text('Save Scope'),
        ),
      ],
    );
  }
}
