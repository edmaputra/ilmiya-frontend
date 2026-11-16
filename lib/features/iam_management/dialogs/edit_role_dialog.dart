import 'package:flutter/material.dart';

import '../../../core/models/iam.dart';
import 'create_role_dialog.dart';

class EditRoleDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CreateRoleDialog(
      roleToEdit: role,
      onRoleCreated: onRoleUpdated,
    );
  }
}
