import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/iam.dart';
import 'iam_user_tile.dart';

class IamUsersTab extends StatelessWidget {
  final List<UserResponse> users;
  final String searchQuery;
  final bool canCreate;
  final bool canUpdateStatus;
  final bool canAssign;
  final bool canDelete;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreateUser;
  final ValueChanged<UserResponse> onAssignRole;
  final Future<void> Function() onDataReload;

  const IamUsersTab({
    super.key,
    required this.users,
    required this.searchQuery,
    required this.canCreate,
    required this.canUpdateStatus,
    required this.canAssign,
    required this.canDelete,
    required this.onSearchChanged,
    required this.onCreateUser,
    required this.onAssignRole,
    required this.onDataReload,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.search,
                        size: 18, color: c.mutedForeground),
                    hintText: 'Search user by name or email...',
                    hintStyle: t.small.copyWith(color: c.mutedForeground),
                    isDense: true,
                    fillColor: c.card,
                    border: const OutlineInputBorder(
                        borderRadius: KiteRadius.allMd),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canCreate ? onCreateUser : null,
                icon: Icon(canCreate ? LucideIcons.plus : LucideIcons.lock,
                    size: 16),
                label: const Text('Create User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: c.border),
              itemBuilder: (ctx, i) {
                final u = users[i];
                return IamUserTile(
                  user: u,
                  canUpdateStatus: canUpdateStatus,
                  canAssign: canAssign,
                  canDelete: canDelete,
                  onAssignRole: onAssignRole,
                  onDataReload: onDataReload,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
