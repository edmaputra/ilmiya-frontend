import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
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
    final auth = context.read<AuthNotifier>();
    if (!apiClient.isMockMode && !auth.hasRole('SUPERADMIN') && !auth.hasPermission('iam:user:read')) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _users = [];
          _roles = [];
          _groups = [];
          _scopes = [];
        });
      }
      return;
    }

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
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) await _loadAllIamData();
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
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
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
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) await _loadAllIamData();
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
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) await _loadAllIamData();
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
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) await _loadAllIamData();
            },
            child: const Text('Save Scope'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();
    final canCreateUser = auth.hasPermission('iam:user:create');
    final canUpdateUserStatus = auth.hasPermission('iam:user:status');
    final canAssignRole = auth.hasPermission('iam:user:assign-role');
    final canDeleteUser = auth.hasPermission('iam:user:delete');
    final canCreateRole = auth.hasPermission('iam:role:create');
    final canCreateGroup = auth.hasPermission('iam:group:create');
    final canCreateScope = auth.hasPermission('iam:scope:create');

    if (!apiClient.isMockMode && !auth.hasRole('SUPERADMIN') && !auth.hasPermission('iam:user:read')) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.shieldAlert, size: 48, color: Color(0xFFD97706)),
              const SizedBox(height: 16),
              const Text(
                'IAM Console Restricted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif'),
              ),
              const SizedBox(height: 8),
              Text(
                'Identity & Access Management console requires platform administrator privileges (SUPERADMIN or iam:user:read).\n\nYour active role is ${auth.roles.isNotEmpty ? auth.roles.first : "School Administrator"} for tenant ${auth.tenantId}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
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
                    style: t.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enterprise ed-iam security console: Users, RBAC Matrix, Directory Groups, and Scopes.',
                    style: t.muted,
                  ),
                ],
              );

              final tabBar = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isNarrow ? double.infinity : 480),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: c.primary,
                  labelColor: c.foreground,
                  unselectedLabelColor: c.mutedForeground,
                  tabs: const [
                    Tab(icon: Icon(LucideIcons.users, size: 16), text: 'Users'),
                    Tab(icon: Icon(LucideIcons.shieldCheck, size: 16), text: 'Roles & RBAC'),
                    Tab(icon: Icon(LucideIcons.layers, size: 16), text: 'Groups'),
                    Tab(icon: Icon(LucideIcons.gitBranch, size: 16), text: 'Scope Tree'),
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
                // Tab 1: Users
                _buildUsersTab(context, filteredUsers, canCreateUser, canUpdateUserStatus, canAssignRole, canDeleteUser),

                // Tab 2: Roles
                _buildRolesTab(context, canCreateRole),

                // Tab 3: Groups
                _buildGroupsTab(context, canCreateGroup),

                // Tab 4: Scopes
                _buildScopesTab(context, canCreateScope),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, List<UserResponse> users, bool canCreate, bool canUpdateStatus, bool canAssign, bool canDelete) {
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
                    prefixIcon: Icon(LucideIcons.search, size: 18, color: c.mutedForeground),
                    hintText: 'Search user by name or email...',
                    hintStyle: t.small.copyWith(color: c.mutedForeground),
                    isDense: true,
                    fillColor: c.card,
                    border: const OutlineInputBorder(borderRadius: KiteRadius.allMd),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canCreate ? _showCreateUserDialog : null,
                icon: Icon(canCreate ? LucideIcons.plus : LucideIcons.lock, size: 16),
                label: const Text('Create User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
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
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 640;
                    if (isNarrow) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: c.accent,
                                  child: Text(
                                    u.fullName.isNotEmpty ? u.fullName[0] : '?',
                                    style: TextStyle(color: c.foreground, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 2,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            u.fullName,
                                            style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                                          ),
                                          if (u.isPlatformSuperAdmin)
                                            const KiteBadge('SUPERADMIN', tone: KiteTone.warning),
                                        ],
                                      ),
                                      Text(u.email, style: t.small.copyWith(fontSize: 11, color: c.mutedForeground)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                DropdownButton<String>(
                                  value: u.status,
                                  underline: const SizedBox(),
                                  dropdownColor: c.card,
                                  style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                                  items: ['ACTIVE', 'SUSPENDED', 'PENDING_ACTIVATION', 'DEACTIVATED']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: canUpdateStatus
                                      ? (val) async {
                                          if (val != null) {
                                            await iamService.changeUserStatus(u.id, val);
                                            if (mounted) await _loadAllIamData();
                                          }
                                        }
                                      : null,
                                ),
                                OutlinedButton(
                                  onPressed: canAssign ? () => _showAssignRoleDialog(u) : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    foregroundColor: c.primary,
                                    side: BorderSide(color: c.border),
                                    shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allSm),
                                  ),
                                  child: const Text('Assign Role', style: TextStyle(fontSize: 11)),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.trash2, size: 16, color: c.destructive),
                                  onPressed: canDelete
                                      ? () async {
                                          await iamService.deleteUser(u.id);
                                          if (mounted) await _loadAllIamData();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: CircleAvatar(
                        backgroundColor: c.accent,
                        child: Text(
                          u.fullName.isNotEmpty ? u.fullName[0] : '?',
                          style: TextStyle(color: c.foreground, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(u.fullName, style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground)),
                          if (u.isPlatformSuperAdmin)
                            const KiteBadge('SUPERADMIN', tone: KiteTone.warning),
                        ],
                      ),
                      subtitle: Text(u.email, style: t.small.copyWith(fontSize: 11, color: c.mutedForeground)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: u.status,
                            underline: const SizedBox(),
                            dropdownColor: c.card,
                            style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                            items: ['ACTIVE', 'SUSPENDED', 'PENDING_ACTIVATION', 'DEACTIVATED']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: canUpdateStatus
                                ? (val) async {
                                    if (val != null) {
                                      await iamService.changeUserStatus(u.id, val);
                                      if (mounted) await _loadAllIamData();
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: canAssign ? () => _showAssignRoleDialog(u) : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              foregroundColor: c.primary,
                              side: BorderSide(color: c.border),
                              shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allSm),
                            ),
                            child: const Text('Assign Role', style: TextStyle(fontSize: 11)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(LucideIcons.trash2, size: 16, color: c.destructive),
                            onPressed: canDelete
                                ? () async {
                                    await iamService.deleteUser(u.id);
                                    if (mounted) await _loadAllIamData();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab(BuildContext context, bool canCreateRole) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Role-Based Access Control (RBAC) Matrix',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateRole ? _showCreateRoleDialog : null,
                icon: Icon(canCreateRole ? LucideIcons.plus : LucideIcons.lock, size: 16),
                label: const Text('Create Custom Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
                ),
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
                    color: c.card,
                    borderRadius: KiteRadius.allMd,
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
                              style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground),
                            ),
                          ),
                          if (r.isSystemRole)
                            const KiteBadge('SYSTEM', tone: KiteTone.info),
                        ],
                      ),
                      Text(r.code, style: t.small.copyWith(fontSize: 10, fontFamily: 'monospace', color: c.mutedForeground)),
                      const SizedBox(height: 6),
                      Text(r.description ?? '', style: t.small.copyWith(fontSize: 11, color: c.mutedForeground), maxLines: 2),
                      const Spacer(),
                      Text('Permissions (${r.permissions.length}):', style: t.small.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: c.foreground)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: r.permissions.map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: c.accent,
                                borderRadius: KiteRadius.allSm,
                                border: Border.all(color: c.border),
                              ),
                              child: Text(p, style: t.small.copyWith(fontSize: 8, fontFamily: 'monospace', color: c.foreground)),
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

  Widget _buildGroupsTab(BuildContext context, bool canCreateGroup) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'User Groups & Directory Integrations',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateGroup ? _showCreateGroupDialog : null,
                icon: Icon(canCreateGroup ? LucideIcons.plus : LucideIcons.lock, size: 16),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
                ),
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
                    color: c.card,
                    borderRadius: KiteRadius.allMd,
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.users, color: c.foreground, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.name, style: t.small.copyWith(fontWeight: FontWeight.bold, color: c.foreground)),
                            Text('Code: ${g.code} • ${g.description ?? ''}', style: t.small.copyWith(fontSize: 11, color: c.mutedForeground)),
                            if (g.externalIdpGroupName != null)
                              Text('IdP Mapping: ${g.externalIdpGroupName}', style: t.small.copyWith(fontSize: 10, color: c.primary, fontFamily: 'monospace')),
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

  Widget _buildScopesTab(BuildContext context, bool canCreateScope) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Hierarchical Scope Tree',
                style: t.large.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: canCreateScope ? () => _showCreateScopeDialog(parentId: null) : null,
                icon: Icon(canCreateScope ? LucideIcons.plus : LucideIcons.lock, size: 16),
                label: const Text('Create Root Scope'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: _scopes.map((s) => _buildScopeNodeWidget(context, s, canCreateScope)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeNodeWidget(BuildContext context, ScopeTreeNode node, bool canCreateScope) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: (node.depth * 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: node.depth == 0 ? c.accent.withOpacity(0.5) : c.card,
              borderRadius: KiteRadius.allMd,
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(
                  node.depth == 0 ? LucideIcons.landmark : LucideIcons.folderTree,
                  size: 16,
                  color: c.foreground,
                ),
                const SizedBox(width: 8),
                Text(node.name, style: t.small.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: c.foreground)),
                const SizedBox(width: 8),
                Text(node.code, style: t.small.copyWith(fontSize: 10, fontFamily: 'monospace', color: c.mutedForeground)),
                const Spacer(),
                TextButton.icon(
                  onPressed: canCreateScope ? () => _showCreateScopeDialog(parentId: node.id) : null,
                  icon: Icon(canCreateScope ? LucideIcons.plus : LucideIcons.lock, size: 12),
                  label: const Text('Add Child', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: c.primary),
                ),
              ],
            ),
          ),
          if (node.children.isNotEmpty)
            ...node.children.map((child) => _buildScopeNodeWidget(context, child, canCreateScope)),
        ],
      ),
    );
  }
}
