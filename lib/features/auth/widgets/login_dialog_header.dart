import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoginDialogHeader extends StatelessWidget {
  final bool isStandalone;
  final VoidCallback? onClose;

  const LoginDialogHeader({
    super.key,
    required this.isStandalone,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warmSand,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Icon(Icons.shield_outlined,
              color: AppColors.forestSage, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warmSand,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text(
                      'ED-IAM SECURITY PORTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.forestSage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Ilmiya Institutional Access',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Select a demo persona to test RBAC permissions or sign in with credentials.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        if (!isStandalone)
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textMuted,
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}
