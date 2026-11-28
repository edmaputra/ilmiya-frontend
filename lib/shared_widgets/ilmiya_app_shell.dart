import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../features/search/ilmiya_command_palette.dart';
import '../state/app_navigation_guard.dart';
import '../state/app_state.dart';
import '../state/auth_notifier.dart';
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
    final auth = context.watch<AuthNotifier>();

    final mobileDestinations = <({int tab, IconData icon, String label})>[
      (
        tab: AppNavigationGuard.schoolProfileTab,
        icon: LucideIcons.school,
        label: 'School'
      ),
      (
        tab: AppNavigationGuard.academicYearsTab,
        icon: LucideIcons.calendarDays,
        label: 'Calendar'
      ),
      (
        tab: AppNavigationGuard.iamTab,
        icon: LucideIcons.shieldCheck,
        label: 'IAM Console'
      ),
      (
        tab: AppNavigationGuard.previewsTab,
        icon: LucideIcons.flaskConical,
        label: 'Previews'
      ),
    ].where((d) => AppNavigationGuard.canViewTab(d.tab, auth)).toList();
    final mobileSelectedIndex =
        mobileDestinations.indexWhere((d) => d.tab == state.currentTab);

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
          bottomNavigationBar: !isDesktop &&
                  mobileDestinations.isNotEmpty &&
                  !auth.isPlatformSession
              ? NavigationBar(
                  selectedIndex:
                      mobileSelectedIndex < 0 ? 0 : mobileSelectedIndex,
                  onDestinationSelected: (index) =>
                      state.setTab(mobileDestinations[index].tab),
                  backgroundColor: c.card,
                  indicatorColor: c.primary.withOpacity(0.18),
                  destinations: [
                    for (final destination in mobileDestinations)
                      NavigationDestination(
                        icon: Icon(destination.icon, size: 20),
                        label: destination.label,
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
