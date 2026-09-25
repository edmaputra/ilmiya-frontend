import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';

class TenantSchoolCard extends StatelessWidget {
  final SchoolResponse school;
  final bool isCurrentTenant;
  final ValueChanged<String> onSwitchTenant;
  final ValueChanged<SchoolResponse> onEditProfile;
  final ValueChanged<SchoolResponse> onSettings;
  final ValueChanged<SchoolResponse> onToggleStatus;

  const TenantSchoolCard({
    super.key,
    required this.school,
    required this.isCurrentTenant,
    required this.onSwitchTenant,
    required this.onEditProfile,
    required this.onSettings,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    KiteTone statusTone = KiteTone.neutral;
    if (school.status == 'ACTIVE') statusTone = KiteTone.success;
    if (school.status == 'SUSPENDED') statusTone = KiteTone.danger;
    if (school.status == 'PENDING') statusTone = KiteTone.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentTenant ? AppColors.forestSage.withOpacity(0.04) : c.card,
        borderRadius: KiteRadius.allMd,
        border: Border.all(
          color: isCurrentTenant
              ? AppColors.forestSage.withOpacity(0.4)
              : c.border,
        ),
      ),
      child: Row(
        children: [
          // School Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.forestSage.withOpacity(0.12),
            ),
            child: const Center(
              child: Icon(LucideIcons.landmark,
                  size: 20, color: AppColors.forestSage),
            ),
          ),
          const SizedBox(width: 12),

          // School Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      school.name,
                      style: t.small
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    KiteBadge(school.status, tone: statusTone),
                    if (isCurrentTenant) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE SESSION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    Text('Tenant: ${school.tenantId}',
                        style: t.muted.copyWith(fontSize: 11)),
                    Text('Code: ${school.institutionCode}',
                        style: t.muted.copyWith(fontSize: 11)),
                    if (school.governmentRegistrationNumber != null)
                      Text('NPSN: ${school.governmentRegistrationNumber}',
                          style: t.muted.copyWith(fontSize: 11)),
                    Text('Accreditation: ${school.accreditationStatus ?? '-'}',
                        style: t.muted.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${school.address} • ${school.contactEmail} • ${school.contactPhone}',
                  style: t.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCurrentTenant)
                OutlinedButton.icon(
                  onPressed: () => onSwitchTenant(school.tenantId),
                  icon: const Icon(LucideIcons.arrowRightLeft, size: 13),
                  label: const Text('Switch', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    foregroundColor: AppColors.forestSage,
                  ),
                ),
              const SizedBox(width: 6),
              IconButton(
                iconSize: 16,
                tooltip: 'Edit Profile',
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => onEditProfile(school),
              ),
              IconButton(
                iconSize: 16,
                tooltip: 'Operational Settings',
                icon: const Icon(LucideIcons.settings),
                onPressed: () => onSettings(school),
              ),
              IconButton(
                iconSize: 16,
                tooltip: school.status == 'ACTIVE'
                    ? 'Suspend Tenant'
                    : 'Activate Tenant',
                icon: Icon(
                  school.status == 'ACTIVE'
                      ? LucideIcons.ban
                      : LucideIcons.checkCircle,
                  color: school.status == 'ACTIVE'
                      ? AppColors.earthyTerra
                      : AppColors.forestSage,
                ),
                onPressed: () => onToggleStatus(school),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
