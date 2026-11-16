import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class EditRoleDialog extends StatefulWidget {
  final RoleResponse role;
  final Future<void> Function() onRoleUpdated;

  const EditRoleDialog({
    super.key,
    required this.role,
    required this.onRoleUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required RoleResponse role,
    required Future<void> Function() onRoleUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditRoleDialog(
        role: role,
        onRoleUpdated: onRoleUpdated,
      ),
    );
  }

  @override
  State<EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<EditRoleDialog> {
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
    'iam:user:status',
    'iam:user:assign-role',
    'iam:user:delete',
    'iam:role:create',
    'iam:role:read',
    'iam:role:update',
    'iam:role:delete',
    'iam:group:create',
    'iam:group:read',
    'iam:scope:create',
    'iam:scope:read',
    'audit:log:read',
  ];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final Set<String> _selectedPerms;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.role.name);
    _descCtrl = TextEditingController(text: widget.role.description ?? '');
    _selectedPerms = Set<String>.from(widget.role.permissions);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a role name.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await iamService.updateRole(
        widget.role.id,
        UpdateRoleRequest(
          name: name,
          description: _descCtrl.text.trim(),
          permissions: _selectedPerms.toList(),
        ),
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        await widget.onRoleUpdated();
        messenger.showSnackBar(
          SnackBar(
              content:
                  Text('Role "${widget.role.code}" updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e')),
        );
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
              'Edit Role: ${widget.role.code}',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Role Code: ${widget.role.code} ${widget.role.isSystemRole ? '(System Role)' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Permissions Matrix:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allPermissions.map((perm) {
                  final isChecked = _selectedPerms.contains(perm);
                  return FilterChip(
                    label: Text(perm, style: const TextStyle(fontSize: 10)),
                    selected: isChecked,
                    selectedColor: AppColors.forestSage.withOpacity(0.2),
                    checkmarkColor: AppColors.forestSage,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
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
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
