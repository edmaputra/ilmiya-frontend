import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class AssignRoleDialog extends StatefulWidget {
  final UserResponse user;
  final List<RoleResponse> roles;

  final VoidCallback? onRoleAssigned;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.roles,
    this.onRoleAssigned,
  });

  static Future<void> show(
    BuildContext context, {
    required UserResponse user,
    required List<RoleResponse> roles,
    VoidCallback? onRoleAssigned,
  }) {
    if (roles.isEmpty) return Future.value();
    return showDialog(
      context: context,
      builder: (ctx) => AssignRoleDialog(
        user: user,
        roles: roles,
        onRoleAssigned: onRoleAssigned,
      ),
    );
  }

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  late String _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _selectedRoleId = widget.roles.first.id;
  }

  Future<void> _submit() async {
    await iamService.assignRole(
      userId: widget.user.id,
      roleId: _selectedRoleId,
      tenantId: widget.user.id,
    );

    if (mounted) {
      Navigator.of(context).pop();
      widget.onRoleAssigned?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role successfully assigned')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Assign Role: ${widget.user.fullName}',
              style: const TextStyle(fontFamily: 'serif', fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Role to assign to user in this tenant:',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRoleId,
            items: widget.roles
                .map((r) => DropdownMenuItem(
                    value: r.id, child: Text('${r.name} (${r.code})')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedRoleId = v);
              }
            },
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
          child: const Text('Assign Role'),
        ),
      ],
    );
  }
}
