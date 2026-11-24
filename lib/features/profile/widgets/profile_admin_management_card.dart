import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../iam_management/dialogs/assign_role_dialog.dart';

class ProfileAdminManagementCard extends StatefulWidget {
  final List<UserResponse> users;
  final List<RoleResponse> roles;
  final IamService iamService;
  final String currentTenantId;
  final Future<void> Function() onDataReload;

  const ProfileAdminManagementCard({
    super.key,
    required this.users,
    this.roles = const [],
    required this.iamService,
    required this.currentTenantId,
    required this.onDataReload,
  });

  @override
  State<ProfileAdminManagementCard> createState() =>
      _ProfileAdminManagementCardState();
}

class _ProfileAdminManagementCardState
    extends State<ProfileAdminManagementCard> {
  UserResponse? _selectedUser;
  late final TextEditingController _nameEditCtrl;
  final _adminResetPasswordCtrl = TextEditingController();

  bool _isUpdatingName = false;
  bool _isResettingPassword = false;
  bool _isUpdatingStatus = false;
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.users.isNotEmpty ? widget.users.first : null;
    _nameEditCtrl = TextEditingController(text: _selectedUser?.fullName ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileAdminManagementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedUser != null) {
      final updated = widget.users.firstWhere((u) => u.id == _selectedUser!.id,
          orElse: () => _selectedUser!);
      _selectedUser = updated;
      _nameEditCtrl.text = updated.fullName;
    } else if (widget.users.isNotEmpty) {
      _selectedUser = widget.users.first;
      _nameEditCtrl.text = _selectedUser!.fullName;
    }
  }

  @override
  void dispose() {
    _nameEditCtrl.dispose();
    _adminResetPasswordCtrl.dispose();
    super.dispose();
  }

  void _onSelectUser(UserResponse user) {
    setState(() {
      _selectedUser = user;
      _nameEditCtrl.text = user.fullName;
      _adminResetPasswordCtrl.clear();
    });
  }

  Future<void> _handleUpdateUserName() async {
    if (_selectedUser == null) return;
    final newName = _nameEditCtrl.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isUpdatingName = true);
    try {
      final updated =
          await widget.iamService.updateUser(_selectedUser!.id, newName);
      setState(() => _selectedUser = updated);
      await widget.onDataReload();
      if (mounted) {
        AppToast.showSuccess(
            context, 'User name updated to "$newName" successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update user name: $e');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingName = false);
    }
  }

  Future<void> _handleAdminResetPassword() async {
    if (_selectedUser == null) return;
    final newPass = _adminResetPasswordCtrl.text.trim();
    if (newPass.length < 6) {
      AppToast.showError(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isResettingPassword = true);
    try {
      await widget.iamService.resetPassword(_selectedUser!.id, newPass);
      _adminResetPasswordCtrl.clear();
      if (mounted) {
        AppToast.showSuccess(
            context, 'Password for ${_selectedUser!.fullName} reset.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to reset password: $e');
      }
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  Future<void> _handleStatusChange(String newStatus) async {
    if (_selectedUser == null || _selectedUser!.status == newStatus) return;

    setState(() => _isUpdatingStatus = true);
    try {
      await widget.iamService.changeUserStatus(_selectedUser!.id, newStatus);
      await widget.onDataReload();
      if (mounted) {
        AppToast.showSuccess(context, 'Account status updated to $newStatus.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update status: $e');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _handleDeleteUser() async {
    if (_selectedUser == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete User'),
        content: Text(
            'Are you sure you want to delete user "${_selectedUser!.fullName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.earthyTerra,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.iamService.deleteUser(_selectedUser!.id);
        _selectedUser = null;
        await widget.onDataReload();
        if (mounted) {
          AppToast.showSuccess(context, 'User deleted successfully.');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'Failed to delete user: $e');
        }
      }
    }
  }

  Future<void> _showAssignRoleDialog() async {
    if (_selectedUser == null) return;
    var roles = widget.roles;
    if (roles.isEmpty) {
      try {
        roles =
            await widget.iamService.listRoles(tenantId: widget.currentTenantId);
      } catch (_) {}
    }
    if (!mounted) return;
    await AssignRoleDialog.show(
      context,
      user: _selectedUser!,
      roles: roles,
      tenantId: widget.currentTenantId,
      onRoleAssigned: widget.onDataReload,
      iamService: widget.iamService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredUsers = widget.users.where((u) {
      if (_searchFilter.isEmpty) return true;
      final q = _searchFilter.toLowerCase();
      return u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.id.toLowerCase().contains(q);
    }).toList();

    return KiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.shieldAlert,
                    color: Color(0xFF7E22CE), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Administration',
                        style: t.large.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF581C87),
                        ),
                      ),
                      Text(
                        'Superadmin privilege: Inspect, edit, reset & govern.',
                        style: t.muted.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SUPERADMIN TOOLKIT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7E22CE),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: c.border),

            // User Picker / Search Header
            Text(
              'Select Account to Manage',
              style: t.small.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('admin_user_search_input'),
              decoration: InputDecoration(
                hintText: 'Search user by name, email, or ID...',
                prefixIcon: const Icon(LucideIcons.search, size: 16),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border),
                ),
              ),
              onChanged: (v) => setState(() => _searchFilter = v.trim()),
            ),
            const SizedBox(height: 10),

            // Quick Chips / List of Users
            if (filteredUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No accounts match the search criteria.',
                    style: t.muted),
              )
            else
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final u = filteredUsers[idx];
                    final isSelected = _selectedUser?.id == u.id;
                    return ChoiceChip(
                      key: Key('admin_user_chip_${u.id}'),
                      label: Text(u.fullName.isNotEmpty ? u.fullName : u.email),
                      selected: isSelected,
                      onSelected: (_) => _onSelectUser(u),
                      selectedColor: const Color(0xFF9333EA).withOpacity(0.15),
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF9333EA) : c.border,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF7E22CE)
                            : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Target Account Management Panel
            if (_selectedUser != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE9D5FF).withOpacity(0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFF9333EA).withOpacity(0.18),
                          child: Text(
                            _selectedUser!.fullName.isNotEmpty
                                ? _selectedUser!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7E22CE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedUser!.fullName,
                                style: t.small
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_selectedUser!.email} • ID: ${_selectedUser!.id}',
                                style: t.muted.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _selectedUser!.status == 'ACTIVE'
                                ? const Color(0xFF16A34A).withOpacity(0.12)
                                : const Color(0xFFDC2626).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _selectedUser!.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _selectedUser!.status == 'ACTIVE'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Edit Target User Full Name
                    Text('Target User Full Name',
                        style: t.small.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('admin_edit_user_name_input'),
                            controller: _nameEditCtrl,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              filled: true,
                              fillColor:
                                  isDark ? AppColors.darkCard : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          key: const Key('admin_save_user_name_btn'),
                          onPressed:
                              _isUpdatingName ? null : _handleUpdateUserName,
                          icon: _isUpdatingName
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.save, size: 14),
                          label: const Text('Save Name'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E22CE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Reset Password for Target User
                    Text('Direct Password Override',
                        style: t.small.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('admin_reset_password_input'),
                            controller: _adminResetPasswordCtrl,
                            decoration: InputDecoration(
                              hintText: 'New password for this user...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              filled: true,
                              fillColor:
                                  isDark ? AppColors.darkCard : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          key: const Key('admin_reset_password_btn'),
                          onPressed: _isResettingPassword
                              ? null
                              : _handleAdminResetPassword,
                          icon: _isResettingPassword
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.key, size: 14),
                          label: const Text('Reset Password'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B21A8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Status and Role Governance Actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('admin_manage_roles_btn'),
                          onPressed: _showAssignRoleDialog,
                          icon: const Icon(LucideIcons.shieldCheck, size: 14),
                          label: const Text('Manage Roles & Scopes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7E22CE),
                            side: const BorderSide(color: Color(0xFFC084FC)),
                          ),
                        ),
                        OutlinedButton(
                          key: const Key('admin_set_active_status_btn'),
                          onPressed: _isUpdatingStatus
                              ? null
                              : () => _handleStatusChange('ACTIVE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF16A34A),
                            side: const BorderSide(color: Color(0xFF86EFAC)),
                          ),
                          child: const Text('Set Active'),
                        ),
                        OutlinedButton(
                          key: const Key('admin_set_suspended_status_btn'),
                          onPressed: _isUpdatingStatus
                              ? null
                              : () => _handleStatusChange('SUSPENDED'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD97706),
                            side: const BorderSide(color: Color(0xFFFDE68A)),
                          ),
                          child: const Text('Suspend'),
                        ),
                        OutlinedButton.icon(
                          key: const Key('admin_delete_user_btn'),
                          onPressed: _handleDeleteUser,
                          icon: const Icon(LucideIcons.trash2,
                              size: 14, color: AppColors.earthyTerra),
                          label: const Text('Delete Account',
                              style: TextStyle(color: AppColors.earthyTerra)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
