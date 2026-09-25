import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/command_action_item.dart';

class CommandActionTile extends StatelessWidget {
  final CommandActionItem item;
  final bool isSelected;
  final bool isDark;

  const CommandActionTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C2E2A) : const Color(0xFFF1F5F9))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.forestSage.withOpacity(0.15)
                    : (isDark ? Colors.white10 : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                item.icon,
                size: 16,
                color: isSelected
                    ? AppColors.forestSage
                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white38 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              item.group,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
