import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class FlattenedScopeItem {
  final String id;
  final String label;

  const FlattenedScopeItem({required this.id, required this.label});
}

class AssignRoleDialog extends StatefulWidget {
  final UserResponse user;
  final List<RoleResponse> roles;
  final List<ScopeTreeNode> scopes;
  final String? tenantId;
  final String? initialRoleId;
  final String? initialScopeId;
  final VoidCallback? onRoleAssigned;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.roles,
    this.scopes = const [],
    this.tenantId,
    this.initialRoleId,
    this.initialScopeId,
    this.onRoleAssigned,
  });

  static Future<void> show(
    BuildContext context, {
    required UserResponse user,
    required List<RoleResponse> roles,
    List<ScopeTreeNode> scopes = const [],
    String? tenantId,
    String? initialRoleId,
    String? initialScopeId,
    VoidCallback? onRoleAssigned,
  }) {
    if (roles.isEmpty) return Future.value();
    return showDialog(
      context: context,
      builder: (ctx) => AssignRoleDialog(
        user: user,
        roles: roles,
        scopes: scopes,
        tenantId: tenantId,
        initialRoleId: initialRoleId,
        initialScopeId: initialScopeId,
        onRoleAssigned: onRoleAssigned,
      ),
    );
  }

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  late String _selectedRoleId;
  String? _selectedScopeId;
  late final List<FlattenedScopeItem> _flattenedScopes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRoleId = widget.initialRoleId ?? widget.roles.first.id;
    _flattenedScopes = _flattenScopes(widget.scopes);
    _selectedScopeId = widget.initialScopeId;
  }

  List<FlattenedScopeItem> _flattenScopes(List<ScopeTreeNode> nodes,
      [int depth = 0]) {
    final list = <FlattenedScopeItem>[];
    for (final node in nodes) {
      final prefix = '  ' * depth;
      final label = depth > 0
          ? '$prefix└─ ${node.name} (${node.path})'
          : '${node.name} (${node.path})';
      list.add(FlattenedScopeItem(id: node.id, label: label));
      if (node.children.isNotEmpty) {
        list.addAll(_flattenScopes(node.children, depth + 1));
      }
    }
    return list;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final effectiveTenantId =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? widget.tenantId!
              : apiClient.tenantId;

      await iamService.assignRole(
        userId: widget.user.id,
        roleId: _selectedRoleId,
        tenantId: effectiveTenantId,
        scopeNodeId: _selectedScopeId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRoleAssigned?.call();
        AppToast.showSuccess(
            context, 'Role & Scope successfully assigned to user');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to assign role & scope: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.forestSage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.shieldAlert,
                color: AppColors.forestSage, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Role & Scope: ${widget.user.fullName}',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.user.email,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select RBAC role and target scope boundary for this user:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // Role Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRoleId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Role *',
                prefixIcon: const Icon(LucideIcons.shield, size: 16),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: widget.roles.map((r) {
                return DropdownMenuItem(
                  value: r.id,
                  child: Text(
                    '${r.name} (${r.code})',
                    style: const TextStyle(fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedRoleId = v);
                }
              },
            ),
            const SizedBox(height: 14),

            // Scope Dropdown
            DropdownButtonFormField<String?>(
              value: _selectedScopeId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Target Scope (Hierarchy)',
                prefixIcon: const Icon(LucideIcons.network, size: 16),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Entire Tenant (Root Scope)',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._flattenedScopes.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(
                      s.label,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (v) {
                setState(() => _selectedScopeId = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Assign Role & Scope'),
        ),
      ],
    );
  }
}
