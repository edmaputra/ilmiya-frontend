import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/presentation/login_dialog.dart';

class TenantAccessRestrictedView extends StatelessWidget {
  const TenantAccessRestrictedView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.earthyTerra.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(LucideIcons.shieldAlert,
                    color: AppColors.earthyTerra, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SuperAdmin Access Required',
              style: t.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The Tenant & School Profile Management console is restricted to Platform SuperAdmins with unrestricted multi-tenant authority.',
              textAlign: TextAlign.center,
              style: t.muted,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () => LoginDialog.show(context),
              icon: const Icon(LucideIcons.logIn, size: 16),
              label: const Text('Sign In with SuperAdmin Account'),
            ),
          ],
        ),
      ),
    );
  }
}
