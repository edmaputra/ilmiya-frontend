import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';

class TenantIdentityCard extends StatelessWidget {
  final SchoolResponse school;

  const TenantIdentityCard({
    super.key,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.landmark,
                  color: AppColors.forestSage, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Legal & Institutional Identity',
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          _infoRow(
              context, LucideIcons.fingerprint, 'Tenant ID', school.tenantId),
          const SizedBox(height: 10),
          _infoRow(context, LucideIcons.barcode, 'Institution Code',
              school.institutionCode),
          const SizedBox(height: 10),
          _infoRow(context, LucideIcons.badgeCheck, 'Govt Registration (NPSN)',
              school.governmentRegistrationNumber ?? '-'),
          const SizedBox(height: 10),
          _infoRow(context, LucideIcons.award, 'Accreditation',
              '${school.accreditationStatus ?? '-'} (${school.accreditationBody ?? ''})'),
          const SizedBox(height: 10),
          _infoRow(
              context,
              LucideIcons.calendarCheck,
              'Accreditation Valid Until',
              school.accreditationValidUntil ?? '-'),
          const SizedBox(height: 10),
          _infoRow(
              context, LucideIcons.mapPin, 'Campus Address', school.address),
          const SizedBox(height: 10),
          _infoRow(
              context, LucideIcons.mail, 'Contact Email', school.contactEmail),
          const SizedBox(height: 10),
          _infoRow(
              context, LucideIcons.phone, 'Contact Phone', school.contactPhone),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.mutedForeground),
        const SizedBox(width: 8),
        SizedBox(
          width: 150,
          child: Text(label, style: t.small.copyWith(color: c.mutedForeground)),
        ),
        Expanded(
          child: Text(
            value,
            style: t.small
                .copyWith(fontWeight: FontWeight.w600, color: c.foreground),
          ),
        ),
      ],
    );
  }
}
