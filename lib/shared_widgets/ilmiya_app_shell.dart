import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/models/iam.dart';
import '../core/services/api_client.dart';
import '../features/auth/presentation/login_dialog.dart';
import '../features/search/ilmiya_command_palette.dart';
import '../state/app_state.dart';
import '../state/auth_notifier.dart';
import 'ilmiya_logo.dart';
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
                    child: _SidebarContent(),
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
                          child: const _SidebarContent(),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          _TopBar(isDesktop: isDesktop),
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

class _SidebarContent extends StatelessWidget {
  const _SidebarContent();

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final state = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();

    final tenantDisplayName = auth.tenantId == 'tenant-lincoln-high-001'
        ? 'Lincoln High School'
        : auth.tenantId == 'tenant-sma1-ilmiya-002'
            ? 'SMA Negeri 1 Ilmiya'
            : auth.tenantId
                .replaceAll('tenant-', '')
                .replaceAll('-', ' ')
                .toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IlmiyaLogo(size: 34, isSquircle: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ilmiya',
                              style: t.h4.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.forestSage.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SIS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.forestSage,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'School Information System',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: t.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Active Tenant Selector Card
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _showTenantDialog(context, auth),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.building,
                        size: 14,
                        color: AppColors.forestSage,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenantDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              auth.tenantId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: c.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronsUpDown,
                        size: 14,
                        color: c.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Navigation Sections
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildSectionHeader('Institution & Control'),
              _NavTile(
                title: 'School Profile',
                icon: LucideIcons.school,
                tabIndex: 0,
                isActive: state.currentTab == 0,
              ),
              _NavTile(
                title: 'Executive Dashboard',
                icon: LucideIcons.layoutDashboard,
                tabIndex: 4,
                isActive: state.currentTab == 4,
              ),
              const SizedBox(height: 12),
              _buildSectionHeader('Academics'),
              _NavTile(
                title: 'Academic Years',
                icon: LucideIcons.calendarDays,
                tabIndex: 1,
                isActive: state.currentTab == 1,
              ),
              _NavTile(
                title: 'Courses & Grades',
                icon: LucideIcons.graduationCap,
                tabIndex: 5,
                isActive: state.currentTab == 5,
              ),
              const SizedBox(height: 12),
              _buildSectionHeader('Administration'),
              _NavTile(
                title: 'IAM Console',
                icon: LucideIcons.shieldCheck,
                tabIndex: 2,
                isActive: state.currentTab == 2,
              ),
              const SizedBox(height: 12),
              _buildSectionHeader('Communications & Labs'),
              _NavTile(
                title: 'Feature Previews',
                icon: LucideIcons.flaskConical,
                tabIndex: 3,
                isActive: state.currentTab == 3,
                badgeText: 'Labs',
              ),
              _NavTile(
                title: 'Messages',
                icon: LucideIcons.messageSquare,
                tabIndex: 6,
                isActive: state.currentTab == 6,
                unreadCount: state.unreadMessagesCount,
              ),
              _NavTile(
                title: 'Notifications',
                icon: LucideIcons.bell,
                tabIndex: 7,
                isActive: state.currentTab == 7,
                unreadCount: state.unreadNotifsCount,
              ),
            ],
          ),
        ),

        // Bottom Footer: Mode pill & User tile
        const Divider(height: 1),
        _buildFooter(context, state, auth),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppState state, AuthNotifier auth) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final user = auth.user;
    final userName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : state.currentUser.name;
    final userRole = auth.roles.isNotEmpty
        ? auth.roles.first
        : state.currentUser.role.displayName;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Backend Mode Pill
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final newMode = !apiClient.isMockMode;
              apiClient.isMockMode = newMode;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newMode
                        ? 'Switched to Mock In-Memory Simulation'
                        : 'Switched to Live REST Backend Mode (${apiClient.baseUrl})',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: apiClient.isMockMode
                    ? const Color(0xFFFAF5FF)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: apiClient.isMockMode
                      ? const Color(0xFFE9D5FF)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: apiClient.isMockMode
                          ? const Color(0xFF9333EA)
                          : const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      apiClient.isMockMode
                          ? 'Mock Simulation'
                          : 'Live REST API',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: apiClient.isMockMode
                            ? const Color(0xFF7E22CE)
                            : const Color(0xFF15803D),
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.refreshCw,
                    size: 11,
                    color: apiClient.isMockMode
                        ? const Color(0xFF7E22CE)
                        : const Color(0xFF15803D),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // User Profile Row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.forestSage.withOpacity(0.15),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestSage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.small.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      userRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.muted.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),

              // Theme Toggle
              IconButton(
                iconSize: 16,
                tooltip: state.themeMode == ThemeMode.dark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? LucideIcons.sun
                      : LucideIcons.moon,
                  color: c.mutedForeground,
                ),
                onPressed: () => state.toggleThemeMode(),
              ),

              // Logout / Switch Persona Menu
              _buildUserActionsMenu(context, auth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserActionsMenu(BuildContext context, AuthNotifier auth) {
    final c = KiteColors.of(context);
    return PopupMenuButton<String>(
      tooltip: 'User Account & RBAC Personas',
      offset: const Offset(0, -140),
      icon: Icon(LucideIcons.moreVertical, size: 16, color: c.mutedForeground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      onSelected: (action) {
        if (action == 'login') {
          LoginDialog.show(context);
        } else if (action == 'logout') {
          auth.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed out successfully.')),
          );
        } else if (action.startsWith('persona:')) {
          final keyStr = action.replaceFirst('persona:', '');
          final personaKey = DemoPersonaKey.values.firstWhere(
            (k) => k.name == keyStr,
            orElse: () => DemoPersonaKey.superadmin,
          );
          auth.loginAsPersona(personaKey);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'SWITCH DEMO PERSONA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        ...DemoPersonaKey.values.map((key) {
          final persona = DEMO_PERSONAS[key]!;
          final isActive = auth.user?.email == persona.email;
          return PopupMenuItem<String>(
            value: 'persona:${key.name}',
            child: Row(
              children: [
                Icon(
                  isActive ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  size: 14,
                  color:
                      isActive ? AppColors.forestSage : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      persona.roleLabel,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              Icon(LucideIcons.logIn, size: 15, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Sign In with Credentials...',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut, size: 15, color: AppColors.earthyTerra),
              SizedBox(width: 8),
              Text('Sign Out',
                  style: TextStyle(fontSize: 12, color: AppColors.earthyTerra)),
            ],
          ),
        ),
      ],
    );
  }

  void _showTenantDialog(BuildContext context, AuthNotifier auth) {
    final tenantCtrl = TextEditingController(text: auth.tenantId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.building, color: AppColors.forestSage, size: 20),
            SizedBox(width: 8),
            Text('Switch School Tenant', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select or enter target school tenant ID to isolate data partitions:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tenantCtrl,
              decoration: InputDecoration(
                labelText: 'Tenant ID',
                prefixIcon: const Icon(LucideIcons.school, size: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(LucideIcons.school, size: 14),
                  label: const Text('Lincoln High',
                      style: TextStyle(fontSize: 11)),
                  onPressed: () => tenantCtrl.text = 'tenant-lincoln-high-001',
                ),
                ActionChip(
                  avatar: const Icon(LucideIcons.graduationCap, size: 14),
                  label: const Text('SMAN 1 Ilmiya',
                      style: TextStyle(fontSize: 11)),
                  onPressed: () => tenantCtrl.text = 'tenant-sma1-ilmiya-002',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newTenant = tenantCtrl.text.trim();
              if (newTenant.isNotEmpty) {
                Navigator.of(ctx).pop();
                try {
                  await auth.switchTenant(newTenant);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched tenant to $newTenant')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error switching tenant: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Switch Tenant'),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int tabIndex;
  final bool isActive;
  final String? badgeText;
  final int? unreadCount;

  const _NavTile({
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

class _TopBar extends StatelessWidget {
  final bool isDesktop;

  const _TopBar({required this.isDesktop});

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
