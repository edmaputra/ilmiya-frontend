import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../state/auth_notifier.dart';

class AppShellTenantDialog extends StatelessWidget {
  final AuthNotifier auth;

  const AppShellTenantDialog({super.key, required this.auth});

  static Future<void> show(BuildContext context, AuthNotifier auth) {
    return showDialog(
      context: context,
      builder: (ctx) => AppShellTenantDialog(auth: auth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantCtrl = TextEditingController(text: auth.tenantId);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.building, color: AppColors.forestSage, size: 20),
          SizedBox(width: 8),
          Text('Switch School Tenant', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select or enter target school tenant ID to isolate data partitions:',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tenantCtrl,
            decoration: InputDecoration(
              labelText: 'Tenant ID',
              prefixIcon: const Icon(LucideIcons.school, size: 16),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                avatar: const Icon(LucideIcons.school, size: 14),
                label:
                    const Text('Lincoln High', style: TextStyle(fontSize: 11)),
                onPressed: () => tenantCtrl.text = 'tenant-lincoln-high-001',
              ),
              ActionChip(
                avatar: const Icon(LucideIcons.graduationCap, size: 14),
                label:
                    const Text('SMAN 1 Ilmiya', style: TextStyle(fontSize: 11)),
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
