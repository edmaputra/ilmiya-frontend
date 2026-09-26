import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';

class TenantStatusConfirmationDialog extends StatelessWidget {
  final SchoolResponse school;
  final String newStatus;

  const TenantStatusConfirmationDialog({
    super.key,
    required this.school,
    required this.newStatus,
  });

  static Future<bool?> show(
    BuildContext context, {
    required SchoolResponse school,
    required String newStatus,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => TenantStatusConfirmationDialog(
        school: school,
        newStatus: newStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionName = newStatus == 'ACTIVE' ? 'activate' : 'suspend';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            newStatus == 'ACTIVE'
                ? LucideIcons.checkCircle2
                : LucideIcons.alertTriangle,
            color: newStatus == 'ACTIVE'
                ? AppColors.forestSage
                : AppColors.earthyTerra,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Confirm Tenant Status Change',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to $actionName institutional tenant "${school.name}" (${school.tenantId})?',
        style: const TextStyle(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: newStatus == 'ACTIVE'
                ? AppColors.forestSage
                : AppColors.earthyTerra,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(newStatus == 'ACTIVE' ? 'Activate' : 'Suspend'),
        ),
      ],
    );
  }
}
