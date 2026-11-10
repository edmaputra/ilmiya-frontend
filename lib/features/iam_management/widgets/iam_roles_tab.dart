import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';

class IamRolesTab extends StatefulWidget {
  final List<RoleResponse> roles;
  final bool canCreateRole;
  final VoidCallback onCreateRole;

  const IamRolesTab({
    super.key,
    required this.roles,
    required this.canCreateRole,
    required this.onCreateRole,
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
        final summary = _summarizePermissions(role.permissions);
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
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF9333EA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Code: ${role.code} • ${role.permissions.length} permissions configured',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: summary.entries.map((e) {
                      return Chip(
                        label: Text('${e.key}: ${e.value}',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.warmSandHover,
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: role.permissions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (c, idx) {
                      final p = role.permissions[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.check,
                                color: AppColors.forestSage, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
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
      if (_searchQuery.isEmpty) return true;
      return r.name.toLowerCase().contains(_searchQuery) ||
          r.code.toLowerCase().contains(_searchQuery) ||
          (r.description?.toLowerCase().contains(_searchQuery) ?? false) ||
          r.permissions.any((p) => p.toLowerCase().contains(_searchQuery));
    }).toList();

    return KiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles & RBAC Matrix',
                    style: t.large.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                  Text(
                    'Define role access boundaries and organizational authority rules',
                    style: t.small.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.canCreateRole ? widget.onCreateRole : null,
                icon: Icon(
                  widget.canCreateRole ? LucideIcons.plus : LucideIcons.lock,
                  size: 16,
                ),
                label: const Text('Create Custom Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and Filters Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search roles by name, code or permission...',
                    prefixIcon: const Icon(LucideIcons.search, size: 16),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'ALL',
                    label: Text('All', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 'SYSTEM',
                    label: Text('System', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 'CUSTOM',
                    label: Text('Custom', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_filterType},
                onSelectionChanged: (val) {
                  setState(() => _filterType = val.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Role Grid / Directory
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shieldOff,
                            size: 40, color: c.mutedForeground),
                        const SizedBox(height: 10),
                        Text(
                          'No roles match your search criteria',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 440,
                      mainAxisExtent: 220,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final r = filtered[i];
                      final summary = _summarizePermissions(r.permissions);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: r.isSystemRole
                                        ? const Color(0xFFEFF6FF)
                                        : AppColors.forestSage.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    r.isSystemRole
                                        ? LucideIcons.shieldCheck
                                        : LucideIcons.shield,
                                    size: 18,
                                    color: r.isSystemRole
                                        ? const Color(0xFF2563EB)
                                        : AppColors.forestSage,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        r.code,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
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
                                    children: summary.entries.take(3).map((e) {
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
                                const SizedBox(width: 8),
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
                                        horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
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
