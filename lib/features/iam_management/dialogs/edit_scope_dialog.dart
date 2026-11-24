import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class FlattenedScopeCandidate {
  final String id;
  final String code;
  final String name;
  final String path;
  final int depth;

  const FlattenedScopeCandidate({
    required this.id,
    required this.code,
    required this.name,
    required this.path,
    required this.depth,
  });
}

class EditScopeDialog extends StatefulWidget {
  final ScopeTreeNode scope;
  final List<ScopeTreeNode> allScopes;
  final SchoolResponse? school;
  final String? tenantId;
  final Future<void> Function() onScopeUpdated;

  const EditScopeDialog({
    super.key,
    required this.scope,
    this.allScopes = const [],
    this.school,
    this.tenantId,
    required this.onScopeUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required ScopeTreeNode scope,
    List<ScopeTreeNode> allScopes = const [],
    SchoolResponse? school,
    String? tenantId,
    required Future<void> Function() onScopeUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditScopeDialog(
        scope: scope,
        allScopes: allScopes,
        school: school,
        tenantId: tenantId,
        onScopeUpdated: onScopeUpdated,
      ),
    );
  }

  @override
  State<EditScopeDialog> createState() => _EditScopeDialogState();
}

class _EditScopeDialogState extends State<EditScopeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  String? _selectedParentId;
  late final List<FlattenedScopeCandidate> _candidateParents;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.scope.code);
    _nameCtrl = TextEditingController(text: widget.scope.name);
    _selectedParentId = widget.scope.parentId;
    _candidateParents = _collectEligibleParents(widget.allScopes);
    _codeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Collect candidate parent nodes, filtering out self and descendants to prevent cycles.
  List<FlattenedScopeCandidate> _collectEligibleParents(
      List<ScopeTreeNode> roots) {
    final result = <FlattenedScopeCandidate>[];
    final targetPath = widget.scope.path.trim();

    void traverse(ScopeTreeNode node) {
      bool isSelfOrDescendant = node.id == widget.scope.id;
      if (!isSelfOrDescendant && targetPath.isNotEmpty && targetPath != '/') {
        final normalizedTarget =
            targetPath.endsWith('/') ? targetPath : '$targetPath/';
        final nodeNorm = node.path.endsWith('/') ? node.path : '${node.path}/';
        isSelfOrDescendant =
            node.path == targetPath || nodeNorm.startsWith(normalizedTarget);
      }

      if (!isSelfOrDescendant) {
        result.add(FlattenedScopeCandidate(
          id: node.id,
          code: node.code,
          name: node.name,
          path: node.path,
          depth: node.depth,
        ));
      }

      for (final child in node.children) {
        traverse(child);
      }
    }

    for (final root in roots) {
      traverse(root);
    }
    return result;
  }

  String _computePreviewPath() {
    final cleanCode = _codeCtrl.text.trim().toUpperCase();
    final parentId = _selectedParentId;

    if (parentId != null && parentId.isNotEmpty && parentId != '__ROOT__') {
      final parent =
          _candidateParents.where((p) => p.id == parentId).firstOrNull;
      if (parent != null) {
        final parentBase = parent.path.endsWith('/')
            ? parent.path.substring(0, parent.path.length - 1)
            : parent.path;
        return cleanCode.isEmpty
            ? '$parentBase/<SCOPE_CODE>'
            : '$parentBase/$cleanCode';
      }
    }

    final currentPath = widget.scope.path;
    final lastSlash = currentPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return cleanCode.isEmpty ? currentPath : '/$cleanCode';
    }
    final basePath = currentPath.substring(0, lastSlash);
    if (cleanCode.isEmpty) {
      return '$basePath/<SCOPE_CODE>';
    }
    return '$basePath/$cleanCode';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedName = _nameCtrl.text.trim();
    final updatedCode = _codeCtrl.text.trim().toUpperCase();
    final isCodeOrNameChanged =
        updatedCode != widget.scope.code || updatedName != widget.scope.name;
    final isParentChanged = _selectedParentId != null &&
        _selectedParentId != widget.scope.parentId &&
        _selectedParentId != '__ROOT__' &&
        _selectedParentId!.isNotEmpty;

    try {
      // 1. Move scope if parent changed
      if (isParentChanged) {
        await iamService.moveScope(
          widget.scope.id,
          MoveScopeRequest(newParentId: _selectedParentId!),
          tenantId: widget.tenantId,
        );
      }

      // 2. Update code and name if changed
      if (isCodeOrNameChanged) {
        await iamService.updateScope(
          widget.scope.id,
          UpdateScopeRequest(
            code: updatedCode,
            name: updatedName,
          ),
          tenantId: widget.tenantId,
        );
      }

      if (mounted) {
        AppToast.showSuccess(
            context, "Scope '$updatedName' saved successfully");
        Navigator.of(context).pop();
        await widget.onScopeUpdated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to update scope: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewPath = _computePreviewPath();
    final hasMatchingParent =
        _candidateParents.any((c) => c.id == _selectedParentId);
    final dropdownValue = hasMatchingParent ? _selectedParentId : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.forestSage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.pencil,
              color: AppColors.forestSage,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit & Reparent Scope',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${widget.scope.id}',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Path Preview Banner
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warmSand.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.forestSage.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.gitBranch,
                              size: 13, color: AppColors.forestSage),
                          SizedBox(width: 6),
                          Text(
                            'Hierarchical Scope Path (Resolved):',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        previewPath,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Move / Parent Scope Selector
                if (_candidateParents.isNotEmpty) ...[
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Parent Scope (Move Path)',
                      prefixIcon: const Icon(LucideIcons.folderTree, size: 16),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const ValueKey('edit_scope_parent_dropdown'),
                        value: dropdownValue,
                        isExpanded: true,
                        isDense: true,
                        hint: Text(widget.scope.parentId != null
                            ? 'Select new parent to move under...'
                            : 'Select parent scope to move under...'),
                        items: [
                          if (widget.scope.parentId != null)
                            DropdownMenuItem<String>(
                              value: widget.scope.parentId,
                              child: Text(
                                '📍 Keep current parent (${_candidateParents.where((c) => c.id == widget.scope.parentId).firstOrNull?.name ?? "Current"})',
                                style: const TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ..._candidateParents
                              .where((c) => c.id != widget.scope.parentId)
                              .map((candidate) {
                            final indent = '  ' * candidate.depth;
                            return DropdownMenuItem<String>(
                              value: candidate.id,
                              child: Text(
                                '$indent📁 ${candidate.name} (${candidate.code})',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedParentId = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warmSand.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warmAmber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.info,
                            size: 14, color: AppColors.warmAmber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No eligible parent scopes available to move under in current scope boundary.',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                TextFormField(
                  key: const ValueKey('edit_scope_code_field'),
                  controller: _codeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Scope Code',
                    prefixIcon: const Icon(LucideIcons.code, size: 16),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Scope code is required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  key: const ValueKey('edit_scope_name_field'),
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Scope Name',
                    prefixIcon: const Icon(LucideIcons.tag, size: 16),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Scope name is required'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const ValueKey('edit_scope_submit_btn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
