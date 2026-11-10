import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../dialogs/manage_group_dialog.dart';

class IamGroupsTab extends StatefulWidget {
  final List<GroupResponse> groups;
  final List<UserResponse> users;
  final List<RoleResponse> roles;
  final List<ScopeTreeNode> scopes;
  final bool canCreateGroup;
  final VoidCallback onCreateGroup;
  final VoidCallback onGroupChanged;

  const IamGroupsTab({
    super.key,
    required this.groups,
    this.users = const [],
    this.roles = const [],
    this.scopes = const [],
    required this.canCreateGroup,
    required this.onCreateGroup,
    required this.onGroupChanged,
  });

  @override
  State<IamGroupsTab> createState() => _IamGroupsTabState();
}

class _IamGroupsTabState extends State<IamGroupsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final filtered = widget.groups.where((g) {
      if (_searchQuery.isEmpty) return true;
      return g.name.toLowerCase().contains(_searchQuery) ||
          g.code.toLowerCase().contains(_searchQuery) ||
          (g.description?.toLowerCase().contains(_searchQuery) ?? false) ||
          (g.externalIdpGroupName?.toLowerCase().contains(_searchQuery) ??
              false);
    }).toList();

    return KiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Groups & Directory Integrations',
                    style: t.large.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                  Text(
                    'Organize staff and students into functional directory units with shared RBAC policies',
                    style: t.small.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.canCreateGroup ? widget.onCreateGroup : null,
                icon: Icon(
                    widget.canCreateGroup ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            style: const TextStyle(fontSize: 12),
            onChanged: (v) =>
                setState(() => _searchQuery = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search groups by name, code or IDP mapping...',
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Groups List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.usersRound,
                            size: 40, color: c.mutedForeground),
                        const SizedBox(height: 10),
                        Text(
                          'No groups found',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final g = filtered[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.forestSage.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.users,
                                  color: AppColors.forestSage, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        g.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.warmSandHover,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          g.code,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (g.description != null &&
                                            g.description!.isNotEmpty)
                                        ? g.description!
                                        : 'No description provided.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: c.mutedForeground,
                                    ),
                                  ),
                                  if (g.externalIdpGroupName != null &&
                                      g.externalIdpGroupName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.link2,
                                            size: 11,
                                            color: AppColors.forestSage),
                                        const SizedBox(width: 4),
                                        Text(
                                          'IdP Group: ${g.externalIdpGroupName}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.forestSage,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => ManageGroupDialog.show(
                                context,
                                group: g,
                                allUsers: widget.users,
                                allRoles: widget.roles,
                                allScopes: widget.scopes,
                                onGroupChanged: widget.onGroupChanged,
                              ),
                              icon: const Icon(LucideIcons.slidersHorizontal,
                                  size: 14),
                              label: const Text('Manage',
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
