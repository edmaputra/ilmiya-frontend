import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class SchoolSuperadminBanner extends StatelessWidget {
  const SchoolSuperadminBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.forestSage.withOpacity(0.08),
        borderRadius: KiteRadius.allMd,
        border: Border.all(color: AppColors.forestSage.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldCheck,
              color: AppColors.forestSage, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Platform SuperAdmin Mode: You have global multi-tenant authority. Open the dedicated Tenant Console to provision and manage all institutions.',
              style: t.small.copyWith(
                color: AppColors.forestSage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forestSage,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () => context.read<AppState>().setTab(8),
            icon: const Icon(LucideIcons.building2, size: 14),
            label: const Text('Tenant Console', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
