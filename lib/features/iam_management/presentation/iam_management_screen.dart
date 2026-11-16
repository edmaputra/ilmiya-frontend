import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../shared_widgets/tenant_session_required_view.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/assign_role_dialog.dart';
import '../dialogs/create_group_dialog.dart';
import '../dialogs/create_role_dialog.dart';
import '../dialogs/create_scope_dialog.dart';
import '../dialogs/create_user_dialog.dart';
import '../dialogs/edit_role_dialog.dart';
import '../widgets/iam_access_restricted_view.dart';
import '../widgets/iam_groups_tab.dart';
import '../widgets/iam_roles_tab.dart';
import '../widgets/iam_scopes_tab.dart';
import '../widgets/iam_users_tab.dart';

class IamManagementScreen extends StatefulWidget {
  const IamManagementScreen({super.key});

  @override
  State<IamManagementScreen> createState() => _IamManagementScreenState();
}

class _IamManagementScreenState extends State<IamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UserResponse> _users = [];
  List<RoleResponse> _roles = [];
  List<GroupResponse> _groups = [];
  List<ScopeTreeNode> _scopes = [];
  Map<String, UserRoleAssignmentResponse> _userAssignments = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllIamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllIamData() async {
    final auth = context.read<AuthNotifier>();
    if (!apiClient.isMockMode &&
        !auth.hasRole('SUPERADMIN') &&
        !auth.hasRole('TENANT_ADMIN') &&
        !auth.hasPermission('iam:user:read')) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _users = [];
          _roles = [];
          _groups = [];
          _scopes = [];
          _userAssignments = {};
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tId = auth.tenantId;
      final u = await iamService.listUsers(tenantId: tId);
      final r = await iamService.listRoles();
      final g = await iamService.listGroups();
      final s = await iamService.getScopeTree();

      final assignments = <String, UserRoleAssignmentResponse>{};
      for (final user in u) {
        try {
          final userRoles = await iamService.getUserRoles(user.id);
          if (userRoles.isNotEmpty) {
            assignments[user.id] = userRoles.first;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _users = u;
          _roles = r;
          _groups = g;
          _scopes = s;
          _userAssignments = assignments;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateUserDialog() {
    CreateUserDialog.show(
      context,
      onUserCreated: _loadAllIamData,
    );
  }

  void _showAssignRoleDialog(UserResponse user) {
    final currentAssignment = _userAssignments[user.id];
    AssignRoleDialog.show(
      context,
      user: user,
      roles: _roles,
      scopes: _scopes,
      tenantId: context.read<AuthNotifier>().tenantId,
      initialRoleId: currentAssignment?.roleId,
      initialScopeId: currentAssignment?.scopeNodeId,
      onRoleAssigned: _loadAllIamData,
    );
  }

  void _showCreateRoleDialog() {
    CreateRoleDialog.show(
      context,
      onRoleCreated: _loadAllIamData,
    );
  }

  void _showEditRoleDialog(RoleResponse role) {
    EditRoleDialog.show(
      context,
      role: role,
      onRoleUpdated: _loadAllIamData,
    );
  }

  Future<void> _deleteRole(RoleResponse role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = KiteColors.of(ctx);
        final t = KiteText.of(ctx);
        return AlertDialog(
          title: Text('Delete Role',
              style: t.h4.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete role "${role.name}" (${role.code})? This action cannot be undone.',
            style: t.small,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.destructive,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await iamService.deleteRole(role.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Role "${role.name}" deleted successfully.')),
          );
        }
        await _loadAllIamData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete role: $e')),
          );
        }
      }
    }
  }

  void _showCreateGroupDialog() {
    CreateGroupDialog.show(
      context,
      onGroupCreated: _loadAllIamData,
    );
  }

  void _showCreateScopeDialog({String? parentId}) {
    CreateScopeDialog.show(
      context,
      parentId: parentId,
      onScopeCreated: _loadAllIamData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();

    if (auth.isPlatformSession) {
      return const TenantSessionRequiredView(
        sectionName: 'IAM Console & Security Governance',
      );
    }

    // RBAC Security Check
    if (!apiClient.isMockMode &&
        !auth.hasRole('SUPERADMIN') &&
        !auth.hasRole('TENANT_ADMIN') &&
        !auth.hasPermission('iam:user:read')) {
      return IamAccessRestrictedView(auth: auth);
    }

    final canCreateUser = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:user:create');
    final canUpdateUserStatus = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:user:status');
    final canAssignRole = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:user:assign-role');
    final canDeleteUser = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:user:delete');
    final canCreateRole = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:role:create');
    final canEditRole = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:role:update');
    final canDeleteRole = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:role:delete');
    final canCreateGroup = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:group:create');
    final canCreateScope = auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('iam:scope:create');

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    final filteredUsers = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Responsive Header Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              final titleColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identity & Access Management (IAM)',
                    style: t.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enterprise ed-iam security console: Users, RBAC Matrix, Directory Groups, and Scopes.',
                    style: t.muted,
                  ),
                ],
              );

              final tabBar = ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isNarrow ? double.infinity : 480),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: c.primary,
                  labelColor: c.foreground,
                  unselectedLabelColor: c.mutedForeground,
                  tabs: const [
                    Tab(icon: Icon(LucideIcons.users, size: 16), text: 'Users'),
                    Tab(
                        icon: Icon(LucideIcons.shieldCheck, size: 16),
                        text: 'Roles & RBAC'),
                    Tab(
                        icon: Icon(LucideIcons.layers, size: 16),
                        text: 'Groups'),
                    Tab(
                        icon: Icon(LucideIcons.gitBranch, size: 16),
                        text: 'Scope Tree'),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleColumn,
                    const SizedBox(height: 12),
                    tabBar,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleColumn),
                  const SizedBox(width: 16),
                  tabBar,
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                IamUsersTab(
                  users: filteredUsers,
                  searchQuery: _searchQuery,
                  canCreate: canCreateUser,
                  canUpdateStatus: canUpdateUserStatus,
                  canAssign: canAssignRole,
                  canDelete: canDeleteUser,
                  userAssignments: _userAssignments,
                  roles: _roles,
                  scopes: _scopes,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  onCreateUser: _showCreateUserDialog,
                  onAssignRole: _showAssignRoleDialog,
                  onDataReload: _loadAllIamData,
                ),
                IamRolesTab(
                  roles: _roles,
                  canCreateRole: canCreateRole,
                  onCreateRole: _showCreateRoleDialog,
                  onEditRole: _showEditRoleDialog,
                  onDeleteRole: _deleteRole,
                  canEditRole: canEditRole,
                  canDeleteRole: canDeleteRole,
                ),
                IamGroupsTab(
                  groups: _groups,
                  canCreateGroup: canCreateGroup,
                  onCreateGroup: _showCreateGroupDialog,
                ),
                IamScopesTab(
                  scopes: _scopes,
                  canCreateScope: canCreateScope,
                  onCreateRootScope: () =>
                      _showCreateScopeDialog(parentId: null),
                  onAddChildScope: (parentId) =>
                      _showCreateScopeDialog(parentId: parentId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
