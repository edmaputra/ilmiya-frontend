import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';

class HeaderNavPill extends StatelessWidget {
  final String label;
  final int tabIndex;
  final bool isActive;
  final IconData? icon;
  final String? tag;

  const HeaderNavPill({
    super.key,
    required this.label,
    required this.tabIndex,
    required this.isActive,
    this.icon,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('nav_pill_$tabIndex'),
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setTab(tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.naturalParchment : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color:
                    isActive ? AppColors.forestSage : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color:
                    isActive ? AppColors.forestSage : AppColors.textSecondary,
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.warmSand,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  tag!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestSage,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
