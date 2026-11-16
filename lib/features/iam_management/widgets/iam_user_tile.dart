import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';

class IamUserTile extends StatelessWidget {
  final UserResponse user;
  final String? assignedRole;
  final String? assignedScope;
  final bool canUpdateStatus;
  final bool canAssign;
  final bool canDelete;
  final ValueChanged<UserResponse> onAssignRole;
  final Future<void> Function() onDataReload;

  const IamUserTile({
    super.key,
    required this.user,
    this.assignedRole,
    this.assignedScope,
    required this.canUpdateStatus,
    required this.canAssign,
    required this.canDelete,
    required this.onAssignRole,
    required this.onDataReload,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        if (isNarrow) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: c.accent,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0] : '?',
                        style: TextStyle(
                          color: c.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                user.fullName,
                                style: t.small.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground,
                                ),
                              ),
                              if (user.isPlatformSuperAdmin)
                                const KiteBadge('SUPERADMIN',
                                    tone: KiteTone.warning),
                            ],
                          ),
                          Text(
                            user.email,
                            style: t.small.copyWith(
                              fontSize: 11,
                              color: c.mutedForeground,
                            ),
                          ),
                          if (assignedRole != null ||
                              assignedScope != null) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              children: [
                                if (assignedRole != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: c.accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Role: $assignedRole',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                if (assignedScope != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.forestSage
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Scope: $assignedScope',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.forestSage,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: user.status,
                      underline: const SizedBox(),
                      dropdownColor: c.card,
                      style: t.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: c.foreground,
                      ),
                      items: [
                        'ACTIVE',
                        'SUSPENDED',
                        'PENDING_ACTIVATION',
                        'DEACTIVATED'
                      ]
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: canUpdateStatus
                          ? (val) async {
                              if (val != null) {
                                await iamService.changeUserStatus(user.id, val);
                                await onDataReload();
                              }
                            }
                          : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: canAssign ? () => onAssignRole(user) : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        foregroundColor: c.primary,
                        side: BorderSide(color: c.border),
                        shape: const RoundedRectangleBorder(
                            borderRadius: KiteRadius.allSm),
                      ),
                      icon: const Icon(LucideIcons.shieldAlert, size: 12),
                      label: const Text('Assign Role',
                          style: TextStyle(fontSize: 11)),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.trash2,
                          size: 16, color: c.destructive),
                      onPressed: canDelete
                          ? () async {
                              await iamService.deleteUser(user.id);
                              await onDataReload();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          leading: CircleAvatar(
            backgroundColor: c.accent,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0] : '?',
              style: TextStyle(
                color: c.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                user.fullName,
                style: t.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: c.foreground,
                ),
              ),
              if (user.isPlatformSuperAdmin)
                const KiteBadge('SUPERADMIN', tone: KiteTone.warning),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: t.small.copyWith(fontSize: 11, color: c.mutedForeground),
              ),
              if (assignedRole != null || assignedScope != null) ...[
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    if (assignedRole != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Role: $assignedRole',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (assignedScope != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Scope: $assignedScope',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: user.status,
                underline: const SizedBox(),
                dropdownColor: c.card,
                style: t.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: c.foreground,
                ),
                items: [
                  'ACTIVE',
                  'SUSPENDED',
                  'PENDING_ACTIVATION',
                  'DEACTIVATED'
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: canUpdateStatus
                    ? (val) async {
                        if (val != null) {
                          await iamService.changeUserStatus(user.id, val);
                          await onDataReload();
                        }
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: canAssign ? () => onAssignRole(user) : null,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  foregroundColor: c.primary,
                  side: BorderSide(color: c.border),
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allSm),
                ),
                icon: const Icon(LucideIcons.shieldAlert, size: 12),
                label:
                    const Text('Assign Role', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 16, color: c.destructive),
                onPressed: canDelete
                    ? () async {
                        await iamService.deleteUser(user.id);
                        await onDataReload();
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
