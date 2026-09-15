import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';
import '../../../state/auth_notifier.dart';

class IamManagementScreen extends StatefulWidget {
  const IamManagementScreen({super.key});

  @override
  State<IamManagementScreen> createState() => _IamManagementScreenState();
}

class _IamManagementScreenState extends State<IamManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UserResponse> _users = [];
  List<RoleResponse> _roles = [];
  List<GroupResponse> _groups = [];
  List<ScopeTreeNode> _scopes = [];
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
    setState(() => _isLoading = true);
    try {
      final u = await iamService.listUsers();
      final r = await iamService.listRoles();
      final g = await iamService.listGroups();
      final s = await iamService.getScopeTree();
      if (mounted) {
        setState(() {
          _users = u;
          _roles = r;
          _groups = g;
          _scopes = s;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateUserDialog() {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    bool isSuperAdmin = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Create New User', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 10),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Platform SuperAdmin', style: TextStyle(fontSize: 13)),
                value: isSuperAdmin,
                onChanged: (v) => setDlgState(() => isSuperAdmin = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              onPressed: () async {
                await iamService.createUser(CreateUserRequest(
                  email: emailCtrl.text.trim(),
                  fullName: nameCtrl.text.trim(),
                  isPlatformSuperAdmin: isSuperAdmin,
                ));
                if (mounted) {
                  Navigator.of(ctx).pop();
                  _loadAllIamData();
                }
              },
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignRoleDialog(UserResponse user) {
    if (_roles.isEmpty) return;
    String selectedRoleId = _roles.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.forestSage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assign Role: ${user.fullName}',
                  style: const TextStyle(fontFamily: 'serif', fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Role to assign to user in this tenant:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRoleId,
                items: _roles.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.name} (${r.code})'))).toList(),
                onChanged: (v) => setDlgState(() => selectedRoleId = v ?? selectedRoleId),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              onPressed: () async {
                await iamService.assignRole(
                  userId: user.id,
                  roleId: selectedRoleId,
                  tenantId: user.id,
                );
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role successfully assigned')),
                  );
                }
              },
              child: const Text('Assign Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoleDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedPerms = <String>{'school:profile:read'};

    final allPermissions = [
      'school:profile:read',
      'school:profile:write',
      'school:settings:manage',
      'academic:year:read',
      'academic:year:write',
      'academic:course:read',
      'academic:course:write',
      'student:profile:read',
      'student:profile:write',
      'attendance:record:read',
      'attendance:record:create',
      'exam:grade:create',
      'iam:user:create',
      'iam:user:read',
      'iam:role:create',
      'iam:group:create',
      'iam:scope:create',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_moderator_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Create Custom Role', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Role Code (e.g. LAB_TECH)')),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Role Name')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 14),
                const Text('Permissions Matrix:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allPermissions.map((perm) {
                    final isSel = selectedPerms.contains(perm);
                    return FilterChip(
                      label: Text(perm, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                      selected: isSel,
                      selectedColor: AppColors.warmSand,
                      checkmarkColor: AppColors.forestSage,
                      onSelected: (val) {
                        setDlgState(() {
                          if (val) {
                            selectedPerms.add(perm);
                          } else {
                            selectedPerms.remove(perm);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              onPressed: () async {
                await iamService.createRole(CreateRoleRequest(
                  code: codeCtrl.text.trim().toUpperCase(),
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  permissions: selectedPerms.toList(),
                ));
                if (mounted) {
                  Navigator.of(ctx).pop();
                  _loadAllIamData();
                }
              },
              child: const Text('Create Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final idpCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.group_add_rounded, color: AppColors.forestSage),
            SizedBox(width: 8),
            Text('Create User Group', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Group Code')),
            const SizedBox(height: 10),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group Name')),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            TextField(controller: idpCtrl, decoration: const InputDecoration(labelText: 'External IdP Mapping (Optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
            onPressed: () async {
              await iamService.createGroup(CreateGroupRequest(
                code: codeCtrl.text.trim().toUpperCase(),
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                externalIdpGroupName: idpCtrl.text.trim().isNotEmpty ? idpCtrl.text.trim() : null,
              ));
              if (mounted) {
                Navigator.of(ctx).pop();
                _loadAllIamData();
              }
            },
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  void _showCreateScopeDialog({String? parentId}) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: AppColors.forestSage),
            const SizedBox(width: 8),
            Text(parentId == null ? 'Create Root Scope' : 'Add Child Scope', style: const TextStyle(fontFamily: 'serif', fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Scope Code (e.g. DEPT_SCIENCE)')),
            const SizedBox(height: 10),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Scope Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
            onPressed: () async {
              await iamService.createScope(CreateScopeRequest(
                code: codeCtrl.text.trim().toUpperCase(),
                name: nameCtrl.text.trim(),
                parentId: parentId,
              ));
              if (mounted) {
                Navigator.of(ctx).pop();
                _loadAllIamData();
              }
            },
            child: const Text('Save Scope'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canCreateUser = auth.hasPermission('iam:user:create');
    final canUpdateUserStatus = auth.hasPermission('iam:user:status');
    final canAssignRole = auth.hasPermission('iam:user:assign-role');
    final canDeleteUser = auth.hasPermission('iam:user:delete');
    final canCreateRole = auth.hasPermission('iam:role:create');
    final canCreateGroup = auth.hasPermission('iam:group:create');
    final canCreateScope = auth.hasPermission('iam:scope:create');

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.forestSage));
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
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity & Access Management (IAM)',
                      style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enterprise ed-iam security console: Users, RBAC Matrix, Directory Groups, and Scopes.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.forestSage,
                  labelColor: AppColors.forestSage,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(icon: Icon(Icons.people_outline, size: 16), text: 'Users'),
                    Tab(icon: Icon(Icons.shield_outlined, size: 16), text: 'Roles & RBAC'),
                    Tab(icon: Icon(Icons.groups_outlined, size: 16), text: 'Groups'),
                    Tab(icon: Icon(Icons.account_tree_outlined, size: 16), text: 'Scope Tree'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Users
                _buildUsersTab(filteredUsers, canCreateUser, canUpdateUserStatus, canAssignRole, canDeleteUser),

                // Tab 2: Roles
                _buildRolesTab(canCreateRole),

                // Tab 3: Groups
                _buildGroupsTab(canCreateGroup),

                // Tab 4: Scopes
                _buildScopesTab(canCreateScope),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(List<UserResponse> users, bool canCreate, bool canUpdateStatus, bool canAssign, bool canDelete) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    hintText: 'Search user by name or email...',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canCreate ? _showCreateUserDialog : null,
                icon: Icon(canCreate ? Icons.add : Icons.lock_outline, size: 16),
                label: const Text('Create User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final u = users[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.warmSand,
                    child: Text(u.fullName[0], style: const TextStyle(color: AppColors.forestSage, fontWeight: FontWeight.bold)),
                  ),
                  title: Row(
                    children: [
                      Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (u.isPlatformSuperAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            'SUPERADMIN',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(u.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: u.status,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        items: ['ACTIVE', 'SUSPENDED', 'PENDING_ACTIVATION', 'DEACTIVATED']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: canUpdateStatus
                            ? (val) async {
                                if (val != null) {
                                  await iamService.changeUserStatus(u.id, val);
                                  _loadAllIamData();
                                }
                              }
                            : null,
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: canAssign ? () => _showAssignRoleDialog(u) : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          foregroundColor: AppColors.forestSage,
                        ),
                        child: const Text('Assign Role', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.earthyTerra),
                        onPressed: canDelete
                            ? () async {
                                await iamService.deleteUser(u.id);
                                _loadAllIamData();
                              }
                            : null,
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

  Widget _buildRolesTab(bool canCreateRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Role-Based Access Control (RBAC) Matrix',
                style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateRole ? _showCreateRoleDialog : null,
                icon: Icon(canCreateRole ? Icons.add : Icons.lock_outline, size: 16),
                label: const Text('Create Custom Role'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _roles.length,
              itemBuilder: (ctx, i) {
                final r = _roles[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.naturalParchment,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (r.isSystemRole)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.warmSand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('SYSTEM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.forestSage)),
                            ),
                        ],
                      ),
                      Text(r.code, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Text(r.description ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2),
                      const Spacer(),
                      Text('Permissions (${r.permissions.length}):', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: r.permissions.map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(p, style: const TextStyle(fontSize: 8, fontFamily: 'monospace')),
                            )).toList(),
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

  Widget _buildGroupsTab(bool canCreateGroup) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Groups & Directory Integrations',
                style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateGroup ? _showCreateGroupDialog : null,
                icon: Icon(canCreateGroup ? Icons.add : Icons.lock_outline, size: 16),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: _groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final g = _groups[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.naturalParchment,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_outlined, color: AppColors.forestSage, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Code: ${g.code} • ${g.description ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            if (g.externalIdpGroupName != null)
                              Text('IdP Mapping: ${g.externalIdpGroupName}', style: const TextStyle(fontSize: 10, color: AppColors.forestSage, fontFamily: 'monospace')),
                          ],
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

  Widget _buildScopesTab(bool canCreateScope) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hierarchical Scope Tree',
                style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateScope ? () => _showCreateScopeDialog(parentId: null) : null,
                icon: Icon(canCreateScope ? Icons.add : Icons.lock_outline, size: 16),
                label: const Text('Create Root Scope'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: _scopes.map((s) => _buildScopeNodeWidget(s, canCreateScope)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeNodeWidget(ScopeTreeNode node, bool canCreateScope) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: (node.depth * 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: node.depth == 0 ? AppColors.warmSand : AppColors.naturalParchment,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  node.depth == 0 ? Icons.account_balance_outlined : Icons.folder_open_outlined,
                  size: 16,
                  color: AppColors.forestSage,
                ),
                const SizedBox(width: 8),
                Text(node.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(node.code, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMuted)),
                const Spacer(),
                TextButton.icon(
                  onPressed: canCreateScope ? () => _showCreateScopeDialog(parentId: node.id) : null,
                  icon: Icon(canCreateScope ? Icons.add : Icons.lock_outline, size: 12),
                  label: const Text('Add Child', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          ),
          if (node.children.isNotEmpty)
            ...node.children.map((c) => _buildScopeNodeWidget(c, canCreateScope)),
        ],
      ),
    );
  }
}
