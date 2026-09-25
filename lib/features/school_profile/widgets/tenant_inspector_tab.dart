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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: KiteRadius.allMd,
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.searchCode,
                    size: 18, color: AppColors.forestSage),
                const SizedBox(width: 10),
                const Text(
                  'Select Tenant to Inspect:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: inspected.tenantId,
                      isExpanded: true,
                      items: schools
                          .map((s) => DropdownMenuItem(
                                value: s.tenantId,
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
                OutlinedButton.icon(
                  onPressed: () => onEditProfile(inspected),
                  icon: const Icon(LucideIcons.pencil, size: 14),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Card: Institutional Details
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: TenantIdentityCard(school: inspected),
                  ),

                  if (isWide)
                    const SizedBox(width: 16)
                  else
                    const SizedBox(height: 16),

                  // Right Card: Operational Schedule & Rules
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: TenantOperationalPoliciesCard(
                      school: inspected,
                      onSettings: onSettings,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
