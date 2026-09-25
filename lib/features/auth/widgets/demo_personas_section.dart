import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../state/auth_notifier.dart';

class DemoPersonasSection extends StatelessWidget {
  final AuthNotifier auth;
  final DemoPersonaKey? loadingPersona;
  final ValueChanged<DemoPersonaKey> onSelectPersona;

  const DemoPersonasSection({
    super.key,
    required this.auth,
    required this.loadingPersona,
    required this.onSelectPersona,
  });

  IconData _getPersonaIcon(DemoPersonaKey key) {
    switch (key) {
      case DemoPersonaKey.superadmin:
        return Icons.security_rounded;
      case DemoPersonaKey.principal:
        return Icons.account_balance_rounded;
      case DemoPersonaKey.teacher:
        return Icons.school_rounded;
      case DemoPersonaKey.student:
        return Icons.person_rounded;
      case DemoPersonaKey.parent:
        return Icons.family_restroom_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.touch_app_outlined,
                size: 16, color: AppColors.forestSage),
            SizedBox(width: 6),
            Text(
              '1-Click Demo Personas',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Instantly authenticate without passwords to test RBAC roles & action guards:',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        ...DemoPersonaKey.values.map((key) {
          final persona = DEMO_PERSONAS[key]!;
          final isSelected = auth.user?.email == persona.email;
          final isLoading = loadingPersona == key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: auth.isLoading ? null : () => onSelectPersona(key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.warmSand : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forestSage
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelected
                          ? AppColors.forestSage
                          : AppColors.surfaceMuted,
                      child: Icon(
                        _getPersonaIcon(key),
                        size: 18,
                        color: isSelected
                            ? AppColors.surfaceWhite
                            : AppColors.forestSage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                persona.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  persona.roleLabel,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestSage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            persona.description,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.forestSage),
                      )
                    else
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
