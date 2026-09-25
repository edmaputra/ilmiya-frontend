import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';

class AppShellNavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int tabIndex;
  final bool isActive;
  final String? badgeText;
  final int? unreadCount;

  const AppShellNavTile({
    super.key,
    required this.title,
    required this.icon,
    required this.tabIndex,
    required this.isActive,
    this.badgeText,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive
            ? (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2E2A)
                : const Color(0xFFF1F5F9))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context.read<AppState>().setTab(tabIndex);
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? AppColors.forestSage : c.mutedForeground,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: t.small.copyWith(
                      color: isActive ? c.foreground : c.mutedForeground,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (unreadCount != null && unreadCount! > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (badgeText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: c.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: c.mutedForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
