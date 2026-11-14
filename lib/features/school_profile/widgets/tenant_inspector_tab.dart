import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import 'tenant_identity_card.dart';
import 'tenant_operational_policies_card.dart';

class TenantInspectorTab extends StatelessWidget {
  final List<SchoolResponse> schools;
  final SchoolResponse? inspectedSchool;
  final ValueChanged<String> onSelectSchool;
  final ValueChanged<SchoolResponse> onEditProfile;
  final ValueChanged<SchoolResponse> onSettings;

  const TenantInspectorTab({
    super.key,
    required this.schools,
    required this.inspectedSchool,
    required this.onSelectSchool,
    required this.onEditProfile,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final inspected =
        inspectedSchool ?? (schools.isNotEmpty ? schools.first : null);

    if (inspected == null) {
      return Center(
        child: Text('No tenant available for inspection.', style: t.p),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tenant Selector Header
          LayoutBuilder(
            builder: (ctx, selectorConstraints) {
              final isCompact = selectorConstraints.maxWidth < 600;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: KiteRadius.allMd,
                  border: Border.all(color: c.border),
                ),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.searchCode,
                                  size: 18, color: AppColors.forestSage),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Select Tenant to Inspect:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: inspected.id,
                                    isExpanded: true,
                                    items: schools
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(
                                                '${s.name} (${s.tenantId})',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (newId) {
                                      if (newId != null) {
                                        onSelectSchool(newId);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => onEditProfile(inspected),
                                icon: const Icon(LucideIcons.pencil, size: 14),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(LucideIcons.searchCode,
                              size: 18, color: AppColors.forestSage),
                          const SizedBox(width: 10),
                          const Text(
                            'Select Tenant to Inspect:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: inspected.id,
                                isExpanded: true,
                                items: schools
                                    .map((s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(
                                              '${s.name} (${s.tenantId} • ${s.institutionCode})'),
                                        ))
                                    .toList(),
                                onChanged: (newId) {
                                  if (newId != null) {
                                    onSelectSchool(newId);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => onEditProfile(inspected),
                            icon: const Icon(LucideIcons.pencil, size: 14),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final leftCard = TenantIdentityCard(school: inspected);
              final rightCard = TenantOperationalPoliciesCard(
                school: inspected,
                onSettings: onSettings,
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: leftCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: rightCard),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  leftCard,
                  const SizedBox(height: 16),
                  rightCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
