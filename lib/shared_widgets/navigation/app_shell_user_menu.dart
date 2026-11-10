import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../features/auth/presentation/login_dialog.dart';
import '../../state/auth_notifier.dart';
import 'header_tenant_switcher_dialog.dart';

class AppShellUserMenu extends StatelessWidget {
  final AuthNotifier auth;

  const AppShellUserMenu({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final user = auth.user;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Authenticated Staff';
    final email = user?.email ?? '';
    final primaryRole = auth.roles.isNotEmpty ? auth.roles.first : 'User';

    return PopupMenuButton<String>(
      tooltip: 'User Account Options',
      offset: const Offset(0, -140),
      icon: Icon(LucideIcons.moreVertical, size: 16, color: c.mutedForeground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      onSelected: (action) {
        if (action == 'switch_tenant') {
          HeaderTenantSwitcherDialog.show(context, auth);
        } else if (action == 'login') {
          LoginDialog.show(context);
        } else if (action == 'logout') {
          auth.logout();
          AppToast.showSuccess(context, 'Signed out successfully.');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  primaryRole,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestSage,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'switch_tenant',
          child: Row(
            children: [
              Icon(LucideIcons.building2,
                  size: 15, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Switch School Tenant...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              Icon(LucideIcons.logIn, size: 15, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Sign In with Another Account...',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut, size: 15, color: AppColors.earthyTerra),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.earthyTerra,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
