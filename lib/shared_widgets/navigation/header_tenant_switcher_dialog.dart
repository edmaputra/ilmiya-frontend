import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../state/auth_notifier.dart';

class HeaderTenantSwitcherDialog extends StatelessWidget {
  final AuthNotifier auth;

  const HeaderTenantSwitcherDialog({super.key, required this.auth});

  static Future<void> show(BuildContext context, AuthNotifier auth) {
    return showDialog(
      context: context,
      builder: (ctx) => HeaderTenantSwitcherDialog(auth: auth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantCtrl = TextEditingController(text: auth.tenantId);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.domain_rounded, color: AppColors.forestSage),
          SizedBox(width: 8),
          Text('Switch Multi-Tenant Context', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specify target school tenant ID to isolate data partitions:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tenantCtrl,
            decoration: const InputDecoration(
              labelText: 'Tenant ID',
              prefixIcon: Icon(Icons.apartment_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                avatar: const Icon(Icons.school,
                    size: 14, color: AppColors.forestSage),
                label: const Text('Lincoln High (tenant-lincoln-high-001)',
                    style: TextStyle(fontSize: 11)),
                onPressed: () => tenantCtrl.text = 'tenant-lincoln-high-001',
              ),
              ActionChip(
                avatar: const Icon(Icons.account_balance,
                    size: 14, color: AppColors.forestSage),
                label: const Text('SMAN 1 Ilmiya (tenant-sma1-ilmiya-002)',
                    style: TextStyle(fontSize: 11)),
                onPressed: () => tenantCtrl.text = 'tenant-sma1-ilmiya-002',
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final newTenant = tenantCtrl.text.trim();
            if (newTenant.isNotEmpty) {
              Navigator.of(context).pop();
              try {
                await auth.switchTenant(newTenant);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Switched tenant to $newTenant')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error switching tenant: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Switch Tenant'),
        ),
      ],
    );
  }
}
