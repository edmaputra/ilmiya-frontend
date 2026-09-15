import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../state/app_state.dart';
import 'header_nav_bar.dart';
import 'toast_popover.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;

  const AdaptiveScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      appBar: const HeaderNavBar(),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: body,
            ),
          ),
          const ToastPopover(),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: state.currentTab,
              onDestinationSelected: (index) => state.setTab(index),
              backgroundColor: Colors.white,
              indicatorColor: AppColors.warmSand,
              elevation: 4,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.account_balance_outlined),
                  selectedIcon: Icon(Icons.account_balance, color: AppColors.forestSage),
                  label: 'School',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month, color: AppColors.forestSage),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings, color: AppColors.forestSage),
                  label: 'IAM Console',
                ),
                NavigationDestination(
                  icon: Icon(Icons.science_outlined),
                  selectedIcon: Icon(Icons.science, color: AppColors.forestSage),
                  label: 'Previews',
                ),
              ],
            )
          : null,
    );
  }
}
