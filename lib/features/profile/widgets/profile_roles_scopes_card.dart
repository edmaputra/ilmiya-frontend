import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../state/auth_notifier.dart';

class ProfileRolesScopesCard extends StatelessWidget {
  final UserProfileResponse? user;
  final AuthNotifier auth;

  const ProfileRolesScopesCard({
    super.key,
    required this.user,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final roles = auth.roles;
    final scopes = auth.scopes;
    final permissions = auth.permissions;
    final isSuperAdmin = auth.isSuperAdmin;

    return KiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.shieldCheck,
                    color: AppColors.forestSage, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assigned Roles & Scope Boundaries',
                    style: t.large.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(height: 20, color: c.border),
            const SizedBox(height: 8),

            // Roles Section
            Text('Granted Security Roles',
                style: t.small.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (roles.isEmpty)
              Text('No specific roles assigned', style: t.muted)
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: roles.map((role) {
                  return Chip(
                    avatar: const Icon(LucideIcons.shield,
                        size: 14, color: AppColors.forestSage),
                    label: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestSage,
                      ),
                    ),
                    backgroundColor: AppColors.forestSage.withOpacity(0.08),
                    side: const BorderSide(color: Color(0xFFBBF7D0)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Accessible Scopes Section
            Text('Authorized Scope Boundaries',
                style: t.small.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (isSuperAdmin)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.globe,
                        size: 16, color: Color(0xFF7E22CE)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Global Platform Boundary: Unrestricted access across all tenant scopes.',
                        style: t.small.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF6B21A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (scopes.isEmpty)
              Text('Root / Institutional level (No sub-scope restrictions)',
                  style: t.muted)
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: scopes.map((scope) {
                  return Chip(
                    avatar: const Icon(LucideIcons.folderTree,
                        size: 14, color: Color(0xFFD97706)),
                    label: Text(
                      scope,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Color(0xFF92400E),
                      ),
                    ),
                    backgroundColor: const Color(0xFFFEF3C7),
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Permissions overview
            Text('Effective Permissions Overview',
                style: t.small.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (isSuperAdmin || permissions.contains('*'))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.sparkles,
                        size: 16, color: Color(0xFF15803D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Full System Privileges (*): All IAM, Academic, Institution & Security operations permitted.',
                        style: t.small.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: permissions.map((p) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      p,
                      style: t.small.copyWith(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
