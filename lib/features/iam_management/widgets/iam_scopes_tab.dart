import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';
import '../../../core/utils/app_toast.dart';

enum ScopeNodeType {
  tenantRoot,
  campusAnchor,
  childScope,
}

class IamScopesTab extends StatefulWidget {
  final List<ScopeTreeNode> scopes;
  final List<SchoolResponse> schools;
  final String tenantId;
  final bool canCreateScope;
  final bool canEditScope;
  final bool canDeleteScope;
  final bool canCreateRootScope;
  final bool isTenantWideAdmin;
  final String? lockedSchoolId;
  final void Function(SchoolResponse? school)? onCreateRootScope;
  final void Function(
          String parentId, ScopeTreeNode node, SchoolResponse? school)?
      onAddChildScope;
  final void Function(ScopeTreeNode node, SchoolResponse? school)? onEditScope;
  final ValueChanged<ScopeTreeNode>? onDeleteScope;

  const IamScopesTab({
    super.key,
    required this.scopes,
    this.schools = const [],
    this.tenantId = '',
    required this.canCreateScope,
    this.canEditScope = false,
    this.canDeleteScope = false,
    this.canCreateRootScope = true,
    this.isTenantWideAdmin = true,
    this.lockedSchoolId,
    this.onCreateRootScope,
    this.onAddChildScope,
    this.onEditScope,
    this.onDeleteScope,
  });

  @override
  State<IamScopesTab> createState() => _IamScopesTabState();
}

class _IamScopesTabState extends State<IamScopesTab> {
  static const String _allSchoolsId = '__ALL__';

  String? _selectedSchoolId;
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _collapsedNodeIds = {};

  @override
  void initState() {
    super.initState();
    _initSelectedSchool();
  }

  @override
  void didUpdateWidget(covariant IamScopesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lockedSchoolId != widget.lockedSchoolId ||
        oldWidget.schools != widget.schools) {
      _initSelectedSchool();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _initSelectedSchool() {
    if (widget.lockedSchoolId != null && widget.lockedSchoolId!.isNotEmpty) {
      _selectedSchoolId = widget.lockedSchoolId;
      return;
    }

    if (widget.schools.isNotEmpty) {
      if (_selectedSchoolId == null ||
          (_selectedSchoolId != _allSchoolsId &&
              !widget.schools.any((s) => s.id == _selectedSchoolId))) {
        _selectedSchoolId = widget.schools.first.id;
      }
    } else {
      _selectedSchoolId = null;
    }
  }

  SchoolResponse? get _selectedSchool {
    if (_selectedSchoolId == null ||
        _selectedSchoolId == _allSchoolsId ||
        widget.schools.isEmpty) {
      return null;
    }
    return widget.schools.firstWhere(
      (s) => s.id == _selectedSchoolId,
      orElse: () => widget.schools.first,
    );
  }

  ScopeNodeType _resolveNodeType(ScopeTreeNode node) {
    if (node.depth == 0) {
      final isCampus = widget.schools.any((s) =>
          node.path.contains(s.id) ||
          (s.institutionCode.isNotEmpty &&
              (node.code.toUpperCase() == s.institutionCode.toUpperCase() ||
                  node.path
                      .toUpperCase()
                      .contains(s.institutionCode.toUpperCase()))) ||
          node.code.startsWith('CAMPUS_'));
      if (isCampus) {
        return ScopeNodeType.campusAnchor;
      }
      return ScopeNodeType.tenantRoot;
    }

    final isCampus = widget.schools.any((s) =>
        node.path.endsWith('/${s.id}') ||
        node.path == '/${widget.tenantId}/${s.id}' ||
        (s.institutionCode.isNotEmpty &&
            node.code.toUpperCase() == s.institutionCode.toUpperCase()));
    if (isCampus && node.depth == 1) {
      return ScopeNodeType.campusAnchor;
    }

    return ScopeNodeType.childScope;
  }

  bool _scopeMatchesSchool(ScopeTreeNode node, SchoolResponse school) {
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
        (school.id == 'sch-001' || widget.schools.length == 1)) {
      return true;
    }
    return false;
  }

  bool _nodeOrDescendantMatches(ScopeTreeNode node, SchoolResponse school) {
    if (_scopeMatchesSchool(node, school)) return true;
    for (final child in node.children) {
      if (_nodeOrDescendantMatches(child, school)) return true;
    }
    return false;
  }

  List<ScopeTreeNode> _filterBySearch(List<ScopeTreeNode> nodes, String query) {
    final result = <ScopeTreeNode>[];
    for (final node in nodes) {
      final selfMatches = node.name.toLowerCase().contains(query) ||
          node.code.toLowerCase().contains(query) ||
          node.path.toLowerCase().contains(query);
      final filteredChildren = _filterBySearch(node.children, query);
      if (selfMatches || filteredChildren.isNotEmpty) {
        result.add(ScopeTreeNode(
          id: node.id,
          code: node.code,
          name: node.name,
          path: node.path,
          depth: node.depth,
          parentId: node.parentId,
          children:
              filteredChildren.isNotEmpty ? filteredChildren : node.children,
        ));
      }
    }
    return result;
  }

  List<ScopeTreeNode> _getDisplayScopes(
      SchoolResponse? school, String searchQuery) {
    List<ScopeTreeNode> list;
    if (school == null || !widget.isTenantWideAdmin) {
      list = widget.scopes;
    } else {
      bool matchesAnyOtherSchool(ScopeTreeNode n) => widget.schools
          .where((s) => s.id != school.id)
          .any((other) => _nodeOrDescendantMatches(n, other));

      list = widget.scopes.where((node) {
        if (_nodeOrDescendantMatches(node, school)) return true;
        if (node.depth == 0 && !matchesAnyOtherSchool(node)) return true;
        return false;
      }).toList();
    }

    if (searchQuery.trim().isEmpty) return list;
    return _filterBySearch(list, searchQuery.trim().toLowerCase());
  }

  void _copyPath(String path) {
    Clipboard.setData(ClipboardData(text: path));
    AppToast.showSuccess(context, 'Scope path copied: $path');
  }

  void _toggleCollapse(String nodeId) {
    setState(() {
      if (_collapsedNodeIds.contains(nodeId)) {
        _collapsedNodeIds.remove(nodeId);
      } else {
        _collapsedNodeIds.add(nodeId);
      }
    });
  }

  void _expandAll(List<ScopeTreeNode> nodes) {
    setState(() => _collapsedNodeIds.clear());
  }

  void _collapseAll(List<ScopeTreeNode> nodes) {
    void collectParentIds(List<ScopeTreeNode> list) {
      for (final n in list) {
        if (n.children.isNotEmpty) {
          _collapsedNodeIds.add(n.id);
          collectParentIds(n.children);
        }
      }
    }

    setState(() {
      _collapsedNodeIds.clear();
      collectParentIds(widget.scopes);
    });
  }

  Future<void> _confirmDeleteScope(ScopeTreeNode node) async {
    if (widget.onDeleteScope == null) return;

    if (node.children.isEmpty) {
      widget.onDeleteScope!(node);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Scope Hierarchy?'),
        content: Text(
          "Deleting '${node.name}' (${node.code}) will also delete its ${node.children.length} sub-scope(s).\n\nAre you sure you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Scope and Subtree'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDeleteScope!(node);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final hasSchools = widget.schools.isNotEmpty;
    final isLocked =
        widget.lockedSchoolId != null && widget.lockedSchoolId!.isNotEmpty;
    final selectedSchool = _selectedSchool;

    final canManageScope = widget.canCreateScope &&
        widget.canCreateRootScope &&
        !isLocked &&
        hasSchools;

    final displayScopes = _getDisplayScopes(selectedSchool, _searchCtrl.text);
    final isMobile = MediaQuery.of(context).size.width < 500;

    return KiteCard(
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Hierarchical Scope Tree',
                        style: (isMobile ? t.h4 : t.large)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isLocked) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.warmAmber.withOpacity(0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.lock,
                                  size: 11, color: AppColors.warmAmber),
                              SizedBox(width: 4),
                              Text(
                                'Campus Jailed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warmAmber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isMobile) ...[
                    const SizedBox(height: 2),
                    Text(
                      isLocked
                          ? 'Restricted administration for current campus subtree.'
                          : 'School-anchored authorization boundary and hierarchical RBAC paths.',
                      style: t.muted.copyWith(fontSize: 11),
                    ),
                  ],
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
          SizedBox(height: isMobile ? 8 : 14),

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
            // Case 2: Has schools -> Select school or display locked school
            if (isLocked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warmSand.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.warmAmber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.school,
                        size: 18, color: AppColors.forestSage),
                    const SizedBox(width: 10),
                    const Text(
                      'Assigned Campus:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${selectedSchool?.name ?? widget.lockedSchoolId} (${selectedSchool?.id ?? widget.lockedSchoolId})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(LucideIcons.lock,
                        size: 14, color: AppColors.warmAmber),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 14, vertical: isMobile ? 4 : 8),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.school,
                        size: 18, color: AppColors.forestSage),
                    const SizedBox(width: 8),
                    const Text(
                      'Select School:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSchoolId,
                          isExpanded: true,
                          items: [
                            if (widget.isTenantWideAdmin)
                              const DropdownMenuItem<String>(
                                value: _allSchoolsId,
                                child: Text(
                                  '🌐 All Campuses (Tenant Overview)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ...widget.schools.map((s) {
                              return DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(
                                  '${s.name} (${s.id})',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
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
            SizedBox(height: isMobile ? 6 : 8),

            // Base scope path preview banner
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 8),
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
                      _selectedSchoolId == _allSchoolsId
                          ? 'Base Scope Path: /${widget.tenantId.isNotEmpty ? widget.tenantId : "tenant"}/* (Tenant-wide Overview)'
                          : 'Base Scope Path: /${widget.tenantId.isNotEmpty ? widget.tenantId : "tenant"}/${selectedSchool?.id ?? "school_id"}/',
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
            SizedBox(height: isMobile ? 6 : 10),

            // Search Bar & Expand/Collapse controls
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: isMobile ? 34 : 38,
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search,
                            size: 15, color: c.mutedForeground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const ValueKey('scope_search_field'),
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: t.small.copyWith(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search scopes by name, code, path...',
                              hintStyle: t.muted.copyWith(fontSize: 11.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 14),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Expand All',
                  icon: const Icon(LucideIcons.unfoldVertical, size: 16),
                  onPressed: () => _expandAll(displayScopes),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: 'Collapse All',
                  icon: const Icon(LucideIcons.foldVertical, size: 16),
                  onPressed: () => _collapseAll(displayScopes),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Scopes list
            Expanded(
              child: displayScopes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.folderX,
                              size: 32, color: c.mutedForeground),
                          const SizedBox(height: 8),
                          Text(
                            _searchCtrl.text.isNotEmpty
                                ? 'No scopes found matching "${_searchCtrl.text}"'
                                : 'No scopes configured for this context.',
                            style: t.muted.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: displayScopes
                          .map((s) => _buildScopeNodeWidget(context, s,
                              widget.canCreateScope, selectedSchool))
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
    final nodeType = _resolveNodeType(node);
    final isRootOrAnchor = nodeType == ScopeNodeType.tenantRoot ||
        nodeType == ScopeNodeType.campusAnchor;
    final hasChildren = node.children.isNotEmpty;
    final isCollapsed = _collapsedNodeIds.contains(node.id);

    // Determine badge and icon based on scope classification
    final IconData icon;
    final Color iconColor;
    final String badgeLabel;
    final Color badgeBg;
    final Color badgeFg;

    switch (nodeType) {
      case ScopeNodeType.tenantRoot:
        icon = LucideIcons.shieldCheck;
        iconColor = const Color(0xFF7C3AED);
        badgeLabel = 'TENANT ROOT';
        badgeBg = const Color(0xFFEDE9FE);
        badgeFg = const Color(0xFF5B21B6);
        break;
      case ScopeNodeType.campusAnchor:
        icon = LucideIcons.school;
        iconColor = AppColors.forestSage;
        badgeLabel = 'CAMPUS ANCHOR';
        badgeBg = const Color(0xFFD1FAE5);
        badgeFg = const Color(0xFF065F46);
        break;
      case ScopeNodeType.childScope:
        icon = LucideIcons.folderTree;
        iconColor = c.foreground;
        badgeLabel = 'L${node.depth}';
        badgeBg = c.muted.withOpacity(0.4);
        badgeFg = c.mutedForeground;
        break;
    }

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
              color: nodeType == ScopeNodeType.tenantRoot
                  ? const Color(0xFFF5F3FF)
                  : (nodeType == ScopeNodeType.campusAnchor
                      ? const Color(0xFFF0FDF4)
                      : c.card),
              borderRadius: KiteRadius.allMd,
              border: Border.all(
                color: nodeType == ScopeNodeType.tenantRoot
                    ? const Color(0xFFDDD6FE)
                    : (nodeType == ScopeNodeType.campusAnchor
                        ? const Color(0xFFA7F3D0)
                        : c.border),
              ),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    key: ValueKey('toggle_collapse_${node.id}'),
                    onTap: () => _toggleCollapse(node.id),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        isCollapsed
                            ? LucideIcons.chevronRight
                            : LucideIcons.chevronDown,
                        size: 16,
                        color: c.mutedForeground,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 4),
                Icon(icon, size: 16, color: iconColor),
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
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeFg,
                              ),
                            ),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
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
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            key: ValueKey('copy_scope_path_${node.id}'),
                            icon: const Icon(LucideIcons.copy, size: 11),
                            tooltip: 'Copy path',
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              minimumSize: const Size(18, 18),
                            ),
                            onPressed: () => _copyPath(node.path),
                          ),
                        ],
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
                if (widget.canEditScope && widget.onEditScope != null) ...[
                  IconButton(
                    key: ValueKey('edit_scope_${node.id}'),
                    icon: const Icon(LucideIcons.pencil, size: 13),
                    tooltip: 'Edit Scope',
                    style: IconButton.styleFrom(
                      foregroundColor: c.foreground,
                      padding: const EdgeInsets.all(2),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(22, 22),
                    ),
                    onPressed: () => widget.onEditScope?.call(node, school),
                  ),
                ],
                if (widget.canDeleteScope && widget.onDeleteScope != null) ...[
                  if (isRootOrAnchor)
                    Tooltip(
                      message:
                          'Root and campus anchor scopes cannot be deleted',
                      child: IconButton(
                        key: ValueKey('delete_scope_${node.id}'),
                        icon: const Icon(LucideIcons.trash2, size: 13),
                        style: IconButton.styleFrom(
                          foregroundColor: c.mutedForeground.withOpacity(0.5),
                          padding: const EdgeInsets.all(2),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(22, 22),
                        ),
                        onPressed: null,
                      ),
                    )
                  else
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
                      onPressed: () => _confirmDeleteScope(node),
                    ),
                ],
              ],
            ),
          ),
          if (hasChildren && !isCollapsed)
            ...node.children.map((child) =>
                _buildScopeNodeWidget(context, child, canCreate, school)),
        ],
      ),
    );
  }
}
