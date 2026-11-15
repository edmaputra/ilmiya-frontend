import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import 'foundation_card.dart';
import 'tenant_metric_pill.dart';

class FoundationsDirectoryTab extends StatelessWidget {
  final List<TenantResponse> allTenants;
  final List<SchoolResponse> allSchools;
  final String searchQuery;
  final String selectedStatusFilter;
  final String currentTenantId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onRegisterFoundation;
  final ValueChanged<String> onSwitchTenant;
  final ValueChanged<TenantResponse> onEditFoundation;
  final ValueChanged<TenantResponse> onToggleStatus;
  final ValueChanged<String> onAddCampus;

  const FoundationsDirectoryTab({
    super.key,
    required this.allTenants,
    required this.allSchools,
    required this.searchQuery,
    required this.selectedStatusFilter,
    required this.currentTenantId,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onRegisterFoundation,
    required this.onSwitchTenant,
    required this.onEditFoundation,
    required this.onToggleStatus,
    required this.onAddCampus,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final totalFoundations = allTenants.length;
    final activeFoundations = allTenants
        .where((tenant) => tenant.status.toUpperCase() == 'ACTIVE')
        .length;
    final suspendedFoundations = allTenants
        .where((tenant) => tenant.status.toUpperCase() == 'SUSPENDED')
        .length;
    final totalSchools = allSchools.length;

    final filteredTenants = allTenants.where((tenant) {
      if (selectedStatusFilter != 'ALL' &&
          tenant.status.toUpperCase() != selectedStatusFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesName = tenant.name.toLowerCase().contains(q);
        final matchesId = tenant.id.toLowerCase().contains(q);
        final matchesEntity =
            tenant.legalEntityNumber?.toLowerCase().contains(q) ?? false;
        final matchesReg =
            tenant.registrationType?.toLowerCase().contains(q) ?? false;
        return matchesName || matchesId || matchesEntity || matchesReg;
      }
      return true;
    }).toList();

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
                label: 'TOTAL FOUNDATIONS',
                value: '$totalFoundations',
                icon: LucideIcons.landmark,
              );
              final pill2 = TenantMetricPill(
                label: 'ACTIVE FOUNDATIONS',
                value: '$activeFoundations',
                icon: LucideIcons.checkCircle2,
                color: AppColors.forestSage,
              );
              final pill3 = TenantMetricPill(
                label: 'SUSPENDED',
                value: '$suspendedFoundations',
                icon: LucideIcons.ban,
                color: AppColors.earthyTerra,
              );
              final pill4 = TenantMetricPill(
                label: 'TOTAL CAMPUSES',
                value: '$totalSchools',
                icon: LucideIcons.school,
                color: Colors.blue.shade700,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText:
                      'Search by foundation name, tenant ID, or AHU number...',
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
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: ['ALL', 'ACTIVE', 'SUSPENDED'].map((st) {
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: onRegisterFoundation,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text(
                      'Register Foundation / Tenant',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Foundations List
          if (filteredTenants.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(LucideIcons.landmark,
                        size: 40, color: c.mutedForeground),
                    const SizedBox(height: 8),
                    Text('No foundation tenants matched the criteria.',
                        style: t.p),
                  ],
                ),
              ),
            )
          else
            ...filteredTenants.map((tenant) {
              final schools =
                  allSchools.where((s) => s.tenantId == tenant.id).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FoundationCard(
                  tenant: tenant,
                  affiliatedSchools: schools,
                  isCurrentTenant: tenant.id == currentTenantId,
                  onSwitchTenant: onSwitchTenant,
                  onEdit: onEditFoundation,
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
