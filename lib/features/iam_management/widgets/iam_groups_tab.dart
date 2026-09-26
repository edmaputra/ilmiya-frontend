import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/iam.dart';

class IamGroupsTab extends StatelessWidget {
  final List<GroupResponse> groups;
  final bool canCreateGroup;
  final VoidCallback onCreateGroup;

  const IamGroupsTab({
    super.key,
    required this.groups,
    required this.canCreateGroup,
    required this.onCreateGroup,
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
                'User Groups & Directory Integrations',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateGroup ? onCreateGroup : null,
                icon: Icon(canCreateGroup ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Group'),
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
            child: ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final g = groups[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: KiteRadius.allMd,
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.users, color: c.foreground, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name,
                              style: t.small.copyWith(
                                fontWeight: FontWeight.bold,
                                color: c.foreground,
                              ),
                            ),
                            Text(
                              'Code: ${g.code} • ${g.description ?? ''}',
                              style: t.small.copyWith(
                                fontSize: 11,
                                color: c.mutedForeground,
                              ),
                            ),
                            if (g.externalIdpGroupName != null)
                              Text(
                                'IdP Mapping: ${g.externalIdpGroupName}',
                                style: t.small.copyWith(
                                  fontSize: 10,
                                  color: c.primary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
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
