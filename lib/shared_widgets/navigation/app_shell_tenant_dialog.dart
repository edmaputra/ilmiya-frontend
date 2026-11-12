import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/school.dart';
import '../../core/services/school_service.dart';
import '../../state/auth_notifier.dart';

class AppShellTenantDialog extends StatefulWidget {
  final AuthNotifier auth;
  final SchoolService? schoolService;
  final String title;

  const AppShellTenantDialog({
    super.key,
    required this.auth,
    this.schoolService,
    this.title = 'Switch School Tenant',
  });

  static Future<void> show(
    BuildContext context,
    AuthNotifier auth, {
    SchoolService? schoolService,
    String title = 'Switch School Tenant',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppShellTenantDialog(
        auth: auth,
        schoolService: schoolService,
        title: title,
      ),
    );
  }

  @override
  State<AppShellTenantDialog> createState() => _AppShellTenantDialogState();
}

class _AppShellTenantDialogState extends State<AppShellTenantDialog> {
  late final SchoolService _schoolService;
  late final TextEditingController _searchCtrl;
  late final TextEditingController _customTenantCtrl;
  late final ExpansionTileController _expansionController;

  List<SchoolResponse> _allSchools = [];
  List<SchoolResponse> _filteredSchools = [];
  bool _isLoading = true;
  bool _isSwitching = false;
  String _selectedTenantId = '';

  @override
  void initState() {
    super.initState();
    _schoolService = widget.schoolService ?? SchoolService();
    _selectedTenantId = widget.auth.tenantId;
    _searchCtrl = TextEditingController();
    _customTenantCtrl = TextEditingController(text: widget.auth.tenantId);
    _expansionController = ExpansionTileController();
    _loadSchools();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customTenantCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final list = await _schoolService.listSchools();
      if (mounted) {
        setState(() {
          _allSchools = list;
          _applyFilter(_searchCtrl.text);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        // Fallback default mock schools if service call fails
        _allSchools = [
          SchoolResponse(
            id: 'sch-001',
            tenantId: 'tenant-lincoln-high-001',
            name: 'SMA Negeri 1 Ilmiya (Lincoln High Campus)',
            institutionCode: 'SMAN1-ILM',
            address: '1240 Oakcrest Ave, Portland, OR 97201',
            contactEmail: 'office@lincolnhigh.edu',
            contactPhone: '+1 503 555 0192',
            status: 'ACTIVE',
            workingDays: [
              'MONDAY',
              'TUESDAY',
              'WEDNESDAY',
              'THURSDAY',
              'FRIDAY'
            ],
            gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
            termLayout: 'SEMESTER',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
          SchoolResponse(
            id: 'sch-002',
            tenantId: 'tenant-sma1-ilmiya-002',
            name: 'SMA Negeri 1 Ilmiya',
            institutionCode: 'SMAN1-ILM',
            address: 'Jl. Pendidikan No. 42, Jakarta Selatan',
            contactEmail: 'admin@ilmiya-school.edu',
            contactPhone: '+62 21 7890 1234',
            status: 'ACTIVE',
            workingDays: [
              'MONDAY',
              'TUESDAY',
              'WEDNESDAY',
              'THURSDAY',
              'FRIDAY'
            ],
            gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
            termLayout: 'SEMESTER',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
        ];
        _applyFilter(_searchCtrl.text);
        _isLoading = false;
      }
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredSchools = List.from(_allSchools);
    } else {
      _filteredSchools = _allSchools.where((s) {
        final matchesName = s.name.toLowerCase().contains(q);
        final matchesTenant = s.tenantId.toLowerCase().contains(q);
        final matchesCode = s.institutionCode.toLowerCase().contains(q);
        final matchesAddress = s.address.toLowerCase().contains(q);
        return matchesName || matchesTenant || matchesCode || matchesAddress;
      }).toList();
    }
  }

  Future<void> _handleSwitch(String targetTenantId) async {
    final tenant = targetTenantId.trim();
    if (tenant.isEmpty) return;

    setState(() => _isSwitching = true);
    try {
      await widget.auth.switchTenant(tenant);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched tenant to $tenant')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSwitching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching tenant: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final surfaceBg =
        isDark ? AppColors.darkSurface : AppColors.naturalParchment;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textMuted : AppColors.textSecondary;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.forestSage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.building,
              color: AppColors.forestSage,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Search school name or enter tenant partition ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            color: secondaryTextColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              key: const Key('tenant_search_field'),
              controller: _searchCtrl,
              onChanged: (val) {
                setState(() => _applyFilter(val));
              },
              style: TextStyle(fontSize: 13, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: 'Search school name, code, or tenant ID...',
                hintStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 16,
                  color: secondaryTextColor,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 14),
                        color: secondaryTextColor,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _applyFilter(''));
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: surfaceBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.forestSage, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // School List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.forestSage,
                      ),
                    )
                  : _filteredSchools.isEmpty
                      ? _buildEmptyState(
                          secondaryTextColor,
                          borderColor,
                          surfaceBg,
                        )
                      : ListView.separated(
                          itemCount: _filteredSchools.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final school = _filteredSchools[index];
                            final isSelected =
                                _selectedTenantId == school.tenantId;
                            final isCurrent =
                                widget.auth.tenantId == school.tenantId;

                            return InkWell(
                              key: ValueKey('tenant_tile_${school.tenantId}'),
                              onTap: () {
                                setState(() {
                                  _selectedTenantId = school.tenantId;
                                  _customTenantCtrl.text = school.tenantId;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.forestSage
                                          .withOpacity(isDark ? 0.2 : 0.08)
                                      : surfaceBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.forestSage
                                        : borderColor,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isSelected
                                            ? AppColors.forestSage
                                                .withOpacity(0.18)
                                            : (isDark
                                                ? Colors.white12
                                                : const Color(0xFFE2E8F0)),
                                      ),
                                      child: Icon(
                                        LucideIcons.school,
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.forestSage
                                            : secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  school.name,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: primaryTextColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isCurrent) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFE6F4EA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFA8DAB5),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        LucideIcons.check,
                                                        size: 10,
                                                        color:
                                                            Color(0xFF137333),
                                                      ),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        'CURRENT',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Color(0xFF137333),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  school.tenantId,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'monospace',
                                                    color: secondaryTextColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (school.institutionCode
                                                  .isNotEmpty) ...[
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                                Text(
                                                  school.institutionCode,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 18,
                                      color: isSelected
                                          ? AppColors.forestSage
                                          : secondaryTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Collapsible Custom Tenant ID Section
            const SizedBox(height: 8),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('custom_tenant_tile'),
                controller: _expansionController,
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  'Manual Tenant ID Entry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                children: [
                  TextField(
                    key: const Key('custom_tenant_field'),
                    controller: _customTenantCtrl,
                    onChanged: (val) {
                      setState(() => _selectedTenantId = val.trim());
                    },
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Custom Tenant ID',
                      labelStyle:
                          TextStyle(fontSize: 12, color: secondaryTextColor),
                      prefixIcon: Icon(
                        LucideIcons.terminal,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSwitching ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          key: const Key('switch_tenant_btn'),
          onPressed: (_selectedTenantId.isEmpty || _isSwitching)
              ? null
              : () => _handleSwitch(_selectedTenantId),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forestSage,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSwitching
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Switch Tenant',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    Color secondaryTextColor,
    Color borderColor,
    Color surfaceBg,
  ) {
    final query = _searchCtrl.text.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 36, color: secondaryTextColor),
            const SizedBox(height: 8),
            Text(
              'No schools match "$query"',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with a different name, institution code, or tenant ID.',
              style: TextStyle(fontSize: 11, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(LucideIcons.arrowRight, size: 14),
                label: Text('Use "$query" as Tenant ID',
                    style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestSage,
                  side: const BorderSide(color: AppColors.forestSage),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedTenantId = query;
                    _customTenantCtrl.text = query;
                  });
                  if (!_expansionController.isExpanded) {
                    _expansionController.expand();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
