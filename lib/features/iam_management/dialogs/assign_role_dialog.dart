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

class StagedRoleAssignment {
  final String roleId;
  final String? scopeNodeId;

  const StagedRoleAssignment({
    required this.roleId,
    this.scopeNodeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StagedRoleAssignment &&
          runtimeType == other.runtimeType &&
          roleId == other.roleId &&
          scopeNodeId == other.scopeNodeId;

  @override
  int get hashCode => roleId.hashCode ^ (scopeNodeId?.hashCode ?? 0);
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
  final List<StagedRoleAssignment> _stagedAssignments = [];

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

  RoleResponse _findRole(String roleId) {
    return widget.roles.firstWhere(
      (r) => r.id == roleId || r.code == roleId,
      orElse: () => RoleResponse(
        id: roleId,
        tenantId: widget.tenantId ?? '',
        code: roleId,
        name: roleId,
        description: '',
        permissions: [],
        isSystemRole: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
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

  bool _isAssignmentAlreadyActive(String roleId, String? scopeId) {
    return _roleAssignments.any((a) {
      final matchesRole = a.roleId == roleId ||
          widget.roles.any((r) =>
              (r.id == roleId || r.code == roleId) &&
              (r.id == a.roleId || r.code == a.roleId));
      final matchesScope = (a.scopeNodeId ?? '') == (scopeId ?? '');
      return matchesRole && matchesScope;
    });
  }

  bool _isAssignmentAlreadyStaged(String roleId, String? scopeId) {
    return _stagedAssignments.any(
        (a) => a.roleId == roleId && (a.scopeNodeId ?? '') == (scopeId ?? ''));
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

  void _addToBatchQueue({String? specificRoleId, String? specificScopeId}) {
    final roleId = specificRoleId ?? _selectedRoleId;
    final scopeId = specificScopeId ?? _selectedScopeId;

    if (roleId.isEmpty) return;

    final role = _findRole(roleId);

    if (_isAssignmentAlreadyActive(roleId, scopeId)) {
      AppToast.showInfo(
        context,
        'Role "${role.name}" is already assigned to this scope.',
      );
      return;
    }

    if (_isAssignmentAlreadyStaged(roleId, scopeId)) {
      AppToast.showInfo(
        context,
        'Role "${role.name}" is already staged in the batch queue.',
      );
      return;
    }

    setState(() {
      _stagedAssignments.add(StagedRoleAssignment(
        roleId: roleId,
        scopeNodeId: scopeId,
      ));
    });

    AppToast.showSuccess(
      context,
      'Staged "${role.name}" to batch queue',
    );
  }

  void _removeFromBatchQueue(int index) {
    setState(() {
      _stagedAssignments.removeAt(index);
    });
  }

  void _clearBatchQueue() {
    setState(() {
      _stagedAssignments.clear();
    });
  }

  Future<void> _submitBatchAssignments() async {
    final itemsToAssign = _stagedAssignments.isNotEmpty
        ? List<StagedRoleAssignment>.from(_stagedAssignments)
        : (_selectedRoleId.isNotEmpty
            ? [
                StagedRoleAssignment(
                  roleId: _selectedRoleId,
                  scopeNodeId: _selectedScopeId,
                )
              ]
            : <StagedRoleAssignment>[]);

    if (itemsToAssign.isEmpty) return;

    setState(() => _isAssigningRole = true);
    try {
      final effectiveTenantId =
          (widget.tenantId != null && widget.tenantId!.isNotEmpty)
              ? widget.tenantId!
              : apiClient.tenantId;

      final requests = itemsToAssign
          .map((item) => AssignUserRoleRequest(
                roleId: item.roleId,
                tenantId: effectiveTenantId,
                scopeNodeId: item.scopeNodeId,
              ))
          .toList();

      await _effectiveIamService.assignRolesBatch(
        userId: widget.user.id,
        assignments: requests,
      );

      if (mounted) {
        setState(() => _stagedAssignments.clear());
        widget.onRoleAssigned?.call();
        final count = requests.length;
        AppToast.showSuccess(
          context,
          'Successfully assigned $count ${count == 1 ? "role & scope" : "roles in batch"} to user',
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to assign roles (batch): $e');
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
        width: 560,
        height: 520,
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
          // Current Role Assignments Header
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _roleAssignments.isEmpty
                      ? Colors.grey.shade200
                      : AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_roleAssignments.length} active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _roleAssignments.isEmpty
                        ? AppColors.textMuted
                        : AppColors.forestSage,
                  ),
                ),
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
                final role = _findRole(a.roleId);
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

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Batch Role Assignment Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.layers,
                    size: 14, color: AppColors.forestSage),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Batch Role Assignment',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        _BatchEndpointTag(),
                      ],
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Stage multiple roles and scopes, then apply all in one batch request.',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Role Chips
          if (widget.roles.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.roles.map((r) {
                final isSelected = _selectedRoleId == r.id;
                final isAssigned = _roleAssignments.any((a) =>
                    a.roleId == r.id ||
                    widget.roles.any((x) =>
                        (x.id == r.id || x.code == r.id) &&
                        (x.id == a.roleId || x.code == a.roleId)));

                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  avatar: Icon(
                    isAssigned
                        ? LucideIcons.shieldCheck
                        : (isSelected ? LucideIcons.check : LucideIcons.shield),
                    size: 12,
                    color: isSelected
                        ? Colors.white
                        : (isAssigned
                            ? AppColors.forestSage
                            : AppColors.textSecondary),
                  ),
                  label: Text(
                    r.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? AppColors.forestSage
                      : (isAssigned
                          ? AppColors.forestSage.withOpacity(0.08)
                          : Colors.grey.shade100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.forestSage
                          : Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedRoleId = r.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

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
          const SizedBox(height: 10),

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
          const SizedBox(height: 12),

          // Staged Queue Preview
          if (_stagedAssignments.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.forestSage.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.forestSage.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.listPlus,
                              size: 14, color: AppColors.forestSage),
                          const SizedBox(width: 6),
                          Text(
                            'Staged for Batch (${_stagedAssignments.length}):',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _clearBatchQueue,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            'Clear Queue',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.earthyTerra,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stagedAssignments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (ctx, i) {
                      final item = _stagedAssignments[i];
                      final role = _findRole(item.roleId);
                      final scopeLabel = _findScopeLabel(item.scopeNodeId);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.forestSage.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${i + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestSage,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${role.name} (${role.code})',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    scopeLabel,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF1E40AF),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x,
                                  size: 14, color: AppColors.earthyTerra),
                              tooltip: 'Remove from batch queue',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _removeFromBatchQueue(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Batch Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.forestSage,
                    side: const BorderSide(color: AppColors.forestSage),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isAssigningRole ? null : () => _addToBatchQueue(),
                  icon: const Icon(LucideIcons.listPlus, size: 15),
                  label: const Text(
                    'Add to Batch',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isAssigningRole ? null : _submitBatchAssignments,
                  icon: _isAssigningRole
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _stagedAssignments.isEmpty
                              ? LucideIcons.plus
                              : LucideIcons.layers,
                          size: 16,
                        ),
                  label: Text(
                    _isAssigningRole
                        ? 'Assigning...'
                        : (_stagedAssignments.isEmpty
                            ? 'Assign Role & Scope'
                            : 'Assign ${_stagedAssignments.length} Roles (Batch)'),
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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

class _BatchEndpointTag extends StatelessWidget {
  const _BatchEndpointTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppColors.forestSage.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.forestSage.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: const Text(
        'POST /roles/batch',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: AppColors.forestSage,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
