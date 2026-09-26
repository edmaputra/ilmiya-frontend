import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class CreateUserDialog extends StatefulWidget {
  final Future<void> Function() onUserCreated;

  const CreateUserDialog({
    super.key,
    required this.onUserCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onUserCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateUserDialog(
        onUserCreated: onUserCreated,
      ),
    );
  }

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSuperAdmin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await iamService.createUser(CreateUserRequest(
      email: _emailCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      isPlatformSuperAdmin: _isSuperAdmin,
    ));

    if (mounted) {
      Navigator.of(context).pop();
      await widget.onUserCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.person_add_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Create New User',
              style: TextStyle(fontFamily: 'serif', fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email Address'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Platform SuperAdmin',
                style: TextStyle(fontSize: 13)),
            value: _isSuperAdmin,
            onChanged: (v) => setState(() => _isSuperAdmin = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
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
          child: const Text('Create User'),
        ),
      ],
    );
  }
}
