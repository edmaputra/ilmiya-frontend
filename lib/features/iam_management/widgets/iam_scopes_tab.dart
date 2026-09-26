import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/iam.dart';

class IamScopesTab extends StatelessWidget {
  final List<ScopeTreeNode> scopes;
  final bool canCreateScope;
  final VoidCallback onCreateRootScope;
  final ValueChanged<String> onAddChildScope;

  const IamScopesTab({
    super.key,
    required this.scopes,
    required this.canCreateScope,
    required this.onCreateRootScope,
    required this.onAddChildScope,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Hierarchical Scope Tree',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateScope ? onCreateRootScope : null,
                icon: Icon(canCreateScope ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Root Scope'),
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
            child: ListView(
              children: scopes
                  .map((s) => _buildScopeNodeWidget(context, s, canCreateScope))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeNodeWidget(
      BuildContext context, ScopeTreeNode node, bool canCreate) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: (node.depth * (isMobile ? 12.0 : 20.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: node.depth == 0 ? c.accent.withOpacity(0.5) : c.card,
              borderRadius: KiteRadius.allMd,
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(
                  node.depth == 0
                      ? LucideIcons.landmark
                      : LucideIcons.folderTree,
                  size: 16,
                  color: c.foreground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final isNarrow = box.maxWidth < 220;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              node.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: t.small.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground),
                            ),
                            Text(
                              node.code,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: t.small.copyWith(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: c.mutedForeground),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              node.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: t.small.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            node.code,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: t.small.copyWith(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: c.mutedForeground),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: canCreate ? () => onAddChildScope(node.id) : null,
                  icon: Icon(
                    canCreate ? LucideIcons.plus : LucideIcons.lock,
                    size: 12,
                  ),
                  label:
                      const Text('Add Child', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    foregroundColor: c.primary,
                  ),
                ),
              ],
            ),
          ),
          if (node.children.isNotEmpty)
            ...node.children.map(
                (child) => _buildScopeNodeWidget(context, child, canCreate)),
        ],
      ),
    );
  }
}
