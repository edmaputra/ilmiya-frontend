import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import 'tenant_metric_pill.dart';
import 'tenant_school_card.dart';

class TenantDirectoryTab extends StatelessWidget {
  final List<SchoolResponse> allSchools;
  final List<SchoolResponse> filteredSchools;
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

  const TenantDirectoryTab({
    super.key,
    required this.allSchools,
    required this.filteredSchools,
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

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metric Summary Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TenantMetricPill(
                label: 'TOTAL TENANTS',
                value: '$totalCount',
                icon: LucideIcons.building2,
              ),
              TenantMetricPill(
                label: 'ACTIVE SCHOOLS',
                value: '$activeCount',
                icon: LucideIcons.checkCircle2,
                color: AppColors.forestSage,
              ),
              TenantMetricPill(
                label: 'PENDING ONBOARDING',
                value: '$pendingCount',
                icon: LucideIcons.clock,
                color: Colors.amber.shade700,
              ),
              TenantMetricPill(
                label: 'SUSPENDED',
                value: '$suspendedCount',
                icon: LucideIcons.ban,
                color: AppColors.earthyTerra,
              ),
            ],
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
                  Wrap(
                    spacing: 6,
                    children:
                        ['ALL', 'ACTIVE', 'PENDING', 'SUSPENDED'].map((st) {
                      final isSel = selectedStatusFilter == st;
                      return ChoiceChip(
                        label: Text(st, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        selectedColor: AppColors.warmSand,
                        onSelected: (val) {
                          if (val) onStatusFilterChanged(st);
                        },
                      );
                    }).toList(),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestSage,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: onRegisterTenant,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Register School'),
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

          const SizedBox(height: 14),

          // Schools List
          Expanded(
            child: filteredSchools.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.building,
                            size: 40, color: c.mutedForeground),
                        const SizedBox(height: 8),
                        Text('No school tenants matched the criteria.',
                            style: t.p),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredSchools.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final s = filteredSchools[idx];
                      return TenantSchoolCard(
                        school: s,
                        isCurrentTenant: s.tenantId == currentTenantId,
                        onSwitchTenant: onSwitchTenant,
                        onEditProfile: onEditProfile,
                        onSettings: onSettings,
                        onToggleStatus: onToggleStatus,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
