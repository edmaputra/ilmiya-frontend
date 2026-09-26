import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/iam.dart';

class IamRolesTab extends StatelessWidget {
  final List<RoleResponse> roles;
  final bool canCreateRole;
  final VoidCallback onCreateRole;

  const IamRolesTab({
    super.key,
    required this.roles,
    required this.canCreateRole,
    required this.onCreateRole,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Role-Based Access Control (RBAC) Matrix',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateRole ? onCreateRole : null,
                icon: Icon(canCreateRole ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Custom Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: roles.length,
              itemBuilder: (ctx, i) {
                final r = roles[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: KiteRadius.allMd,
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
                              style: t.small.copyWith(
                                fontWeight: FontWeight.bold,
                                color: c.foreground,
                              ),
                            ),
                          ),
                          if (r.isSystemRole)
                            const KiteBadge('SYSTEM', tone: KiteTone.info),
                        ],
                      ),
                      Text(
                        r.code,
                        style: t.small.copyWith(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: c.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.description ?? '',
                        style: t.small
                            .copyWith(fontSize: 11, color: c.mutedForeground),
                        maxLines: 2,
                      ),
                      const Spacer(),
                      Text(
                        'Permissions (${r.permissions.length}):',
                        style: t.small.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: c.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: r.permissions
                                .map((p) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: c.accent,
                                        borderRadius: KiteRadius.allSm,
                                        border: Border.all(color: c.border),
                                      ),
                                      child: Text(
                                        p,
                                        style: t.small.copyWith(
                                          fontSize: 8,
                                          fontFamily: 'monospace',
                                          color: c.foreground,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
