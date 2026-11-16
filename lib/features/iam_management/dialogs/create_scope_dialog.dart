import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class CreateScopeDialog extends StatefulWidget {
  final String? parentId;
  final ScopeTreeNode? parentNode;
  final SchoolResponse? school;
  final String? tenantId;
  final Future<void> Function() onScopeCreated;

  const CreateScopeDialog({
    super.key,
    this.parentId,
    this.parentNode,
    this.school,
    this.tenantId,
    required this.onScopeCreated,
  });

  static Future<void> show(
    BuildContext context, {
    String? parentId,
    ScopeTreeNode? parentNode,
    SchoolResponse? school,
    String? tenantId,
    required Future<void> Function() onScopeCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateScopeDialog(
        parentId: parentId,
        parentNode: parentNode,
        school: school,
        tenantId: tenantId,
        onScopeCreated: onScopeCreated,
      ),
    );
  }

  @override
  State<CreateScopeDialog> createState() => _CreateScopeDialogState();
}

class _CreateScopeDialogState extends State<CreateScopeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.parentId == null && widget.school != null) {
      _codeCtrl.text = widget.school!.institutionCode.isNotEmpty
          ? widget.school!.institutionCode.toUpperCase()
          : 'ROOT';
      _nameCtrl.text = '${widget.school!.name} Root Scope';
    }
    _codeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String _getEffectiveTenantId() {
    if (widget.tenantId != null && widget.tenantId!.isNotEmpty) {
      return widget.tenantId!;
    }
    return apiClient.tenantId.isNotEmpty ? apiClient.tenantId : 'tenant';
  }

  String _computePreviewPath() {
    final tId = _getEffectiveTenantId();
    final cleanCode = _codeCtrl.text.trim().toUpperCase();

    if (widget.parentId == null) {
      final sId = widget.school?.id ?? 'school_id';
      if (cleanCode.isEmpty || cleanCode == 'ROOT' || cleanCode == sId) {
        return '/$tId/$sId';
      }
      return '/$tId/$sId/$cleanCode';
    }

    final parentPath = widget.parentNode?.path ?? '';
    final base = parentPath.endsWith('/')
        ? parentPath.substring(0, parentPath.length - 1)
        : parentPath;
    if (cleanCode.isEmpty) return '$base/<SCOPE_CODE>';
    return '$base/$cleanCode';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final scopeName = _nameCtrl.text.trim();
    final effectiveTenantId = _getEffectiveTenantId();
    try {
      await iamService.createScope(CreateScopeRequest(
        tenantId: effectiveTenantId,
        code: _codeCtrl.text.trim().toUpperCase(),
        name: scopeName,
        parentId: widget.parentId,
      ));

      if (mounted) {
        AppToast.showSuccess(
            context, "Scope '$scopeName' created successfully");
        Navigator.of(context).pop();
        await widget.onScopeCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to create scope: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRoot = widget.parentId == null;
    final previewPath = _computePreviewPath();

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
            child: Icon(
              isRoot ? LucideIcons.landmark : LucideIcons.network,
              color: AppColors.forestSage,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRoot ? 'Create Root Scope' : 'Add Custom Scope',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.school != null)
                  Text(
                    'School: ${widget.school!.name}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Form(
          key: _formKey,
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
                  border:
                      Border.all(color: AppColors.forestSage.withOpacity(0.2)),
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
                          'Hierarchical Scope Path (Standard):',
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

              TextFormField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  labelText: isRoot
                      ? 'Scope Code (e.g. ROOT or CAMPUS_MAIN)'
                      : 'Scope Code (e.g. DEPT_SCIENCE, CLASS_10A)',
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
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: isRoot
                      ? 'Scope Name (e.g. Main Campus Root)'
                      : 'Scope Name (e.g. Science Department)',
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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
              : const Text('Save Scope'),
        ),
      ],
    );
  }
}
