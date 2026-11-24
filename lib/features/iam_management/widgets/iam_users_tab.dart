import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/iam.dart';
import 'iam_user_tile.dart';

class IamUsersTab extends StatelessWidget {
  final List<UserResponse> users;
  final Map<String, List<RoleResponse>> userRoles;
  final String searchQuery;
  final bool canCreate;
  final bool canEdit;
  final bool canUpdateStatus;
  final bool canAssign;
  final bool canDelete;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreateUser;
  final ValueChanged<UserResponse>? onEditUser;
  final ValueChanged<UserResponse> onAssignRole;
  final Future<void> Function() onDataReload;
  final Map<String, UserRoleAssignmentResponse> userAssignments;
  final List<RoleResponse> roles;
  final List<ScopeTreeNode> scopes;

  const IamUsersTab({
    super.key,
    required this.users,
    this.userRoles = const {},
    required this.searchQuery,
    required this.canCreate,
    this.canEdit = true,
    required this.canUpdateStatus,
    required this.canAssign,
    required this.canDelete,
    required this.onSearchChanged,
    required this.onCreateUser,
    this.onEditUser,
    required this.onAssignRole,
    required this.onDataReload,
    this.userAssignments = const {},
    this.roles = const [],
    this.scopes = const [],
  });

  String _nodeLabel(ScopeTreeNode n) {
    if (n.name.isNotEmpty) return n.name;
    if (n.code.isNotEmpty) return n.code;
    return n.id;
  }

  List<ScopeTreeNode>? _findScopeChain(
      List<ScopeTreeNode> nodes, String? scopeId) {
    if (scopeId == null || scopeId.isEmpty) return null;
    for (final n in nodes) {
      if (n.id == scopeId || n.path == scopeId) return [n];
      final childChain = _findScopeChain(n.children, scopeId);
      if (childChain != null) return [n, ...childChain];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.search,
                        size: 18, color: c.mutedForeground),
                    hintText: 'Search user by name or email...',
                    hintStyle: t.small.copyWith(color: c.mutedForeground),
                    isDense: true,
                    fillColor: c.card,
                    border: const OutlineInputBorder(
                        borderRadius: KiteRadius.allMd),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canCreate ? onCreateUser : null,
                icon: Icon(canCreate ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create User'),
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
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: c.border),
              itemBuilder: (ctx, i) {
                final u = users[i];
                final assignment = userAssignments[u.id];
                final role = assignment != null
                    ? roles.where((r) => r.id == assignment.roleId).firstOrNull
                    : null;
                final chain = _findScopeChain(scopes, assignment?.scopeNodeId);
                final targetLabel =
                    chain != null ? _nodeLabel(chain.last) : null;
                final breadcrumb = chain?.map(_nodeLabel).join(' > ');
                final rawPath = chain?.last.path;
                final scopeTooltip =
                    breadcrumb != null && rawPath != null && rawPath.isNotEmpty
                        ? '$breadcrumb ($rawPath)'
                        : breadcrumb;

                return IamUserTile(
                  user: u,
                  assignedRoles:
                      userRoles[u.id] ?? (role != null ? [role] : const []),
                  assignedScope: targetLabel ?? assignment?.scopeNodeId,
                  assignedScopeTooltip: scopeTooltip,
                  canEdit: canEdit,
                  canUpdateStatus: canUpdateStatus,
                  canAssign: canAssign,
                  canDelete: canDelete,
                  onEditUser: onEditUser,
                  onAssignRole: onAssignRole,
                  onDataReload: onDataReload,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
