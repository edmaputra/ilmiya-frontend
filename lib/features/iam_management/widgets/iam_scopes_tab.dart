import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';

class IamScopesTab extends StatefulWidget {
  final List<ScopeTreeNode> scopes;
  final List<SchoolResponse> schools;
  final String tenantId;
  final bool canCreateScope;
  final bool canDeleteScope;
  final void Function(SchoolResponse? school)? onCreateRootScope;
  final void Function(
          String parentId, ScopeTreeNode node, SchoolResponse? school)?
      onAddChildScope;
  final ValueChanged<ScopeTreeNode>? onDeleteScope;

  const IamScopesTab({
    super.key,
    required this.scopes,
    this.schools = const [],
    this.tenantId = '',
    required this.canCreateScope,
    this.canDeleteScope = false,
    this.onCreateRootScope,
    this.onAddChildScope,
    this.onDeleteScope,
  });

  @override
  State<IamScopesTab> createState() => _IamScopesTabState();
}

class _IamScopesTabState extends State<IamScopesTab> {
  String? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    _initSelectedSchool();
  }

  @override
  void didUpdateWidget(covariant IamScopesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedSchool();
  }

  void _initSelectedSchool() {
    if (widget.schools.isNotEmpty) {
      if (_selectedSchoolId == null ||
          !widget.schools.any((s) => s.id == _selectedSchoolId)) {
        _selectedSchoolId = widget.schools.first.id;
      }
    } else {
      _selectedSchoolId = null;
    }
  }

  SchoolResponse? get _selectedSchool {
    if (_selectedSchoolId == null || widget.schools.isEmpty) return null;
    return widget.schools.firstWhere(
      (s) => s.id == _selectedSchoolId,
      orElse: () => widget.schools.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final hasSchools = widget.schools.isNotEmpty;
    final selectedSchool = _selectedSchool;
    final canManageScope = widget.canCreateScope && hasSchools;

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
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
                    'Hierarchical Scope Tree',
                    style: t.large.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'School-anchored authorization boundary and hierarchical RBAC paths.',
                    style: t.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
              ElevatedButton.icon(
                key: const ValueKey('create_root_scope_btn'),
                onPressed: canManageScope
                    ? () => widget.onCreateRootScope?.call(selectedSchool)
                    : null,
                icon: Icon(canManageScope ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create Root Scope'),
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

          // Case 1: No schools registered under this tenant
          if (!hasSchools)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warmSand.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.warmAmber.withOpacity(0.5), width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warmAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.alertTriangle,
                        color: AppColors.warmAmber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'School Required to Manage Scopes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'A tenant must have at least one school before hierarchical scopes can be configured.\n'
                          'The basic scope path requires the format: <tenantId>/<school_id_0>, continuing with custom scopes.\n'
                          'Please register a school under "Institution & Control" -> "Schools & Campuses" first before creating or modifying scopes.',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Case 2: Has schools -> Select school first
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.school,
                      size: 18, color: AppColors.forestSage),
                  const SizedBox(width: 10),
                  const Text(
                    'Select School:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSchool?.id,
                        isExpanded: true,
                        items: widget.schools.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                              '${s.name} (${s.id})',
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSchoolId = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Base scope path preview banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.forestSage.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.forestSage.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.gitBranch,
                      size: 14, color: AppColors.forestSage),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Base Scope Path: /${widget.tenantId.isNotEmpty ? widget.tenantId : "tenant"}/${selectedSchool?.id ?? "school_id"}/',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Scopes list
            Expanded(
              child: ListView(
                children: widget.scopes
                    .map((s) => _buildScopeNodeWidget(
                        context, s, canManageScope, selectedSchool))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeNodeWidget(BuildContext context, ScopeTreeNode node,
      bool canCreate, SchoolResponse? school) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: (node.depth * (isMobile ? 8.0 : 20.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: node.depth == 0 ? c.accent.withOpacity(0.5) : c.card,
              borderRadius: KiteRadius.allMd,
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(
                  node.depth == 0
                      ? LucideIcons.landmark
                      : LucideIcons.folderTree,
                  size: 16,
                  color: c.foreground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            node.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: t.small.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: c.foreground),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: c.muted.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              node.code,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: t.small.copyWith(
                                  fontSize: 9.5,
                                  fontFamily: 'monospace',
                                  color: c.mutedForeground),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        node.path,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: canCreate
                      ? () =>
                          widget.onAddChildScope?.call(node.id, node, school)
                      : null,
                  icon: Icon(
                    canCreate ? LucideIcons.plus : LucideIcons.lock,
                    size: 11,
                  ),
                  label:
                      const Text('Add Child', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: c.primary,
                  ),
                ),
                if (widget.canDeleteScope && widget.onDeleteScope != null) ...[
                  IconButton(
                    key: ValueKey('delete_scope_${node.id}'),
                    icon: const Icon(LucideIcons.trash2, size: 13),
                    tooltip: 'Delete Scope',
                    style: IconButton.styleFrom(
                      foregroundColor: c.destructive,
                      padding: const EdgeInsets.all(2),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(22, 22),
                    ),
                    onPressed: () => widget.onDeleteScope!(node),
                  ),
                ],
              ],
            ),
          ),
          if (node.children.isNotEmpty)
            ...node.children.map((child) =>
                _buildScopeNodeWidget(context, child, canCreate, school)),
        ],
      ),
    );
  }
}
