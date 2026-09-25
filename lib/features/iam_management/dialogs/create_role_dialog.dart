import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class CreateRoleDialog extends StatefulWidget {
  final Future<void> Function() onRoleCreated;

  const CreateRoleDialog({
    super.key,
    required this.onRoleCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onRoleCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateRoleDialog(
        onRoleCreated: onRoleCreated,
      ),
    );
  }

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  static const List<String> _allPermissions = [
    'school:profile:read',
    'school:profile:write',
    'school:settings:manage',
    'academic:year:read',
    'academic:year:write',
    'academic:course:read',
    'academic:course:write',
    'student:profile:read',
    'student:profile:write',
    'attendance:record:read',
    'attendance:record:create',
    'exam:grade:create',
    'iam:user:create',
    'iam:user:read',
    'iam:role:create',
    'iam:group:create',
    'iam:scope:create',
  ];

  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _selectedPerms = <String>{'school:profile:read'};

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await iamService.createRole(CreateRoleRequest(
      code: _codeCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      permissions: _selectedPerms.toList(),
    ));

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onRoleCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.add_moderator_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Create Custom Role',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Role Code (e.g. LAB_TECH)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Role Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 14),
            const Text(
              'Permissions Matrix:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allPermissions.map((perm) {
                final isSel = _selectedPerms.contains(perm);
                return FilterChip(
                  label: Text(
                    perm,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                  selected: isSel,
                  selectedColor: AppColors.warmSand,
                  checkmarkColor: AppColors.forestSage,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedPerms.add(perm);
                      } else {
                        _selectedPerms.remove(perm);
                      }
                    });
                  },
                );
              }).toList(),
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
          child: const Text('Create Role'),
        ),
      ],
    );
  }
}
