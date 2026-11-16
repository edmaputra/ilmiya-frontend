import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class FlattenedScopeItem {
  final String id;
  final String label;

  const FlattenedScopeItem({required this.id, required this.label});
}

class AssignRoleDialog extends StatefulWidget {
  final UserResponse user;
  final List<RoleResponse> roles;
  final List<ScopeTreeNode> scopes;
  final String tenantId;
  final String? initialRoleId;
  final String? initialScopeId;
  final VoidCallback? onRoleAssigned;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.roles,
    required this.scopes,
    required this.tenantId,
    this.initialRoleId,
    this.initialScopeId,
    this.onRoleAssigned,
  });

  static Future<void> show(
    BuildContext context, {
    required UserResponse user,
    required List<RoleResponse> roles,
    required List<ScopeTreeNode> scopes,
    required String tenantId,
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRoleId = widget.initialRoleId ?? widget.roles.first.id;
    _flattenedScopes = _flattenScopes(widget.scopes);
    _selectedScopeId = widget.initialScopeId ??
        (_flattenedScopes.isNotEmpty ? _flattenedScopes.first.id : null);
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
    setState(() => _isSaving = true);
    try {
      await iamService.assignRole(
        userId: widget.user.id,
        roleId: _selectedRoleId,
        tenantId: widget.tenantId,
        scopeNodeId: _selectedScopeId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRoleAssigned?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Role and Scope successfully assigned to ${widget.user.fullName}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign role/scope: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Assign Role: ${widget.user.fullName}',
              style: const TextStyle(fontFamily: 'serif', fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign an institutional role and boundary scope to this user account:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),

            // Role Dropdown
            const Text(
              'Target Role:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedRoleId,
              decoration: InputDecoration(
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: widget.roles
                  .map((r) => DropdownMenuItem(
                      value: r.id, child: Text('${r.name} (${r.code})')))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedRoleId = v);
                }
              },
            ),
            const SizedBox(height: 16),

            // Scope Dropdown
            const Text(
              'Boundary Scope:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              value: _selectedScopeId,
              decoration: InputDecoration(
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tenant-wide (No Scope Restriction)'),
                ),
                ..._flattenedScopes.map((s) => DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(
                        s.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
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
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Assign Role & Scope'),
        ),
      ],
    );
  }
}
