import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';

class TenantSchoolCard extends StatelessWidget {
  final SchoolResponse school;
  final TenantResponse? parentTenant;
  final bool isCurrentTenant;
  final ValueChanged<String>? onSwitchTenant;
  final ValueChanged<SchoolResponse> onEditProfile;
  final ValueChanged<SchoolResponse> onSettings;
  final ValueChanged<SchoolResponse> onToggleStatus;
  final ValueChanged<String>? onAddCampus;
  final bool canAddCampus;
  final bool canEditProfile;
  final bool canManageSettings;
  final bool canToggleStatus;

  const TenantSchoolCard({
    super.key,
    required this.school,
    this.parentTenant,
    required this.isCurrentTenant,
    this.onSwitchTenant,
    required this.onEditProfile,
    required this.onSettings,
    required this.onToggleStatus,
    this.onAddCampus,
    required this.canAddCampus,
    required this.canEditProfile,
    required this.canManageSettings,
    required this.canToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    KiteTone statusTone = KiteTone.neutral;
    if (school.status == 'ACTIVE') statusTone = KiteTone.success;
    if (school.status == 'SUSPENDED') statusTone = KiteTone.danger;
    if (school.status == 'PENDING') statusTone = KiteTone.warning;

    return LayoutBuilder(
      builder: (ctx, itemConstraints) {
        final isCompact = itemConstraints.maxWidth < 650;

        final avatar = Container(
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
        );

        final nameAndBadges = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              school.name,
              style:
                  t.small.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            KiteBadge(school.status, tone: statusTone),
            if (isCurrentTenant)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
        );

        final metadataWrap = Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text('Tenant: ${school.tenantId}',
                style: t.muted.copyWith(fontSize: 11)),
            if (parentTenant != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Yayasan: ${parentTenant!.name}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestSage,
                  ),
                ),
              ),
            Text('Code: ${school.institutionCode}',
                style: t.muted.copyWith(fontSize: 11)),
            if (school.governmentRegistrationNumber != null)
              Text('NPSN: ${school.governmentRegistrationNumber}',
                  style: t.muted.copyWith(fontSize: 11)),
            Text('Accreditation: ${school.accreditationStatus ?? '-'}',
                style: t.muted.copyWith(fontSize: 11)),
          ],
        );

        final contactInfo = Text(
          '${school.address} • ${school.contactEmail} • ${school.contactPhone}',
          style: t.muted.copyWith(fontSize: 11),
        );

        final actionButtons = Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (canAddCampus && onAddCampus != null)
              IconButton(
                iconSize: 16,
                tooltip: 'Add School Campus',
                icon: const Icon(LucideIcons.school),
                onPressed: () => onAddCampus!(school.tenantId),
              ),
            if (canEditProfile)
              IconButton(
                iconSize: 16,
                tooltip: 'Edit Profile',
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => onEditProfile(school),
              ),
            if (canManageSettings)
              IconButton(
                iconSize: 16,
                tooltip: 'Operational Settings',
                icon: const Icon(LucideIcons.settings),
                onPressed: () => onSettings(school),
              ),
            if (canToggleStatus)
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
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentTenant
                ? AppColors.forestSage.withOpacity(0.04)
                : c.card,
            borderRadius: KiteRadius.allMd,
            border: Border.all(
              color: isCurrentTenant
                  ? AppColors.forestSage.withOpacity(0.4)
                  : c.border,
            ),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nameAndBadges,
                              const SizedBox(height: 4),
                              metadataWrap,
                              const SizedBox(height: 4),
                              contactInfo,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButtons,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatar,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nameAndBadges,
                          const SizedBox(height: 4),
                          metadataWrap,
                          const SizedBox(height: 4),
                          contactInfo,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    actionButtons,
                  ],
                ),
        );
      },
    );
  }
}
