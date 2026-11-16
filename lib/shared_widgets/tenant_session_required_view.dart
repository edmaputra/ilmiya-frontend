import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../state/app_state.dart';
import '../state/auth_notifier.dart';
import 'navigation/app_shell_tenant_dialog.dart';

class TenantSessionRequiredView extends StatelessWidget {
  final String sectionName;

  const TenantSessionRequiredView({
    super.key,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.read<AppState>();
    final auth = context.read<AuthNotifier>();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.forestSage.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.building2,
                  color: AppColors.forestSage,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tenant Session Required',
              style: t.h3.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'As a Platform SuperAdmin, you are currently in global platform mode. To view and manage $sectionName, please switch your active session to the target school tenant.',
              textAlign: TextAlign.center,
              style: t.muted.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => state.setTab(8),
                  icon: const Icon(LucideIcons.building2, size: 16),
                  label: const Text('Go to Tenant Console'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => AppShellTenantDialog.show(context, auth),
                  icon: const Icon(LucideIcons.arrowRightLeft, size: 16),
                  label: const Text('Switch Tenant Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
