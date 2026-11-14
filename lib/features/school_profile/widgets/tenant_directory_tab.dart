import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import 'tenant_metric_pill.dart';
import 'tenant_school_card.dart';

class TenantDirectoryTab extends StatelessWidget {
  final List<SchoolResponse> allSchools;
  final List<SchoolResponse> filteredSchools;
  final List<TenantResponse>? allTenants;
  final String searchQuery;
  final String selectedStatusFilter;
  final String currentTenantId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onRegisterTenant;
  final ValueChanged<String> onSwitchTenant;
  final ValueChanged<SchoolResponse> onEditProfile;
  final ValueChanged<SchoolResponse> onSettings;
  final ValueChanged<SchoolResponse> onToggleStatus;
  final ValueChanged<String>? onAddCampus;

  const TenantDirectoryTab({
    super.key,
    required this.allSchools,
    required this.filteredSchools,
    this.allTenants,
    required this.searchQuery,
    required this.selectedStatusFilter,
    required this.currentTenantId,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onRegisterTenant,
    required this.onSwitchTenant,
    required this.onEditProfile,
    required this.onSettings,
    required this.onToggleStatus,
    this.onAddCampus,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final totalCount = allSchools.length;
    final activeCount = allSchools.where((s) => s.status == 'ACTIVE').length;
    final pendingCount = allSchools.where((s) => s.status == 'PENDING').length;
    final suspendedCount =
        allSchools.where((s) => s.status == 'SUSPENDED').length;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardPadding = screenWidth < 600 ? 12.0 : 16.0;

    return KiteCard(
      padding: EdgeInsets.all(cardPadding),
      child: ListView(
        children: [
          // Metric Summary Row
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final pill1 = TenantMetricPill(
                label: 'TOTAL TENANTS',
                value: '$totalCount',
                icon: LucideIcons.building2,
              );
              final pill2 = TenantMetricPill(
                label: 'ACTIVE SCHOOLS',
                value: '$activeCount',
                icon: LucideIcons.checkCircle2,
                color: AppColors.forestSage,
              );
              final pill3 = TenantMetricPill(
                label: 'PENDING ONBOARDING',
                value: '$pendingCount',
                icon: LucideIcons.clock,
                color: Colors.amber.shade700,
              );
              final pill4 = TenantMetricPill(
                label: 'SUSPENDED',
                value: '$suspendedCount',
                icon: LucideIcons.ban,
                color: AppColors.earthyTerra,
              );

              if (w >= 760) {
                return Row(
                  children: [
                    Expanded(child: pill1),
                    const SizedBox(width: 12),
                    Expanded(child: pill2),
                    const SizedBox(width: 12),
                    Expanded(child: pill3),
                    const SizedBox(width: 12),
                    Expanded(child: pill4),
                  ],
                );
              } else if (w >= 400) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: pill1),
                        const SizedBox(width: 12),
                        Expanded(child: pill2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: pill3),
                        const SizedBox(width: 12),
                        Expanded(child: pill4),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    pill1,
                    const SizedBox(height: 8),
                    pill2,
                    const SizedBox(height: 8),
                    pill3,
                    const SizedBox(height: 8),
                    pill4,
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 16),

          // Search and Filters Bar
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final searchField = TextField(
                decoration: InputDecoration(
                  hintText:
                      'Search by school name, tenant ID, code, or NPSN...',
                  prefixIcon: Icon(LucideIcons.search,
                      size: 16, color: c.mutedForeground),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: KiteRadius.allMd,
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
                onChanged: onSearchChanged,
              );

              final filtersAndAction = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Status filter chips
                  ...['ALL', 'ACTIVE', 'PENDING', 'SUSPENDED'].map((st) {
                    final isSel = selectedStatusFilter == st;
                    return ChoiceChip(
                      label: Text(st, style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      selectedColor: AppColors.warmSand,
                      onSelected: (val) {
                        if (val) onStatusFilterChanged(st);
                      },
                    );
                  }),

                  // Register School action
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestSage,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: onRegisterTenant,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text(
                      'Register School',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    filtersAndAction,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  filtersAndAction,
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Tenants List
          if (filteredSchools.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(LucideIcons.building,
                        size: 40, color: c.mutedForeground),
                    const SizedBox(height: 8),
                    Text('No school tenants matched the criteria.', style: t.p),
                  ],
                ),
              ),
            )
          else
            ...filteredSchools.map((s) {
              TenantResponse? parent;
              if (allTenants != null) {
                try {
                  parent = allTenants!.firstWhere((t) => t.id == s.tenantId);
                } catch (_) {}
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TenantSchoolCard(
                  school: s,
                  parentTenant: parent,
                  isCurrentTenant: s.tenantId == currentTenantId,
                  onSwitchTenant: onSwitchTenant,
                  onEditProfile: onEditProfile,
                  onSettings: onSettings,
                  onToggleStatus: onToggleStatus,
                  onAddCampus: onAddCampus,
                ),
              );
            }),
        ],
      ),
    );
  }
}
