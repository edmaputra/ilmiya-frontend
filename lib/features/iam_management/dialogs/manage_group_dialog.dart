import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class ManageGroupDialog extends StatefulWidget {
  final GroupResponse group;
  final List<UserResponse> allUsers;
  final List<RoleResponse> allRoles;
  final List<ScopeTreeNode> allScopes;
  final VoidCallback onGroupChanged;

  const ManageGroupDialog({
    super.key,
    required this.group,
    required this.allUsers,
    required this.allRoles,
    required this.allScopes,
    required this.onGroupChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required GroupResponse group,
    required List<UserResponse> allUsers,
    required List<RoleResponse> allRoles,
    required List<ScopeTreeNode> allScopes,
    required VoidCallback onGroupChanged,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ManageGroupDialog(
        group: group,
        allUsers: allUsers,
        allRoles: allRoles,
        allScopes: allScopes,
        onGroupChanged: onGroupChanged,
      ),
    );
  }

  @override
  State<ManageGroupDialog> createState() => _ManageGroupDialogState();
}

class _ManageGroupDialogState extends State<ManageGroupDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _idpCtrl;

  List<UserResponse> _members = [];
  List<GroupRoleAssignmentResponse> _groupRoles = [];
  bool _isLoadingMembers = true;
  bool _isLoadingRoles = true;
  bool _isSavingDetails = false;

  String? _selectedUserIdToAdd;
  String? _selectedRoleIdToAssign;
  String? _selectedScopeIdToAssign;

  List<ScopeTreeNode> _flattenScopes(List<ScopeTreeNode> nodes) {
    final list = <ScopeTreeNode>[];
    for (final node in nodes) {
      list.add(node);
      list.addAll(_flattenScopes(node.children));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameCtrl = TextEditingController(text: widget.group.name);
    _descCtrl = TextEditingController(text: widget.group.description ?? '');
    _idpCtrl =
        TextEditingController(text: widget.group.externalIdpGroupName ?? '');

    _loadMembers();
    _loadRoles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _idpCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final members = await iamService.getGroupMembers(widget.group.id);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final roles = await iamService.getGroupRoles(widget.group.id);
      if (mounted) {
        setState(() {
          _groupRoles = roles;
          _isLoadingRoles = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRoles = false);
    }
  }

  Future<void> _updateDetails() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      AppToast.showError(context, 'Group name cannot be blank.');
      return;
    }

    setState(() => _isSavingDetails = true);
    try {
      await iamService.updateGroup(
        widget.group.id,
        UpdateGroupRequest(
          name: newName,
          description:
              _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          externalIdpGroupName:
              _idpCtrl.text.trim().isNotEmpty ? _idpCtrl.text.trim() : null,
        ),
      );
      if (mounted) {
        setState(() => _isSavingDetails = false);
        AppToast.showSuccess(context, 'Group details updated successfully');
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingDetails = false);
        AppToast.showError(context, 'Failed to update group: $e');
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          "Are you sure you want to delete group '${widget.group.name}'? This will remove all membership associations.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.earthyTerra,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await iamService.deleteGroup(widget.group.id);
      if (mounted) {
        AppToast.showSuccess(context, "Group '${widget.group.name}' deleted");
        Navigator.of(context).pop();
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to delete group: $e');
      }
    }
  }

  Future<void> _addMember() async {
    if (_selectedUserIdToAdd == null) return;
    try {
      await iamService.addUserToGroup(_selectedUserIdToAdd!, widget.group.id);
      if (mounted) {
        AppToast.showSuccess(context, 'User added to group');
        _selectedUserIdToAdd = null;
        await _loadMembers();
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to add user: $e');
      }
    }
  }

  Future<void> _removeMember(String userId) async {
    try {
      await iamService.removeUserFromGroup(userId, widget.group.id);
      if (mounted) {
        AppToast.showSuccess(context, 'User removed from group');
        await _loadMembers();
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to remove user: $e');
      }
    }
  }

  Future<void> _assignRole() async {
    if (_selectedRoleIdToAssign == null) return;
    try {
      await iamService.assignGroupRole(
        groupId: widget.group.id,
        roleId: _selectedRoleIdToAssign!,
        tenantId: apiClient.tenantId,
        scopeNodeId: _selectedScopeIdToAssign,
      );
      if (mounted) {
        AppToast.showSuccess(context, 'Role attached to group');
        _selectedRoleIdToAssign = null;
        _selectedScopeIdToAssign = null;
        await _loadRoles();
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to attach role: $e');
      }
    }
  }

  Future<void> _revokeRole(String assignmentId) async {
    try {
      await iamService.revokeGroupRole(
        groupId: widget.group.id,
        assignmentId: assignmentId,
      );
      if (mounted) {
        AppToast.showSuccess(context, 'Role revoked from group');
        await _loadRoles();
        widget.onGroupChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to revoke role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flatScopes = _flattenScopes(widget.allScopes);
    final nonMemberUsers = widget.allUsers
        .where((u) => !_members.any((m) => m.id == u.id))
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.forestSage.withOpacity(0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                border: const Border(
                    bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.users,
                        color: AppColors.forestSage, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Code: ${widget.group.code} • Manage members, group roles, and metadata',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Navigation
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.forestSage,
                labelColor: AppColors.forestSage,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.bold),
                tabs: [
                  const Tab(
                    icon: Icon(LucideIcons.settings2, size: 16),
                    text: 'Settings',
                  ),
                  Tab(
                    icon: const Icon(LucideIcons.userCheck, size: 16),
                    text: 'Members (${_members.length})',
                  ),
                  Tab(
                    icon: const Icon(LucideIcons.shieldCheck, size: 16),
                    text: 'Roles (${_groupRoles.length})',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Group Settings & Edit
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Group Name *',
                          prefixIcon:
                              const Icon(LucideIcons.usersRound, size: 16),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon:
                              const Icon(LucideIcons.alignLeft, size: 16),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _idpCtrl,
                        decoration: InputDecoration(
                          labelText: 'External IDP Mapping (Optional)',
                          hintText: 'e.g. OIDC-Azure-Staff-Group',
                          prefixIcon: const Icon(LucideIcons.link2, size: 16),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestSage,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSavingDetails ? null : _updateDetails,
                            icon: _isSavingDetails
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(LucideIcons.save, size: 16),
                            label: const Text('Save Changes'),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.earthyTerra,
                              side: const BorderSide(
                                  color: AppColors.earthyTerra),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _deleteGroup,
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            label: const Text('Delete Group'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Tab 2: Members Management
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Add Member Section
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedUserIdToAdd,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Select User to Include in Group',
                                  prefixIcon: const Icon(LucideIcons.userPlus,
                                      size: 16),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: nonMemberUsers.map((u) {
                                  return DropdownMenuItem(
                                    value: u.id,
                                    child: Text(
                                      '${u.fullName} (${u.email})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedUserIdToAdd = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.forestSage,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _selectedUserIdToAdd != null
                                  ? _addMember
                                  : null,
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: const Text('Add Member'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        // Members List
                        Expanded(
                          child: _isLoadingMembers
                              ? const Center(child: CircularProgressIndicator())
                              : _members.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No users in this group yet.',
                                        style: TextStyle(
                                            color: AppColors.textMuted),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _members.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (ctx, i) {
                                        final m = _members[i];
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAFAFA),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.borderLight),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: AppColors
                                                    .forestSage
                                                    .withOpacity(0.15),
                                                child: Text(
                                                  m.fullName.isNotEmpty
                                                      ? m.fullName[0]
                                                          .toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.forestSage,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      m.fullName,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      m.email,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  LucideIcons.userMinus,
                                                  size: 16,
                                                  color: AppColors.earthyTerra,
                                                ),
                                                tooltip: 'Remove from group',
                                                onPressed: () =>
                                                    _removeMember(m.id),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 3: Group Roles Management
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Assign Role Form
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRoleIdToAssign,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'Role to Attach',
                                        prefixIcon: const Icon(
                                            LucideIcons.shield,
                                            size: 16),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      items: widget.allRoles.map((r) {
                                        return DropdownMenuItem(
                                          value: r.id,
                                          child: Text(
                                            '${r.name} (${r.code})',
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() =>
                                            _selectedRoleIdToAssign = val);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String?>(
                                      value: _selectedScopeIdToAssign,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'Target Scope (Hierarchy)',
                                        prefixIcon: const Icon(
                                            LucideIcons.network,
                                            size: 16),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                            'Entire Tenant (Root Scope)',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ...flatScopes.map((s) {
                                          return DropdownMenuItem(
                                            value: s.id,
                                            child: Text(
                                              '${s.name} (${s.path})',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) {
                                        setState(() =>
                                            _selectedScopeIdToAssign = val);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.forestSage,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _selectedRoleIdToAssign != null
                                        ? _assignRole
                                        : null,
                                    icon:
                                        const Icon(LucideIcons.link, size: 16),
                                    label: const Text('Attach'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        // Assigned Roles List
                        Expanded(
                          child: _isLoadingRoles
                              ? const Center(child: CircularProgressIndicator())
                              : _groupRoles.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No roles attached to this group yet.',
                                        style: TextStyle(
                                            color: AppColors.textMuted),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _groupRoles.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (ctx, i) {
                                        final gr = _groupRoles[i];
                                        final roleObj =
                                            widget.allRoles.firstWhere(
                                          (r) => r.id == gr.roleId,
                                          orElse: () => RoleResponse(
                                            id: gr.roleId,
                                            tenantId: gr.tenantId,
                                            code: 'UNKNOWN',
                                            name: 'Role #${gr.roleId}',
                                            permissions: [],
                                            isSystemRole: false,
                                            createdAt: '',
                                            updatedAt: '',
                                          ),
                                        );
                                        final scopeObj = flatScopes
                                            .where(
                                                (s) => s.id == gr.scopeNodeId)
                                            .firstOrNull;

                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAFAFA),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.borderLight),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.forestSage
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  LucideIcons.shieldCheck,
                                                  size: 16,
                                                  color: AppColors.forestSage,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      roleObj.name,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 6,
                                                                  vertical:
                                                                      1.5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .warmSandHover,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            roleObj.code,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 9.5,
                                                              fontFamily:
                                                                  'monospace',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Icon(
                                                          LucideIcons.network,
                                                          size: 12,
                                                          color: AppColors
                                                              .textMuted,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          scopeObj != null
                                                              ? '${scopeObj.name} (${scopeObj.path})'
                                                              : 'Entire Tenant (Root)',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10.5,
                                                            color: AppColors
                                                                .textMuted,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  LucideIcons.shieldX,
                                                  size: 16,
                                                  color: AppColors.earthyTerra,
                                                ),
                                                tooltip: 'Revoke role',
                                                onPressed: () =>
                                                    _revokeRole(gr.id),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
