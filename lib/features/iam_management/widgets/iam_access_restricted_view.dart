import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../state/auth_notifier.dart';

class IamAccessRestrictedView extends StatelessWidget {
  final AuthNotifier auth;

  const IamAccessRestrictedView({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shieldAlert,
                size: 48, color: Color(0xFFD97706)),
            const SizedBox(height: 16),
            const Text(
              'IAM Console Restricted',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Identity & Access Management console requires platform administrator privileges (SUPERADMIN or iam:user:read).\n\nYour active role is ${auth.roles.isNotEmpty ? auth.roles.first : "School Administrator"} for tenant ${auth.tenantId}.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
