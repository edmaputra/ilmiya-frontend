import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../features/auth/presentation/login_dialog.dart';
import '../../state/auth_notifier.dart';
import 'header_tenant_switcher_dialog.dart';

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
    final user = auth.user;
    final email = user?.email ?? '';

    return PopupMenuButton<String>(
      tooltip: 'Account Options',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
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
                actorName,
                style: const TextStyle(
                  fontSize: 13,
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
                    fontSize: 11,
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
              Icon(Icons.apartment_rounded,
                  size: 16, color: AppColors.forestSage),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Switch School Tenant...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login_rounded, size: 16, color: AppColors.forestSage),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sign In with Another Account...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  size: 16, color: AppColors.earthyTerra),
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
                constraints: const BoxConstraints(maxWidth: 120),
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
