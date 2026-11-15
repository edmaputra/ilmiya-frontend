import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/assign_role_dialog.dart';
import '../dialogs/create_group_dialog.dart';
import '../dialogs/create_role_dialog.dart';
import '../dialogs/create_scope_dialog.dart';
import '../dialogs/create_user_dialog.dart';
import '../dialogs/edit_user_dialog.dart';
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
  Map<String, List<RoleResponse>> _userRolesMap = {};
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
        !auth.hasPermission('iam:user:read')) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _users = [];
          _roles = [];
          _groups = [];
          _scopes = [];
          _userRolesMap = {};
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        iamService.listUsers().catchError((e) {
          debugPrint('Error loading users: $e');
          return <UserResponse>[];
        }),
        iamService.listRoles().catchError((e) {
          debugPrint('Error loading roles: $e');
          return <RoleResponse>[];
        }),
        iamService.listGroups().catchError((e) {
          debugPrint('Error loading groups: $e');
          return <GroupResponse>[];
        }),
        iamService.getScopeTree().catchError((e) {
          debugPrint('Error loading scopes: $e');
          return <ScopeTreeNode>[];
        }),
      ]);

      final users = results[0] as List<UserResponse>;
      final roles = results[1] as List<RoleResponse>;
      final groups = results[2] as List<GroupResponse>;
      final scopes = results[3] as List<ScopeTreeNode>;

      final userRolesMap = <String, List<RoleResponse>>{};
      if (users.isNotEmpty) {
        try {
          final assignmentsLists = await Future.wait(
            users.map((u) => iamService
                .getUserRoles(u.id)
                .catchError((_) => <UserRoleAssignmentResponse>[])),
          );
          for (var i = 0; i < users.length; i++) {
            final uId = users[i].id;
            final assignments = assignmentsLists[i];
            final assignedRoles = <RoleResponse>[];
            for (final a in assignments) {
              final role = roles.firstWhere(
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
              if (!assignedRoles.any((r) => r.id == role.id)) {
                assignedRoles.add(role);
              }
            }
            userRolesMap[uId] = assignedRoles;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _users = users;
          _roles = roles;
          _groups = groups;
          _scopes = scopes;
          _userRolesMap = userRolesMap;
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

  void _showEditUserDialog(UserResponse user) {
    EditUserDialog.show(
      context,
      user: user,
      onUserUpdated: _loadAllIamData,
    );
  }

  void _showAssignRoleDialog(UserResponse user) {
    AssignRoleDialog.show(
      context,
      user: user,
      roles: _roles,
      scopes: _scopes,
      onRoleAssigned: _loadAllIamData,
    );
  }

  void _showCreateRoleDialog() {
    CreateRoleDialog.show(
      context,
      onRoleCreated: _loadAllIamData,
    );
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
    final canCreateUser = auth.hasPermission('iam:user:create');
    final canEditUser = auth.hasPermission('iam:user:update') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasPermission('*');
    final canUpdateUserStatus = auth.hasPermission('iam:user:status');
    final canAssignRole = auth.hasPermission('iam:user:assign-role');
    final canDeleteUser = auth.hasPermission('iam:user:delete');
    final canCreateRole = auth.hasPermission('iam:role:create');
    final canCreateGroup = auth.hasPermission('iam:group:create');
    final canCreateScope = auth.hasPermission('iam:scope:create');

    // RBAC Security Check
    if (!apiClient.isMockMode &&
        !auth.hasRole('SUPERADMIN') &&
        !auth.hasPermission('iam:user:read')) {
      return IamAccessRestrictedView(auth: auth);
    }

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
                  userRoles: _userRolesMap,
                  searchQuery: _searchQuery,
                  canCreate: canCreateUser,
                  canEdit: canEditUser,
                  canUpdateStatus: canUpdateUserStatus,
                  canAssign: canAssignRole,
                  canDelete: canDeleteUser,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  onCreateUser: _showCreateUserDialog,
                  onEditUser: _showEditUserDialog,
                  onAssignRole: _showAssignRoleDialog,
                  onDataReload: _loadAllIamData,
                ),
                IamRolesTab(
                  roles: _roles,
                  canCreateRole: canCreateRole,
                  onCreateRole: _showCreateRoleDialog,
                ),
                IamGroupsTab(
                  groups: _groups,
                  users: _users,
                  roles: _roles,
                  scopes: _scopes,
                  canCreateGroup: canCreateGroup,
                  onCreateGroup: _showCreateGroupDialog,
                  onGroupChanged: _loadAllIamData,
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
