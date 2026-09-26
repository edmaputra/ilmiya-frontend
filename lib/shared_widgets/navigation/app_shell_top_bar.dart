import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/search/ilmiya_command_palette.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';

class AppShellTopBar extends StatelessWidget {
  final bool isDesktop;

  const AppShellTopBar({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();

    final schoolDisplayName = auth.tenantId == 'tenant-lincoln-high-001'
        ? 'Lincoln High School'
        : auth.tenantId == 'tenant-sma1-ilmiya-002'
            ? 'SMA Negeri 1 Ilmiya'
            : auth.tenantId
                .replaceAll('tenant-', '')
                .replaceAll('-', ' ')
                .toUpperCase();

    final pageTitles = [
      'School Profile',
      'Academic Years',
      'IAM Console',
      'Feature Previews',
      'Executive Dashboard',
      'Courses & Grades',
      'Messages',
      'Notifications',
      'Tenant Console',
    ];

    final currentTitle = state.currentTab < pageTitles.length
        ? pageTitles[state.currentTab]
        : 'Ilmiya SIS';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        border: BorderDirectional(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(LucideIcons.menu, size: 20),
              color: c.mutedForeground,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: t.large
                      .copyWith(fontWeight: FontWeight.w700, height: 1.1),
                ),
                Text(
                  schoolDisplayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestSage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Search Trigger (⌘K)
          if (isDesktop)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showIlmiyaCommandPalette(context),
              child: Container(
                width: 200,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.search,
                        size: 14, color: c.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search... ⌘K',
                        overflow: TextOverflow.ellipsis,
                        style: t.muted.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.search, size: 18),
              tooltip: 'Search (⌘K)',
              onPressed: () => showIlmiyaCommandPalette(context),
            ),

          const SizedBox(width: 4),

          // Notifications bell
          IconButton(
            iconSize: 18,
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: state.unreadNotifsCount > 0,
              label: Text('${state.unreadNotifsCount}'),
              child: const Icon(LucideIcons.bell),
            ),
            onPressed: () => state.setTab(7),
          ),

          // Kite Accent Selector
          PopupMenuButton<KiteAccent>(
            tooltip: 'Kite Theme Accent',
            icon: Icon(
              LucideIcons.palette,
              size: 18,
              color: c.primary,
            ),
            initialValue: state.accent,
            onSelected: (accent) => state.setAccent(accent),
            itemBuilder: (context) => [
              for (final accent in KiteAccent.values)
                PopupMenuItem(
                  value: accent,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.primaryColor(
                            state.themeMode == ThemeMode.dark
                                ? Brightness.dark
                                : Brightness.light,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(accent.label),
                      if (state.accent == accent) ...[
                        const Spacer(),
                        Icon(LucideIcons.check, size: 14, color: c.primary),
                      ],
                    ],
                  ),
                ),
            ],
          ),

          // Dark/Light Theme toggle
          IconButton(
            iconSize: 18,
            tooltip:
                state.themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              state.themeMode == ThemeMode.dark
                  ? LucideIcons.sun
                  : LucideIcons.moon,
            ),
            onPressed: () => state.toggleThemeMode(),
          ),
        ],
      ),
    );
  }
}
