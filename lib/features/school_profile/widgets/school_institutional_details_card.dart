import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/school.dart';

class SchoolInstitutionalDetailsCard extends StatelessWidget {
  final SchoolResponse profile;

  const SchoolInstitutionalDetailsCard({
    super.key,
    required this.profile,
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
              Icon(LucideIcons.landmark, color: c.foreground, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Institutional Details',
                  overflow: TextOverflow.ellipsis,
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          _infoRow(context, LucideIcons.mapPin, 'Address', profile.address),
          const SizedBox(height: 12),
          _infoRow(
              context, LucideIcons.mail, 'Contact Email', profile.contactEmail),
          const SizedBox(height: 12),
          _infoRow(context, LucideIcons.phone, 'Contact Phone',
              profile.contactPhone),
          const SizedBox(height: 12),
          _infoRow(
            context,
            LucideIcons.badgeCheck,
            'Govt Registration (NPSN)',
            profile.governmentRegistrationNumber ?? '-',
          ),
          const SizedBox(height: 12),
          _infoRow(
            context,
            LucideIcons.award,
            'Accreditation',
            '${profile.accreditationStatus ?? '-'} (${profile.accreditationBody ?? ''})',
          ),
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
          width: 140,
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
