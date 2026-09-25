import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';

class TenantQuotasTab extends StatelessWidget {
  const TenantQuotasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        size: 20, color: AppColors.forestSage),
                    const SizedBox(width: 8),
                    Text(
                      'Multi-Tenant Platform Governance & Quotas',
                      style: t.large.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Platform-level default resource quotas, storage thresholds, and cross-tenant data isolation rules.',
                  style: t.muted,
                ),
                Divider(height: 24, color: c.border),
                _quotaRow(context, 'Max Active Student Accounts',
                    '1,000 / Tenant', 0.65),
                const SizedBox(height: 16),
                _quotaRow(context, 'Max Faculty & Staff Accounts',
                    '150 / Tenant', 0.42),
                const SizedBox(height: 16),
                _quotaRow(
                    context, 'Cloud Storage Volume', '50 GB / Tenant', 0.28),
                const SizedBox(height: 16),
                _quotaRow(
                    context, 'Monthly REST API Calls', '500,000 reqs', 0.19),
              ],
            ),
          ),
          const SizedBox(height: 16),
          KiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.lock,
                        size: 18, color: AppColors.forestSage),
                    const SizedBox(width: 8),
                    Text(
                      'Data Isolation & Security Policies',
                      style: t.large.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(height: 24, color: c.border),
                _policyTile(
                  context,
                  'Row-Level Tenant Isolation',
                  'Every SQL and storage query enforces strict X-Tenant-ID isolation preventing cross-school leakage.',
                  true,
                ),
                const SizedBox(height: 10),
                _policyTile(
                  context,
                  'End-to-End Chat Encryption (E2EE)',
                  'Direct messages between teachers and parents are cryptographically signed and encrypted.',
                  true,
                ),
                const SizedBox(height: 10),
                _policyTile(
                  context,
                  'Multi-Campus Hierarchical Scopes',
                  'Allows enterprise institutions to establish subsidiary branches (SMP/SMA) under one parent tenant.',
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quotaRow(
      BuildContext context, String title, String limit, double progress) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(title, style: t.small.copyWith(fontWeight: FontWeight.w600)),
            Text(limit, style: t.muted.copyWith(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: c.muted,
          color: AppColors.forestSage,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _policyTile(
      BuildContext context, String title, String subtitle, bool isEnabled) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isEnabled ? LucideIcons.checkCircle2 : LucideIcons.circle,
          size: 16,
          color: isEnabled ? AppColors.forestSage : c.mutedForeground,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: t.muted.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
