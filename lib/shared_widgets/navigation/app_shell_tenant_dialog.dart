import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/tenant.dart';
import '../../core/services/school_service.dart';
import '../../core/services/tenant_service.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';

class AppShellTenantDialog extends StatefulWidget {
  final AuthNotifier auth;
  final TenantService? tenantService;
  final SchoolService? schoolService;
  final String title;

  const AppShellTenantDialog({
    super.key,
    required this.auth,
    this.tenantService,
    this.schoolService,
    this.title = 'Switch Tenant',
  });

  static Future<void> show(
    BuildContext context,
    AuthNotifier auth, {
    TenantService? tenantService,
    SchoolService? schoolService,
    String title = 'Switch Tenant',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppShellTenantDialog(
        auth: auth,
        tenantService: tenantService,
        schoolService: schoolService,
        title: title,
      ),
    );
  }

  @override
  State<AppShellTenantDialog> createState() => _AppShellTenantDialogState();
}

class _AppShellTenantDialogState extends State<AppShellTenantDialog> {
  late final TenantService _tenantService;
  late final TextEditingController _searchCtrl;
  late final TextEditingController _customTenantCtrl;
  late final ExpansionTileController _expansionController;

  List<TenantResponse> _allTenants = [];
  List<TenantResponse> _filteredTenants = [];
  bool _isLoading = true;
  bool _isSwitching = false;
  String _selectedTenantId = '';

  @override
  void initState() {
    super.initState();
    _tenantService = widget.tenantService ?? TenantService();
    _selectedTenantId = widget.auth.tenantId;
    _searchCtrl = TextEditingController();
    _customTenantCtrl = TextEditingController(text: widget.auth.tenantId);
    _expansionController = ExpansionTileController();
    _loadTenants();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customTenantCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    setState(() => _isLoading = true);
    try {
      final list = await _tenantService.listTenants();
      if (mounted) {
        setState(() {
          _allTenants = list;
          _applyFilter(_searchCtrl.text);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        // Fallback default mock tenants if service call fails
        _allTenants = [
          TenantResponse(
            id: 'tenant-lincoln-high-001',
            name: 'Yayasan Pendidikan Lincoln Ilmiya',
            legalEntityNumber: 'AHU-0012345.AH.01.04.2020',
            registrationType: 'FOUNDATION',
            address: '1240 Oakcrest Ave, Portland, OR 97201',
            contactEmail: 'foundation@lincolnhigh.edu',
            contactPhone: '+1 503 555 0192',
            status: 'ACTIVE',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
          TenantResponse(
            id: 'tenant-sma1-ilmiya-002',
            name: 'Yayasan Pembina Generasi Ilmiya',
            legalEntityNumber: 'AHU-0098765.AH.01.04.2021',
            registrationType: 'FOUNDATION',
            address: 'Jl. Pendidikan No. 42, Kebayoran Baru, Jakarta Selatan',
            contactEmail: 'sekretariat@ilmiya-foundation.id',
            contactPhone: '+62 21 7890 1234',
            status: 'ACTIVE',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
          TenantResponse(
            id: 'tenant-alazhar-003',
            name: 'Yayasan Pesantren Islam Al-Azhar',
            legalEntityNumber: 'AHU-0034567.AH.01.04.2018',
            registrationType: 'FOUNDATION',
            address:
                'Jl. Sisingamangaraja No. 1, Kebayoran Baru, Jakarta Selatan',
            contactEmail: 'info@alazhar-foundation.sch.id',
            contactPhone: '+62 21 7278 8900',
            status: 'ACTIVE',
            createdAt: '2026-02-10T00:00:00Z',
            updatedAt: '2026-02-10T00:00:00Z',
          ),
          TenantResponse(
            id: 'tenant-horizon-004',
            name: 'Horizon STEM Education Trust',
            legalEntityNumber: 'WA-CORP-98721',
            registrationType: 'NON_PROFIT_ORGANIZATION',
            address: '770 Innovation Blvd, Silicon Forest, WA 98052',
            contactEmail: 'contact@horizon-trust.org',
            contactPhone: '+1 206 555 0148',
            status: 'PENDING',
            createdAt: '2026-03-01T00:00:00Z',
            updatedAt: '2026-03-01T00:00:00Z',
          ),
          TenantResponse(
            id: 'tenant-stjude-005',
            name: 'St. Jude Educational Association',
            legalEntityNumber: 'MA-NONPROFIT-4412',
            registrationType: 'RELIGIOUS_BODY',
            address: '500 Cathedral St, Boston, MA 02118',
            contactEmail: 'office@stjude-edu.org',
            contactPhone: '+1 617 555 0184',
            status: 'SUSPENDED',
            createdAt: '2026-01-15T00:00:00Z',
            updatedAt: '2026-01-15T00:00:00Z',
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
      _filteredTenants = List.from(_allTenants);
    } else {
      _filteredTenants = _allTenants.where((t) {
        final matchesName = t.name.toLowerCase().contains(q);
        final matchesTenant = t.id.toLowerCase().contains(q) ||
            t.tenantId.toLowerCase().contains(q);
        final matchesLegal =
            t.legalEntityNumber?.toLowerCase().contains(q) ?? false;
        final matchesRegistration =
            t.registrationType?.toLowerCase().contains(q) ?? false;
        final matchesAddress = t.address.toLowerCase().contains(q);
        final matchesEmail = t.contactEmail.toLowerCase().contains(q);
        return matchesName ||
            matchesTenant ||
            matchesLegal ||
            matchesRegistration ||
            matchesAddress ||
            matchesEmail;
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
        if (widget.auth.isPlatformSession) {
          try {
            Provider.of<AppState>(context, listen: false).setTab(8);
          } catch (_) {}
        }
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
                  widget.auth.isPlatformSession
                      ? 'Platform Operations (Global Console)'
                      : 'Tenant: ${widget.auth.tenantName} (${widget.auth.tenantId})',
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
        height: 540,
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
                hintText: 'Search tenant name, ID, or legal entity...',
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

            if (widget.auth.isSuperAdmin) ...[
              InkWell(
                key: const Key('platform_operations_tenant_tile'),
                onTap: () {
                  setState(() {
                    _selectedTenantId = 'platform';
                    _customTenantCtrl.text = 'platform';
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTenantId == 'platform'
                        ? AppColors.forestSage.withOpacity(isDark ? 0.2 : 0.08)
                        : surfaceBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedTenantId == 'platform'
                          ? AppColors.forestSage
                          : borderColor,
                      width: _selectedTenantId == 'platform' ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedTenantId == 'platform'
                              ? AppColors.forestSage.withOpacity(0.18)
                              : (isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          LucideIcons.globe,
                          size: 18,
                          color: _selectedTenantId == 'platform'
                              ? AppColors.forestSage
                              : secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform Operations (Global Console)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              'Root superadmin platform session • Manage all tenants',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.auth.isPlatformSession)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.forestSage.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Tenant List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.forestSage,
                      ),
                    )
                  : _filteredTenants.isEmpty
                      ? _buildEmptyState(
                          secondaryTextColor,
                          borderColor,
                          surfaceBg,
                        )
                      : ListView.separated(
                          itemCount: _filteredTenants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tenant = _filteredTenants[index];
                            final isSelected = _selectedTenantId == tenant.id;
                            final isCurrent = widget.auth.tenantId == tenant.id;

                            return InkWell(
                              key: ValueKey('tenant_tile_${tenant.id}'),
                              onTap: () {
                                setState(() {
                                  _selectedTenantId = tenant.id;
                                  _customTenantCtrl.text = tenant.id;
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
                                        LucideIcons.building,
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
                                                  tenant.name,
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
                                                  tenant.id,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'monospace',
                                                    color: secondaryTextColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (tenant.legalEntityNumber !=
                                                      null &&
                                                  tenant.legalEntityNumber!
                                                      .isNotEmpty) ...[
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    tenant.legalEntityNumber!,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: secondaryTextColor,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ] else if (tenant
                                                          .registrationType !=
                                                      null &&
                                                  tenant.registrationType!
                                                      .isNotEmpty) ...[
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                                Text(
                                                  tenant.registrationType!,
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
              'No tenants match "$query"',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with a different tenant name, legal entity, or tenant ID.',
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
