import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/iam.dart';
import '../../features/auth/presentation/login_dialog.dart';
import '../../state/auth_notifier.dart';

class HeaderPersonaMenu extends StatelessWidget {
  final AuthNotifier auth;
  final String actorName;
  final String primaryRole;
  final bool isTablet;

  const HeaderPersonaMenu({
    super.key,
    required this.auth,
    required this.actorName,
    required this.primaryRole,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account & Personas',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      onSelected: (action) {
        if (action == 'login') {
          LoginDialog.show(context);
        } else if (action == 'logout') {
          auth.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed out successfully.')),
          );
        } else if (action.startsWith('persona:')) {
          final keyStr = action.replaceFirst('persona:', '');
          final personaKey = DemoPersonaKey.values.firstWhere(
            (k) => k.name == keyStr,
            orElse: () => DemoPersonaKey.superadmin,
          );
          auth.loginAsPersona(personaKey);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            '1-CLICK PERSONAS (RBAC)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...DemoPersonaKey.values.map((key) {
          final persona = DEMO_PERSONAS[key]!;
          final isActive = auth.user?.email == persona.email;
          return PopupMenuItem<String>(
            value: 'persona:${key.name}',
            child: Row(
              children: [
                Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 14,
                  color: isActive ? AppColors.forestSage : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${persona.roleLabel} • ${persona.email}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login, size: 16, color: AppColors.forestSage),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sign In with Custom Credentials...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: AppColors.earthyTerra),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.earthyTerra,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.forestSage.withOpacity(0.2),
              child: Text(
                actorName.isNotEmpty ? actorName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forestSage,
                ),
              ),
            ),
            if (isTablet) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      primaryRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestSage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
