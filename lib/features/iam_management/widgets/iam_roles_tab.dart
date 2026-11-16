import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';

class IamRolesTab extends StatefulWidget {
  final List<RoleResponse> roles;
  final bool canCreateRole;
  final VoidCallback onCreateRole;
  final ValueChanged<RoleResponse>? onEditRole;
  final ValueChanged<RoleResponse>? onDeleteRole;
  final bool canEditRole;
  final bool canDeleteRole;

  const IamRolesTab({
    super.key,
    required this.roles,
    required this.canCreateRole,
    required this.onCreateRole,
    this.onEditRole,
    this.onDeleteRole,
    this.canEditRole = true,
    this.canDeleteRole = true,
  });

  @override
  State<IamRolesTab> createState() => _IamRolesTabState();
}

class _IamRolesTabState extends State<IamRolesTab> {
  String _searchQuery = '';
  String _filterType = 'ALL'; // ALL, SYSTEM, CUSTOM

  Map<String, int> _summarizePermissions(List<String> perms) {
    final counts = <String, int>{};
    for (final p in perms) {
      if (p == '*') {
        counts['Full Access'] = 1;
        continue;
      }
      final domain = p.split(':').first;
      final label = switch (domain) {
        'iam' => 'IAM',
        'school' => 'School',
        'academic' => 'Academics',
        'student' => 'Students',
        'attendance' => 'Attendance',
        'exam' => 'Examinations',
        _ => domain.toUpperCase(),
      };
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  void _inspectRolePermissions(BuildContext context, RoleResponse role) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.forestSage.withOpacity(0.08),
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
                        child: const Icon(LucideIcons.shieldCheck,
                            color: AppColors.forestSage, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    role.name,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: role.isSystemRole
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    role.isSystemRole ? 'SYSTEM' : 'CUSTOM',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: role.isSystemRole
                                          ? const Color(0xFF1D4ED8)
                                          : const Color(0xFF7E22CE),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${role.code} • ${role.permissions.length} permissions configured',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (role.description != null &&
                          role.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.description!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Assigned Permissions',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: role.permissions.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warmSandHover,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              p,
                              style: const TextStyle(
                                  fontSize: 11, fontFamily: 'monospace'),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final filtered = widget.roles.where((r) {
      if (_filterType == 'SYSTEM' && !r.isSystemRole) return false;
      if (_filterType == 'CUSTOM' && r.isSystemRole) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return r.name.toLowerCase().contains(q) ||
            r.code.toLowerCase().contains(q) ||
            (r.description ?? '').toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.search,
                        size: 18, color: c.mutedForeground),
                    hintText: 'Search roles by name, code...',
                    hintStyle: t.small.copyWith(color: c.mutedForeground),
                    isDense: true,
                    fillColor: c.card,
                    border: const OutlineInputBorder(
                        borderRadius: KiteRadius.allMd),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ALL', label: Text('All')),
                  ButtonSegment(value: 'SYSTEM', label: Text('System')),
                  ButtonSegment(value: 'CUSTOM', label: Text('Custom')),
                ],
                selected: {_filterType},
                onSelectionChanged: (set) {
                  setState(() => _filterType = set.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: widget.canCreateRole ? widget.onCreateRole : null,
                icon: Icon(
                    widget.canCreateRole ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Custom Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No roles found',
                        style: t.small.copyWith(color: c.mutedForeground)),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      mainAxisExtent: 180,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final r = filtered[i];
                      final summary = _summarizePermissions(r.permissions);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: t.small.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: c.foreground,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        r.code,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: r.isSystemRole
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFFFAF5FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: r.isSystemRole
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFFE9D5FF),
                                    ),
                                  ),
                                  child: Text(
                                    r.isSystemRole ? 'SYSTEM' : 'CUSTOM',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: r.isSystemRole
                                          ? const Color(0xFF475569)
                                          : const Color(0xFF7E22CE),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: Text(
                                (r.description != null &&
                                        r.description!.isNotEmpty)
                                    ? r.description!
                                    : 'No detailed description provided for this role.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c.mutedForeground,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Divider(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: summary.entries.take(2).map((e) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.warmSandHover,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${e.key} (${e.value})',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _inspectRolePermissions(context, r),
                                  icon: const Icon(LucideIcons.eye, size: 13),
                                  label: Text(
                                    '${r.permissions.length} Perms',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                if (!r.isSystemRole &&
                                    widget.canEditRole &&
                                    widget.onEditRole != null) ...[
                                  const SizedBox(width: 2),
                                  IconButton(
                                    tooltip: 'Edit Role',
                                    icon: const Icon(LucideIcons.pencil,
                                        size: 14),
                                    onPressed: () => widget.onEditRole!(r),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                                if (!r.isSystemRole &&
                                    widget.canDeleteRole &&
                                    widget.onDeleteRole != null) ...[
                                  const SizedBox(width: 2),
                                  IconButton(
                                    tooltip: 'Delete Role',
                                    icon: Icon(LucideIcons.trash2,
                                        size: 14, color: c.destructive),
                                    onPressed: () => widget.onDeleteRole!(r),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ],
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
}
