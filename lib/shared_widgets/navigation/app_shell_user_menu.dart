import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/iam.dart';
import '../../features/auth/presentation/login_dialog.dart';
import '../../state/auth_notifier.dart';

class AppShellUserMenu extends StatelessWidget {
  final AuthNotifier auth;

  const AppShellUserMenu({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);

    return PopupMenuButton<String>(
      tooltip: 'User Account & RBAC Personas',
      offset: const Offset(0, -140),
      icon: Icon(LucideIcons.moreVertical, size: 16, color: c.mutedForeground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
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
            'SWITCH DEMO PERSONA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFF94A3B8),
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
                  isActive ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  size: 14,
                  color:
                      isActive ? AppColors.forestSage : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      persona.roleLabel,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
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
              Icon(LucideIcons.logIn, size: 15, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Sign In with Credentials...',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut, size: 15, color: AppColors.earthyTerra),
              SizedBox(width: 8),
              Text('Sign Out',
                  style: TextStyle(fontSize: 12, color: AppColors.earthyTerra)),
            ],
          ),
        ),
      ],
    );
  }
}
