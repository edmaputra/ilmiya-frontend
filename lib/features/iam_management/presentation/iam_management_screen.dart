import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/services/school_service.dart';
import '../../../shared_widgets/tenant_session_required_view.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/assign_role_dialog.dart';
import '../dialogs/create_group_dialog.dart';
import '../dialogs/create_role_dialog.dart';
import '../dialogs/create_scope_dialog.dart';
import '../dialogs/create_user_dialog.dart';
import '../dialogs/edit_role_dialog.dart';
import '../dialogs/edit_scope_dialog.dart';
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
  List<SchoolResponse> _schools = [];
  List<ScopeTreeNode> _rawTenantScopes = [];
  Map<String, UserRoleAssignmentResponse> _userAssignments = {};
  Map<String, List<RoleResponse>> _userRolesMap = {};
  bool _isLoading = true;
  String _searchQuery = '';

  String? _lastTenantId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTenantId = context.watch<AuthNotifier>().tenantId;
    if (_lastTenantId != currentTenantId) {
      _lastTenantId = currentTenantId;
      _loadAllIamData();
    }
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
          _userRolesMap = {};
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tId = auth.tenantId;
      final isSpecificTenant = tId.isNotEmpty && tId != 'platform';
      final results = await Future.wait([
        iamService.listUsers(tenantId: tId).catchError((e) {
          debugPrint('Error loading users: $e');
          return <UserResponse>[];
        }),
        iamService.listRoles(tenantId: tId).catchError((e) {
          debugPrint('Error loading roles: $e');
          return <RoleResponse>[];
        }),
        iamService.listGroups(tenantId: tId).catchError((e) {
          debugPrint('Error loading groups: $e');
          return <GroupResponse>[];
        }),
        iamService.getScopeTree(tenantId: tId).catchError((e) {
          debugPrint('Error loading scopes: $e');
          return <ScopeTreeNode>[];
        }),
        schoolService
            .listSchools(tenantId: tId, bypassTenantHeader: true)
            .catchError((e) {
          debugPrint('Error loading schools: $e');
          return <SchoolResponse>[];
        }),
      ]);

      final users = results[0] as List<UserResponse>;
      final roles = results[1] as List<RoleResponse>;
      final groups = results[2] as List<GroupResponse>;
      final rawScopes = results[3] as List<ScopeTreeNode>;
      final schools = results[4] as List<SchoolResponse>;

      // Filter schools and scope tree based on user's authorized scope path boundary
      _schools = _filterSchoolsForActor(schools, rawScopes, auth);
      final scopes = _filterScopeTreeForActor(rawScopes, auth);

      final userRolesMap = <String, List<RoleResponse>>{};
      final assignments = <String, UserRoleAssignmentResponse>{};
      final displayUsers = <UserResponse>[];

      if (users.isNotEmpty) {
        try {
          final assignmentsLists = await Future.wait(
            users.map((u) => iamService
                .getUserRoles(u.id)
                .catchError((_) => <UserRoleAssignmentResponse>[])),
          );
          for (var i = 0; i < users.length; i++) {
            final user = users[i];
            final uId = user.id;
            final userAssigns = assignmentsLists[i];

            // In a tenant session, verify the user belongs to this tenant
            final tenantAssigns = isSpecificTenant
                ? userAssigns.where((a) => a.tenantId == tId).toList()
                : userAssigns;

            // In a specific tenant context, enforce strict boundary filtering:
            // 1. Users who have role assignments in a different tenant must NOT be visible.
            // 2. Users with no role assignments in this tenant must NOT be visible,
            //    unless the user has zero assignments anywhere (e.g. freshly created unassigned).
            // 3. Platform superadmins without a role in this tenant must NOT be visible in this tenant.
            final hasOtherTenantAssignment = userAssigns.any((a) =>
                a.tenantId != tId &&
                a.tenantId.isNotEmpty &&
                a.tenantId != 'platform');
            if (isSpecificTenant) {
              if (tenantAssigns.isEmpty) {
                if (hasOtherTenantAssignment || userAssigns.isNotEmpty) {
                  continue;
                }
                if (user.isPlatformSuperAdmin) {
                  continue;
                }
              }
            }

            final primaryAssignment = tenantAssigns.isNotEmpty
                ? tenantAssigns.first
                : (userAssigns.isNotEmpty ? userAssigns.first : null);

            // Scope boundary check: non-tenant-wide admins can only see users within their scope subtree
            if (!auth.isTenantWideAdmin && auth.scopes.isNotEmpty) {
              if (primaryAssignment != null &&
                  primaryAssignment.scopeNodeId != null &&
                  primaryAssignment.scopeNodeId!.isNotEmpty) {
                final userScopePath =
                    _findScopePath(rawScopes, primaryAssignment.scopeNodeId);
                if (userScopePath != null &&
                    !auth.canAccessScopePath(userScopePath)) {
                  continue;
                }
              } else if (primaryAssignment == null) {
                // If user has no assignment, only tenant-wide admin can view/manage
                continue;
              }
            }

            displayUsers.add(user);

            if (tenantAssigns.isNotEmpty) {
              assignments[uId] = tenantAssigns.first;
            } else if (userAssigns.isNotEmpty) {
              assignments[uId] = userAssigns.first;
            }

            final assignedRoles = <RoleResponse>[];
            for (final a
                in (tenantAssigns.isNotEmpty ? tenantAssigns : userAssigns)) {
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

      if (displayUsers.isEmpty &&
          users.isNotEmpty &&
          apiClient.isMockMode &&
          !isSpecificTenant) {
        if (auth.isTenantWideAdmin || auth.scopes.isEmpty) {
          displayUsers.addAll(users);
        }
      }

      if (mounted) {
        setState(() {
          _users = displayUsers;
          _roles = roles;
          _groups = groups;
          _scopes = scopes;
          _rawTenantScopes = rawScopes;
          _userAssignments = assignments;
          _userRolesMap = userRolesMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateUserDialog() {
    final tId = context.read<AuthNotifier>().tenantId;
    CreateUserDialog.show(
      context,
      tenantId: tId,
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
    final currentAssignment = _userAssignments[user.id];
    AssignRoleDialog.show(
      context,
      user: user,
      roles: _roles,
      groups: _groups,
      scopes: _scopes,
      schools: _schools,
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

  Future<void> _deleteUser(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = KiteColors.of(ctx);
        final t = KiteText.of(ctx);
        return AlertDialog(
          title: Text('Delete User',
              style: t.h4.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete user "${user.fullName}" (${user.email})? This action cannot be undone.',
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
        await iamService.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('User "${user.fullName}" deleted successfully.')),
          );
        }
        await _loadAllIamData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: $e')),
          );
        }
      }
    }
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

  Future<void> _handleDeleteScope(ScopeTreeNode node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = KiteColors.of(ctx);
        final t = KiteText.of(ctx);
        return AlertDialog(
          title: Text('Delete Scope Node',
              style: t.h4.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete scope "${node.name}" (${node.code})? This action cannot be undone.',
                style: t.small,
              ),
              if (node.children.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.destructive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.destructive.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertTriangle,
                          color: c.destructive, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This scope contains ${node.children.length} sub-scope(s). Deleting it will remove the entire branch.',
                          style: t.small.copyWith(
                            fontSize: 11,
                            color: c.destructive,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
        await iamService.deleteScope(node.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Scope "${node.name}" deleted successfully.')),
          );
        }
        await _loadAllIamData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete scope: $e')),
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

  String? _findScopePath(List<ScopeTreeNode> nodes, String? scopeId) {
    if (scopeId == null) return null;
    for (final n in nodes) {
      if (n.id == scopeId) return n.path;
      final childPath = _findScopePath(n.children, scopeId);
      if (childPath != null) return childPath;
    }
    return null;
  }

  List<ScopeTreeNode> _filterScopeTreeForActor(
      List<ScopeTreeNode> nodes, AuthNotifier auth) {
    if (auth.isTenantWideAdmin || auth.scopes.isEmpty) {
      return nodes;
    }

    final matchedRoots = <ScopeTreeNode>[];

    void findAccessibleRoots(ScopeTreeNode current) {
      // If current node matches or is descendant of user's scopes, this subtree is accessible
      final normalizedPath = current.path.toLowerCase();
      final hasScopeAccess = auth.scopes.any((s) {
        final normS = s.toLowerCase();
        return normalizedPath == normS || normalizedPath.startsWith('$normS/');
      });

      if (hasScopeAccess) {
        matchedRoots.add(current);
        return;
      }

      // If current node is an ancestor of user's scopes, search deeper
      for (final child in current.children) {
        findAccessibleRoots(child);
      }
    }

    for (final root in nodes) {
      findAccessibleRoots(root);
    }

    return matchedRoots;
  }

  List<SchoolResponse> _filterSchoolsForActor(
    List<SchoolResponse> allSchools,
    List<ScopeTreeNode> rawScopes,
    AuthNotifier auth,
  ) {
    if (auth.isTenantWideAdmin || auth.scopes.isEmpty) {
      return allSchools;
    }

    bool scopeMatchesSchool(ScopeTreeNode node, SchoolResponse school) {
      final sId = school.id.toLowerCase();
      final instCode = school.institutionCode.toLowerCase();
      final path = node.path.toLowerCase();
      final code = node.code.toLowerCase();

      if (path.contains(sId) ||
          (instCode.isNotEmpty &&
              (path.contains(instCode) || code == instCode))) {
        return true;
      }
      if (code == 'campus_main' &&
          (school.id == 'sch-001' || allSchools.length == 1)) {
        return true;
      }
      return false;
    }

    final matchedSchoolPaths = <String, Set<String>>{};
    void collectSchoolPaths(ScopeTreeNode node) {
      for (final s in allSchools) {
        if (scopeMatchesSchool(node, s)) {
          final set = matchedSchoolPaths.putIfAbsent(s.id, () => <String>{});
          set.add(node.path.toLowerCase());
        }
      }
      for (final child in node.children) {
        collectSchoolPaths(child);
      }
    }

    for (final root in rawScopes) {
      collectSchoolPaths(root);
    }

    final normalizedUserScopes =
        auth.scopes.map((s) => s.toLowerCase().trim()).toList();

    return allSchools.where((school) {
      // Direct campus match if user has schoolId
      if (auth.schoolId != null && auth.schoolId == school.id) {
        return true;
      }

      // Check against collected scope paths for this school
      final paths = matchedSchoolPaths[school.id];
      if (paths != null && paths.isNotEmpty) {
        for (final schoolPath in paths) {
          final normSchoolPath =
              schoolPath.endsWith('/') ? schoolPath : '$schoolPath/';
          for (final uScope in normalizedUserScopes) {
            final normUScope = uScope.endsWith('/') ? uScope : '$uScope/';
            // User scope is inside school, or school is inside user scope, or exact match
            if (normUScope.startsWith(normSchoolPath) ||
                normSchoolPath.startsWith(normUScope)) {
              return true;
            }
          }
        }
      }

      // Fallback: check if school id or code is directly present in user scope path strings
      final sId = school.id.toLowerCase();
      final instCode = school.institutionCode.toLowerCase();
      return normalizedUserScopes.any((s) =>
          s.contains(sId) || (instCode.isNotEmpty && s.contains(instCode)));
    }).toList();
  }

  void _showCreateScopeDialog({
    String? parentId,
    ScopeTreeNode? parentNode,
    SchoolResponse? school,
  }) {
    CreateScopeDialog.show(
      context,
      parentId: parentId,
      parentNode: parentNode,
      school: school,
      tenantId: context.read<AuthNotifier>().tenantId,
      onScopeCreated: _loadAllIamData,
    );
  }

  void _showEditScopeDialog(ScopeTreeNode node, SchoolResponse? school) {
    EditScopeDialog.show(
      context,
      scope: node,
      allScopes: _rawTenantScopes.isNotEmpty ? _rawTenantScopes : _scopes,
      school: school,
      tenantId: context.read<AuthNotifier>().tenantId,
      onScopeUpdated: _loadAllIamData,
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

    final canCreateUser = auth.hasPermission('iam:user:create') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canEditUser = auth.hasPermission('iam:user:update') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN') ||
        auth.hasPermission('*');
    final canUpdateUserStatus = auth.hasPermission('iam:user:status') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canAssignRole = auth.hasPermission('iam:user:assign-role') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canDeleteUser = auth.hasPermission('iam:user:delete') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canCreateRole = auth.hasPermission('iam:role:create') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canEditRole = auth.hasPermission('iam:role:update') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canDeleteRole = auth.hasPermission('iam:role:delete') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canCreateGroup = auth.hasPermission('iam:group:create') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canCreateScope = auth.hasPermission('iam:scope:create') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canEditScope = auth.hasPermission('iam:scope:update') ||
        auth.hasPermission('iam:scope:move') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final canDeleteScope = auth.hasPermission('iam:scope:delete') ||
        auth.hasRole('SUPERADMIN') ||
        auth.hasRole('TENANT_ADMIN');
    final isTenantAdmin =
        auth.hasRole('SUPERADMIN') || auth.hasRole('TENANT_ADMIN');
    final isCampusAdmin =
        !isTenantAdmin && auth.schoolId != null && auth.schoolId!.isNotEmpty;
    final lockedSchoolId = isCampusAdmin
        ? auth.schoolId
        : (!isTenantAdmin && _schools.length == 1 ? _schools.first.id : null);
    final canCreateRootScope = isTenantAdmin && canCreateScope;
    final isTenantWideAdmin = auth.isTenantWideAdmin;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    final filteredUsers = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final titleColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identity & Access Management (IAM)',
              style: (isNarrow ? t.h3 : t.h2)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isNarrow) ...[
              const SizedBox(height: 2),
              Text(
                'Enterprise ed-iam security console: Users, RBAC Matrix, Directory Groups, and Scopes.',
                style: t.muted,
              ),
            ],
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
              Tab(icon: Icon(LucideIcons.layers, size: 16), text: 'Groups'),
              Tab(
                  icon: Icon(LucideIcons.gitBranch, size: 16),
                  text: 'Scope Tree'),
            ],
          ),
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 12 : 20,
            vertical: isNarrow ? 10 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleColumn,
                    const SizedBox(height: 10),
                    tabBar,
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    tabBar,
                  ],
                ),
              const SizedBox(height: 12),
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
                      userAssignments: _userAssignments,
                      roles: _roles,
                      scopes: _scopes,
                      onSearchChanged: (v) => setState(() => _searchQuery = v),
                      onCreateUser: _showCreateUserDialog,
                      onEditUser: _showEditUserDialog,
                      onAssignRole: _showAssignRoleDialog,
                      onDeleteUser: _deleteUser,
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
                      users: _users,
                      roles: _roles,
                      scopes: _scopes,
                      canCreateGroup: canCreateGroup,
                      onCreateGroup: _showCreateGroupDialog,
                      onGroupChanged: _loadAllIamData,
                    ),
                    IamScopesTab(
                      scopes: _scopes,
                      schools: _schools,
                      tenantId: auth.tenantId,
                      canCreateScope: canCreateScope,
                      canEditScope: canEditScope,
                      canDeleteScope: canDeleteScope,
                      canCreateRootScope: canCreateRootScope,
                      isTenantWideAdmin: isTenantWideAdmin,
                      lockedSchoolId: lockedSchoolId,
                      onCreateRootScope: (school) => _showCreateScopeDialog(
                        parentId: null,
                        school: school,
                      ),
                      onAddChildScope: (parentId, node, school) =>
                          _showCreateScopeDialog(
                        parentId: parentId,
                        parentNode: node,
                        school: school,
                      ),
                      onEditScope: _showEditScopeDialog,
                      onDeleteScope: _handleDeleteScope,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
