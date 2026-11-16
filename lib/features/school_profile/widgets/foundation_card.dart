import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';

class FoundationCard extends StatelessWidget {
  final TenantResponse tenant;
  final List<SchoolResponse> affiliatedSchools;
  final bool isCurrentTenant;
  final ValueChanged<String> onSwitchTenant;
  final ValueChanged<TenantResponse> onEdit;
  final ValueChanged<TenantResponse> onToggleStatus;
  final ValueChanged<String> onAddCampus;

  const FoundationCard({
    super.key,
    required this.tenant,
    required this.affiliatedSchools,
    required this.isCurrentTenant,
    required this.onSwitchTenant,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onAddCampus,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final isSuspended = tenant.status.toUpperCase() == 'SUSPENDED';

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTenant
              ? AppColors.forestSage.withOpacity(0.5)
              : c.border,
          width: isCurrentTenant ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.landmark,
                  color: AppColors.forestSage,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          tenant.name,
                          style: t.h4.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.muted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tenant.id,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: c.mutedForeground,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSuspended
                                ? AppColors.earthyTerra.withOpacity(0.12)
                                : AppColors.forestSage.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tenant.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSuspended
                                  ? AppColors.earthyTerra
                                  : AppColors.forestSage,
                            ),
                          ),
                        ),
                        if (isCurrentTenant)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warmSand.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE SESSION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF854D0E),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (tenant.registrationType != null &&
                        tenant.registrationType!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tenant.registrationType!,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Metadata Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final maxItemWidth = constraints.maxWidth;
              return Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  if (tenant.legalEntityNumber != null &&
                      tenant.legalEntityNumber!.isNotEmpty)
                    _buildMetaItem(
                      c,
                      LucideIcons.shieldCheck,
                      'AHU / Legal Entity No.',
                      tenant.legalEntityNumber!,
                      maxWidth: maxItemWidth,
                    ),
                  if (tenant.address.isNotEmpty)
                    _buildMetaItem(
                      c,
                      LucideIcons.mapPin,
                      'HQ Address',
                      tenant.address,
                      maxWidth: maxItemWidth,
                    ),
                  if (tenant.contactEmail.isNotEmpty)
                    _buildMetaItem(
                      c,
                      LucideIcons.mail,
                      'Email',
                      tenant.contactEmail,
                      maxWidth: maxItemWidth,
                    ),
                  if (tenant.contactPhone.isNotEmpty)
                    _buildMetaItem(
                      c,
                      LucideIcons.phone,
                      'Phone',
                      tenant.contactPhone,
                      maxWidth: maxItemWidth,
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Affiliated Schools Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.muted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.border.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 320;
                    return Row(
                      children: [
                        const Icon(LucideIcons.school,
                            size: 14, color: AppColors.forestSage),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isNarrow
                                ? 'Campuses (${affiliatedSchools.length})'
                                : 'Affiliated School Campuses (${affiliatedSchools.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () => onAddCampus(tenant.id),
                          icon: const Icon(LucideIcons.plusCircle, size: 14),
                          label: const Text(
                            'Add Campus',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (affiliatedSchools.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'No school institutions currently registered under this Foundation.',
                      style: TextStyle(
                        fontSize: 11,
                        color: c.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: affiliatedSchools.map((s) {
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.institutionCode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestSage,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                s.name,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions Footer
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => onAddCampus(tenant.id),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Add School Campus',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => onEdit(tenant),
                icon: const Icon(LucideIcons.edit2, size: 14),
                label: const Text('Edit Foundation',
                    style: TextStyle(fontSize: 12)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: isSuspended
                      ? AppColors.forestSage
                      : AppColors.earthyTerra,
                ),
                onPressed: () => onToggleStatus(tenant),
                icon: Icon(
                  isSuspended ? LucideIcons.checkCircle : LucideIcons.ban,
                  size: 14,
                ),
                label: Text(
                  isSuspended ? 'Activate' : 'Suspend',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (!isCurrentTenant)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => onSwitchTenant(tenant.id),
                  icon: const Icon(LucideIcons.arrowRightLeft, size: 14),
                  label: const Text('Switch Session',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
    KiteColors c,
    IconData icon,
    String label,
    String value, {
    double? maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 13, color: c.mutedForeground),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: c.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
