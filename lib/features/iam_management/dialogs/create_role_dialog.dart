import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class _PermDef {
  final String code;
  final String label;
  final String description;

  const _PermDef({
    required this.code,
    required this.label,
    required this.description,
  });
}

class _PermCategory {
  final String title;
  final String description;
  final IconData icon;
  final List<_PermDef> permissions;

  const _PermCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.permissions,
  });
}

const List<_PermCategory> _permissionCategories = [
  _PermCategory(
    title: 'Identity & Access (IAM)',
    description: 'User accounts, roles, groups, and scope tree permissions',
    icon: LucideIcons.shieldCheck,
    permissions: [
      _PermDef(
        code: 'iam:user:create',
        label: 'Create User',
        description: 'Register new accounts for staff, teachers, or students',
      ),
      _PermDef(
        code: 'iam:user:read',
        label: 'View Users',
        description:
            'Access user directory, profile details, and role assignments',
      ),
      _PermDef(
        code: 'iam:user:update',
        label: 'Update User',
        description: 'Edit personal metadata and profile information',
      ),
      _PermDef(
        code: 'iam:user:status',
        label: 'Manage User Status',
        description: 'Activate, suspend, or lock user credentials',
      ),
      _PermDef(
        code: 'iam:user:delete',
        label: 'Delete User',
        description: 'Permanently remove a user account from tenant',
      ),
      _PermDef(
        code: 'iam:user:assign-role',
        label: 'Assign User Role',
        description:
            'Attach or revoke RBAC roles with optional scope targeting',
      ),
      _PermDef(
        code: 'iam:user:manage-membership',
        label: 'Manage Group Memberships',
        description: 'Add or remove users from directory groups',
      ),
      _PermDef(
        code: 'iam:role:create',
        label: 'Create Role',
        description: 'Define custom RBAC permission sets',
      ),
      _PermDef(
        code: 'iam:role:read',
        label: 'View Roles',
        description: 'Inspect assigned role matrices and permissions',
      ),
      _PermDef(
        code: 'iam:role:update',
        label: 'Update Role',
        description: 'Edit custom role permissions and metadata',
      ),
      _PermDef(
        code: 'iam:role:delete',
        label: 'Delete Role',
        description: 'Remove custom non-system roles',
      ),
      _PermDef(
        code: 'iam:group:create',
        label: 'Create Group',
        description: 'Create functional directory groups',
      ),
      _PermDef(
        code: 'iam:group:read',
        label: 'View Groups',
        description: 'Inspect group lists, members, and group-level roles',
      ),
      _PermDef(
        code: 'iam:group:update',
        label: 'Update Group',
        description: 'Edit group names, descriptions, and IDP mappings',
      ),
      _PermDef(
        code: 'iam:group:delete',
        label: 'Delete Group',
        description: 'Delete user groups and their membership associations',
      ),
      _PermDef(
        code: 'iam:group:assign-role',
        label: 'Assign Group Role',
        description:
            'Attach roles to entire functional groups with scope support',
      ),
      _PermDef(
        code: 'iam:scope:create',
        label: 'Create Scope',
        description:
            'Add organizational campus or department nodes to hierarchy',
      ),
      _PermDef(
        code: 'iam:scope:read',
        label: 'View Scope Tree',
        description: 'Browse campus and branch organizational tree',
      ),
      _PermDef(
        code: 'iam:scope:update',
        label: 'Update Scope',
        description: 'Modify scope names and descriptive attributes',
      ),
      _PermDef(
        code: 'iam:scope:move',
        label: 'Move Scope',
        description: 'Re-parent scope nodes within the organization hierarchy',
      ),
      _PermDef(
        code: 'iam:scope:delete',
        label: 'Delete Scope',
        description: 'Remove unassigned scope nodes',
      ),
    ],
  ),
  _PermCategory(
    title: 'Institution & Governance',
    description: 'School institutional identity and operational settings',
    icon: LucideIcons.school,
    permissions: [
      _PermDef(
        code: 'school:profile:read',
        label: 'View School Profile',
        description:
            'Read institutional identity, contact, and accreditation details',
      ),
      _PermDef(
        code: 'school:profile:write',
        label: 'Edit School Profile',
        description:
            'Update school details, accreditation status, and addresses',
      ),
      _PermDef(
        code: 'school:settings:manage',
        label: 'Manage Operational Settings',
        description:
            'Configure working days, term layouts, and grading preferences',
      ),
    ],
  ),
  _PermCategory(
    title: 'Academics & Curricula',
    description: 'Academic years, terms, courses, and syllabus management',
    icon: LucideIcons.calendarDays,
    permissions: [
      _PermDef(
        code: 'academic:year:read',
        label: 'View Academic Years',
        description: 'Access academic calendars, active semesters, and terms',
      ),
      _PermDef(
        code: 'academic:year:write',
        label: 'Manage Academic Years',
        description: 'Create, modify, and activate academic terms and cycles',
      ),
      _PermDef(
        code: 'academic:course:read',
        label: 'View Courses',
        description:
            'Browse curriculum offerings, subject codes, and course credits',
      ),
      _PermDef(
        code: 'academic:course:write',
        label: 'Manage Courses',
        description: 'Create and update courses, subject details, and syllabi',
      ),
    ],
  ),
  _PermCategory(
    title: 'Student & Classroom',
    description: 'Student profiles, attendance logs, and examination grading',
    icon: LucideIcons.graduationCap,
    permissions: [
      _PermDef(
        code: 'student:profile:read',
        label: 'View Student Profiles',
        description: 'Read student enrollment data, transcripts, and guardians',
      ),
      _PermDef(
        code: 'student:profile:write',
        label: 'Manage Student Profiles',
        description: 'Update student enrollment records and bio data',
      ),
      _PermDef(
        code: 'attendance:record:read',
        label: 'View Attendance',
        description: 'Monitor daily attendance rates and historical summaries',
      ),
      _PermDef(
        code: 'attendance:record:create',
        label: 'Record Attendance',
        description:
            'Submit daily and subject-level classroom attendance rosters',
      ),
      _PermDef(
        code: 'exam:grade:create',
        label: 'Manage Grades & Scores',
        description:
            'Enter assessment marks, calculate GPA, and finalize gradebook',
      ),
    ],
  ),
];

class CreateRoleDialog extends StatefulWidget {
  final Future<void> Function() onRoleCreated;

  const CreateRoleDialog({
    super.key,
    required this.onRoleCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onRoleCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateRoleDialog(
        onRoleCreated: onRoleCreated,
      ),
    );
  }

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  final _selectedPerms = <String>{'school:profile:read'};
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleCategory(_PermCategory cat, bool selectAll) {
    setState(() {
      for (final p in cat.permissions) {
        if (selectAll) {
          _selectedPerms.add(p.code);
        } else {
          _selectedPerms.remove(p.code);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPerms.isEmpty) {
      AppToast.showError(context, 'Please select at least one permission.');
      return;
    }

    setState(() => _isLoading = true);

    final roleName = _nameCtrl.text.trim();
    try {
      await iamService.createRole(CreateRoleRequest(
        tenantId: apiClient.tenantId,
        code: _codeCtrl.text.trim().toUpperCase(),
        name: roleName,
        description:
            _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        permissions: _selectedPerms.toList(),
      ));

      if (mounted) {
        AppToast.showSuccess(context, "Role '$roleName' created successfully");
        Navigator.of(context).pop();
        await widget.onRoleCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to create role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPermissionsCount = _permissionCategories.fold<int>(
      0,
      (sum, cat) => sum + cat.permissions.length,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
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
                    child: const Icon(LucideIcons.shieldPlus,
                        color: AppColors.forestSage, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Custom Role',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Define role metadata and assign functional permission scopes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_selectedPerms.length} / $totalPermissionsCount Selected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Role Basic Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _codeCtrl,
                            style: const TextStyle(
                                fontSize: 13, fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              labelText: 'Role Code *',
                              hintText: 'e.g. LAB_TECH',
                              prefixIcon:
                                  const Icon(LucideIcons.keyRound, size: 16),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Role code is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Role Name *',
                              hintText: 'e.g. Laboratory Technician',
                              prefixIcon:
                                  const Icon(LucideIcons.shield, size: 16),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Role name is required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText:
                            'Describe duties and authorization scope for this role...',
                        prefixIcon: const Icon(LucideIcons.alignLeft, size: 16),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Permission Search and Filter Toolbar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontSize: 12),
                            onChanged: (val) => setState(
                                () => _searchQuery = val.trim().toLowerCase()),
                            decoration: InputDecoration(
                              hintText:
                                  'Search permissions by name, code or keyword...',
                              prefixIcon:
                                  const Icon(LucideIcons.search, size: 16),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(LucideIcons.x, size: 14),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              for (final cat in _permissionCategories) {
                                for (final p in cat.permissions) {
                                  _selectedPerms.add(p.code);
                                }
                              }
                            });
                          },
                          icon: const Icon(LucideIcons.checkCheck, size: 14),
                          label: const Text('Select All',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _selectedPerms.clear());
                          },
                          icon: const Icon(LucideIcons.rotateCcw, size: 14),
                          label: const Text('Clear',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Permission Matrix Categorized
                    ..._permissionCategories.map((cat) {
                      final filtered = cat.permissions.where((p) {
                        if (_searchQuery.isEmpty) return true;
                        return p.code.toLowerCase().contains(_searchQuery) ||
                            p.label.toLowerCase().contains(_searchQuery) ||
                            p.description.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filtered.isEmpty) return const SizedBox.shrink();

                      final selectedInCat = filtered
                          .where((p) => _selectedPerms.contains(p.code))
                          .length;
                      final isAllSelected = selectedInCat == filtered.length;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Material(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: Theme(
                            data: theme.copyWith(
                                dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(cat.icon,
                                    color: AppColors.forestSage, size: 16),
                              ),
                              title: Text(
                                cat.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                cat.description,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        _toggleCategory(cat, !isAllSelected),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    child: Text(
                                      isAllSelected ? 'Deselect' : 'Select All',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isAllSelected
                                            ? AppColors.earthyTerra
                                            : AppColors.forestSage,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: selectedInCat > 0
                                          ? AppColors.forestSage
                                              .withOpacity(0.12)
                                          : AppColors.warmSand,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$selectedInCat/${filtered.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: selectedInCat > 0
                                            ? AppColors.forestSage
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: filtered.map((perm) {
                                final isSelected =
                                    _selectedPerms.contains(perm.code);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedPerms.remove(perm.code);
                                      } else {
                                        _selectedPerms.add(perm.code);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.forestSage
                                              .withOpacity(0.04)
                                          : Colors.transparent,
                                      border: const Border(
                                        top: BorderSide(
                                            color: AppColors.borderLight,
                                            width: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: AppColors.forestSage,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedPerms.add(perm.code);
                                              } else {
                                                _selectedPerms
                                                    .remove(perm.code);
                                              }
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    perm.label,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .warmSandHover,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      perm.code,
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        fontFamily: 'monospace',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                perm.description,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedPerms.length} permissions configured',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
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
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.check, size: 16),
                    label: const Text('Create Role'),
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
