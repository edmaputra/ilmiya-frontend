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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

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
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.forestSage),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.assessment_outlined),
                  selectedIcon: Icon(Icons.assessment, color: AppColors.forestSage),
                  label: 'Grades',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: state.unreadMessagesCount > 0,
                    label: Text('${state.unreadMessagesCount}'),
                    backgroundColor: AppColors.earthyTerra,
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: state.unreadMessagesCount > 0,
                    label: Text('${state.unreadMessagesCount}'),
                    backgroundColor: AppColors.earthyTerra,
                    child: const Icon(Icons.chat_bubble, color: AppColors.forestSage),
                  ),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: state.unreadNotifsCount > 0,
                    label: Text('${state.unreadNotifsCount}'),
                    backgroundColor: AppColors.earthyTerra,
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: state.unreadNotifsCount > 0,
                    label: Text('${state.unreadNotifsCount}'),
                    backgroundColor: AppColors.earthyTerra,
                    child: const Icon(Icons.notifications, color: AppColors.forestSage),
                  ),
                  label: 'Alerts',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.code),
                  selectedIcon: Icon(Icons.code, color: AppColors.forestSage),
                  label: 'Flutter Code',
                ),
              ],
            )
          : null,
    );
  }
}
