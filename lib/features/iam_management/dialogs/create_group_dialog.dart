import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

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
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _idpCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _idpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await iamService.createGroup(CreateGroupRequest(
      code: _codeCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      externalIdpGroupName:
          _idpCtrl.text.trim().isNotEmpty ? _idpCtrl.text.trim() : null,
    ));

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onGroupCreated();
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(labelText: 'Group Code'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Group Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _idpCtrl,
            decoration: const InputDecoration(
              labelText: 'External IdP Mapping (Optional)',
            ),
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
          child: const Text('Create Group'),
        ),
      ],
    );
  }
}
