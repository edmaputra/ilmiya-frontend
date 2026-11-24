import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/utils/app_toast.dart';
import '../../../shared_widgets/navigation/header_tenant_switcher_dialog.dart';
import '../../../state/auth_notifier.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfileResponse? user;
  final AuthNotifier auth;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'User';
    final email = user?.email ?? '';
    final primaryRole = auth.roles.isNotEmpty ? auth.roles.first : 'User';
    final isSuperAdmin = auth.isSuperAdmin;

    return KiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.forestSage.withOpacity(0.18),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestSage,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                            name,
                            style: t.h3.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.forestSage.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              primaryRole,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestSage,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (isSuperAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF9333EA).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PLATFORM SUPERADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7E22CE),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 8, color: Color(0xFF16A34A)),
                                SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (email.isNotEmpty)
                        Row(
                          children: [
                            Icon(LucideIcons.mail,
                                size: 14, color: c.mutedForeground),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                email,
                                style: t.muted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: c.border),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _badgeInfo(
                  context,
                  LucideIcons.building2,
                  'Active Tenant',
                  auth.tenantDisplayName.isNotEmpty
                      ? '${auth.tenantDisplayName} (${auth.tenantId})'
                      : (auth.isPlatformSession
                          ? 'Platform Operations (platform)'
                          : auth.tenantId),
                ),
                if (auth.schoolName.isNotEmpty)
                  _badgeInfo(
                    context,
                    LucideIcons.school,
                    'Campus / School',
                    auth.schoolName,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('profile_switch_tenant_btn'),
                  onPressed: () =>
                      HeaderTenantSwitcherDialog.show(context, auth),
                  icon: const Icon(LucideIcons.arrowLeftRight, size: 15),
                  label: const Text('Switch Tenant Context'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.white : AppColors.textPrimary,
                    side: BorderSide(color: c.border),
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('profile_sign_out_btn'),
                  onPressed: () {
                    auth.logout();
                    AppToast.showSuccess(context, 'Signed out successfully.');
                  },
                  icon: const Icon(LucideIcons.logOut,
                      size: 15, color: AppColors.earthyTerra),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.earthyTerra),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeInfo(
      BuildContext context, IconData icon, String label, String value) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.forestSage),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: t.muted.copyWith(fontSize: 10)),
                Text(
                  value,
                  style: t.small.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
