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
  final String rawName;
  final String path;

  const FlattenedScopeItem({
    required this.id,
    required this.label,
    required this.rawName,
    required this.path,
  });
}

class AssignRoleDialog extends StatefulWidget {
  final UserResponse user;
  final List<RoleResponse> roles;
  final List<GroupResponse> groups;
  final List<ScopeTreeNode> scopes;
  final String? tenantId;
  final String? initialRoleId;
  final String? initialScopeId;
  final VoidCallback? onRoleAssigned;
  final IamService? iamService;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.roles,
    this.groups = const [],
    this.scopes = const [],
    this.tenantId,
    this.initialRoleId,
    this.initialScopeId,
    this.onRoleAssigned,
    this.iamService,
  });

  static Future<void> show(
    BuildContext context, {
    required UserResponse user,
    required List<RoleResponse> roles,
    List<GroupResponse> groups = const [],
    List<ScopeTreeNode> scopes = const [],
    String? tenantId,
    String? initialRoleId,
    String? initialScopeId,
    VoidCallback? onRoleAssigned,
    IamService? iamService,
  }) {
    if (roles.isEmpty) return Future.value();
    return showDialog(
      context: context,
      builder: (ctx) => AssignRoleDialog(
        user: user,
        roles: roles,
        groups: groups,
        scopes: scopes,
        tenantId: tenantId,
        initialRoleId: initialRoleId,
        initialScopeId: initialScopeId,
        onRoleAssigned: onRoleAssigned,
        iamService: iamService,
      ),
    );
  }

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog>
    with SingleTickerProviderStateMixin {
  IamService get _effectiveIamService => widget.iamService ?? iamService;

  late TabController _tabController;

  late String _selectedRoleId;
  String? _selectedScopeId;
  String? _selectedGroupIdToAdd;

  late final List<FlattenedScopeItem> _flattenedScopes;
  List<UserRoleAssignmentResponse> _roleAssignments = [];
  List<GroupResponse> _userGroups = [];
  List<GroupResponse> _allGroups = [];

  bool _isLoading = true;
  bool _isAssigningRole = false;
  bool _isAddingGroup = false;
  String? _revokingAssignmentId;
  String? _removingGroupId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _selectedRoleId = widget.initialRoleId ??
        (widget.roles.isNotEmpty ? widget.roles.first.id : '');
    _flattenedScopes = _flattenScopes(widget.scopes);
    _selectedScopeId = widget.initialScopeId;

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FlattenedScopeItem> _flattenScopes(List<ScopeTreeNode> nodes,
      [int depth = 0]) {
    final list = <FlattenedScopeItem>[];
    for (final node in nodes) {
      final prefix = '  ' * depth;
      final label = depth > 0
          ? '$prefix└─ ${node.name} (${node.path})'
          : '${node.name} (${node.path})';
      list.add(FlattenedScopeItem(
        id: node.id,
        label: label,
        rawName: node.name,
        path: node.path,
      ));
      if (node.children.isNotEmpty) {
        list.addAll(_flattenScopes(node.children, depth + 1));
      }
    }
    return list;
  }

  String _findScopeLabel(String? scopeId) {
    if (scopeId == null || scopeId.isEmpty) {
      return 'Entire Tenant (Root Scope)';
    }
    final match = _flattenedScopes.where((s) => s.id == scopeId).firstOrNull;
    if (match != null) {
      return match.rawName.isNotEmpty
          ? '${match.rawName} (${match.path})'
          : match.label;
    }
    return scopeId;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final effectiveTenantId =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? widget.tenantId!
              : apiClient.tenantId;

      final futures = await Future.wait([
        _effectiveIamService
            .getUserRoles(widget.user.id)
            .catchError((_) => <UserRoleAssignmentResponse>[]),
        _effectiveIamService
            .getUserGroups(widget.user.id)
            .catchError((_) => <GroupResponse>[]),
        widget.groups.isNotEmpty
            ? Future.value(widget.groups)
            : _effectiveIamService
                .listGroups()
                .catchError((_) => <GroupResponse>[]),
      ]);

      if (mounted) {
        final assignments = futures[0] as List<UserRoleAssignmentResponse>;
        final userGroups = futures[1] as List<GroupResponse>;
        final allGroups = futures[2] as List<GroupResponse>;

        // Filter assignments for effective tenant if in specific tenant session
        final filteredAssignments = effectiveTenantId.isNotEmpty &&
                effectiveTenantId != 'platform'
            ? assignments.where((a) => a.tenantId == effectiveTenantId).toList()
            : assignments;

        setState(() {
          _roleAssignments = filteredAssignments;
          _userGroups = userGroups;
          _allGroups = allGroups;
          _isLoading = false;

          final available = _getAvailableGroups();
          if (available.isNotEmpty) {
            _selectedGroupIdToAdd = available.first.id;
          } else {
            _selectedGroupIdToAdd = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<GroupResponse> _getAvailableGroups() {
    final assignedIds = _userGroups.map((g) => g.id).toSet();
    return _allGroups.where((g) => !assignedIds.contains(g.id)).toList();
  }

  Future<void> _submitRole() async {
    if (_selectedRoleId.isEmpty) return;
    setState(() => _isAssigningRole = true);
    try {
      final effectiveTenantId =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? widget.tenantId!
              : apiClient.tenantId;

      await _effectiveIamService.assignRole(
        userId: widget.user.id,
        roleId: _selectedRoleId,
        tenantId: effectiveTenantId,
        scopeNodeId: _selectedScopeId,
      );

      if (mounted) {
        widget.onRoleAssigned?.call();
        AppToast.showSuccess(
            context, 'Role & Scope successfully assigned to user');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to assign role & scope: $e');
      }
    } finally {
      if (mounted) setState(() => _isAssigningRole = false);
    }
  }

  Future<void> _revokeRole(String assignmentId) async {
    setState(() => _revokingAssignmentId = assignmentId);
    try {
      await _effectiveIamService.revokeRole(widget.user.id, assignmentId);
      if (mounted) {
        widget.onRoleAssigned?.call();
        AppToast.showSuccess(context, 'Role assignment revoked');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to revoke role: $e');
      }
    } finally {
      if (mounted) setState(() => _revokingAssignmentId = null);
    }
  }

  Future<void> _submitAddGroup() async {
    if (_selectedGroupIdToAdd == null) return;
    setState(() => _isAddingGroup = true);
    try {
      await _effectiveIamService.addUserToGroup(
          widget.user.id, _selectedGroupIdToAdd!);
      if (mounted) {
        widget.onRoleAssigned?.call();
        AppToast.showSuccess(context, 'User added to group');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to add user to group: $e');
      }
    } finally {
      if (mounted) setState(() => _isAddingGroup = false);
    }
  }

  Future<void> _removeFromGroup(String groupId) async {
    setState(() => _removingGroupId = groupId);
    try {
      await _effectiveIamService.removeUserFromGroup(widget.user.id, groupId);
      if (mounted) {
        widget.onRoleAssigned?.call();
        AppToast.showSuccess(context, 'User removed from group');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to remove user from group: $e');
      }
    } finally {
      if (mounted) setState(() => _removingGroupId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.shieldCheck,
                    color: AppColors.forestSage, size: 20),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 2),
                    Text(
                      '${widget.user.email} • Manage multi-role, group and scope boundaries',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.forestSage,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.forestSage,
            indicatorWeight: 2.5,
            labelStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12.5),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.shield, size: 15),
                    const SizedBox(width: 6),
                    const Text('Roles & Scopes'),
                    if (_roleAssignments.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_roleAssignments.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.users, size: 15),
                    const SizedBox(width: 6),
                    const Text('Groups'),
                    if (_userGroups.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_userGroups.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        height: 480,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.forestSage),
              )
            : (_tabController.index == 0
                ? _buildRolesAndScopesTab()
                : _buildGroupsTab()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildRolesAndScopesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Role Assignments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Assigned Roles & Scopes:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_roleAssignments.length} active',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_roleAssignments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmSand.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warmSand.withOpacity(0.5), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shieldAlert,
                      size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No roles currently assigned to this user.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _roleAssignments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final a = _roleAssignments[i];
                final role = widget.roles.firstWhere(
                  (r) => r.id == a.roleId || r.code == a.roleId,
                  orElse: () => RoleResponse(
                    id: a.roleId,
                    tenantId: a.tenantId,
                    code: a.roleId,
                    name: a.roleId,
                    description: '',
                    permissions: [],
                    isSystemRole: false,
                    createdAt: a.assignedAt,
                    updatedAt: a.assignedAt,
                  ),
                );
                final scopeLabel = _findScopeLabel(a.scopeNodeId);
                final isRevoking = _revokingAssignmentId == a.id;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.shield,
                            size: 15, color: AppColors.forestSage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${role.name} (${role.code})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(LucideIcons.network,
                                    size: 11, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    scopeLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1E40AF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: isRevoking
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.earthyTerra),
                              )
                            : const Icon(LucideIcons.trash2,
                                size: 16, color: AppColors.earthyTerra),
                        tooltip: 'Revoke Role Assignment',
                        onPressed: isRevoking ? null : () => _revokeRole(a.id),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Assign New Role & Scope Form
          const Text(
            'Assign New Role & Scope:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select RBAC role and target scope boundary for this user:',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Role Dropdown
          DropdownButtonFormField<String>(
            value: _selectedRoleId.isNotEmpty ? _selectedRoleId : null,
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
          const SizedBox(height: 12),

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
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 14),

          // Submit Role & Scope Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isAssigningRole ? null : _submitRole,
              icon: _isAssigningRole
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.plus, size: 16),
              label: const Text('Assign Role & Scope'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    final availableGroups = _getAvailableGroups();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current User Groups
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Group Memberships:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_userGroups.length} groups',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_userGroups.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmSand.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warmSand.withOpacity(0.5), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.users,
                      size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'User does not belong to any groups yet.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userGroups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final g = _userGroups[i];
                final isRemoving = _removingGroupId == g.id;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.users,
                            size: 15, color: AppColors.forestSage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${g.name} (${g.code})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (g.description != null &&
                                g.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                g.description!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: isRemoving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.earthyTerra),
                              )
                            : const Icon(LucideIcons.userMinus,
                                size: 16, color: AppColors.earthyTerra),
                        tooltip: 'Remove from group',
                        onPressed:
                            isRemoving ? null : () => _removeFromGroup(g.id),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Add to Group Form
          const Text(
            'Add to Group:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a group to assign membership and inherited roles:',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          if (availableGroups.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No additional groups available to add.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            )
          else ...[
            DropdownButtonFormField<String>(
              value: _selectedGroupIdToAdd,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Group *',
                prefixIcon: const Icon(LucideIcons.users, size: 16),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: availableGroups.map((g) {
                return DropdownMenuItem(
                  value: g.id,
                  child: Text(
                    '${g.name} (${g.code})',
                    style: const TextStyle(fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedGroupIdToAdd = v);
                }
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isAddingGroup ? null : _submitAddGroup,
                icon: _isAddingGroup
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.userPlus, size: 16),
                label: const Text('Add to Group'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
