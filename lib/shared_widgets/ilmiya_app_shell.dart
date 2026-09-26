import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../features/search/ilmiya_command_palette.dart';
import '../state/app_state.dart';
import 'navigation/app_shell_sidebar.dart';
import 'navigation/app_shell_top_bar.dart';
import 'toast_popover.dart';

class IlmiyaAppShell extends StatelessWidget {
  final Widget body;

  const IlmiyaAppShell({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final state = context.watch<AppState>();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showIlmiyaCommandPalette(context),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showIlmiyaCommandPalette(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: c.background,
          drawer: !isDesktop
              ? Drawer(
                  backgroundColor: c.card,
                  child: const SafeArea(
                    child: AppShellSidebar(),
                  ),
                )
              : null,
          bottomNavigationBar: !isDesktop
              ? NavigationBar(
                  selectedIndex: state.currentTab.clamp(0, 3),
                  onDestinationSelected: (index) => state.setTab(index),
                  backgroundColor: c.card,
                  indicatorColor: AppColors.forestSage.withOpacity(0.18),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(LucideIcons.school, size: 20),
                      label: 'School',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.calendarDays, size: 20),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.shieldCheck, size: 20),
                      label: 'IAM Console',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.flaskConical, size: 20),
                      label: 'Previews',
                    ),
                  ],
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                Row(
                  children: [
                    if (isDesktop)
                      SizedBox(
                        width: 256,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.card,
                            border: BorderDirectional(
                              end: BorderSide(color: c.border),
                            ),
                          ),
                          child: const AppShellSidebar(),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          AppShellTopBar(isDesktop: isDesktop),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ],
                ),
                const ToastPopover(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
