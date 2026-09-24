import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_client.dart';
import '../../features/auth/presentation/login_dialog.dart';
import '../../state/app_state.dart';
import '../../state/auth_notifier.dart';

class CommandActionItem {
  final String title;
  final String group;
  final IconData icon;
  final String? subtitle;
  final VoidCallback onSelect;

  const CommandActionItem({
    required this.title,
    required this.group,
    required this.icon,
    this.subtitle,
    required this.onSelect,
  });
}

Future<void> showIlmiyaCommandPalette(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => const IlmiyaCommandPalette(),
  );
}

class IlmiyaCommandPalette extends StatefulWidget {
  const IlmiyaCommandPalette({super.key});

  @override
  State<IlmiyaCommandPalette> createState() => _IlmiyaCommandPaletteState();
}

class _IlmiyaCommandPaletteState extends State<IlmiyaCommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  int _selectedIndex = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _query = _controller.text.trim().toLowerCase();
        _selectedIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<CommandActionItem> _buildActions(BuildContext context) {
    final appState = context.read<AppState>();
    final auth = context.read<AuthNotifier>();

    return [
      // Navigation
      CommandActionItem(
        title: 'School Profile',
        group: 'Navigation',
        icon: LucideIcons.school,
        subtitle: 'Institution details, accreditation & leadership',
        onSelect: () {
          appState.setTab(0);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Academic Years & Terms',
        group: 'Navigation',
        icon: LucideIcons.calendarDays,
        subtitle: 'Academic calendar, semesters, and term schedules',
        onSelect: () {
          appState.setTab(1);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'IAM Console (Identity & Access)',
        group: 'Navigation',
        icon: LucideIcons.shieldCheck,
        subtitle: 'Manage staff, student, and admin credentials & roles',
        onSelect: () {
          appState.setTab(2);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Feature Previews & Labs',
        group: 'Navigation',
        icon: LucideIcons.flaskConical,
        subtitle: 'Experimental components and preview sandbox',
        onSelect: () {
          appState.setTab(3);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Dashboard Overview',
        group: 'Navigation',
        icon: LucideIcons.layoutDashboard,
        subtitle: 'Executive school metrics, attendance & timetable',
        onSelect: () {
          appState.setTab(4);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Courses & Gradebook',
        group: 'Navigation',
        icon: LucideIcons.graduationCap,
        subtitle: 'Curriculum, grade calculations & coursework',
        onSelect: () {
          appState.setTab(5);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Messages & Communications',
        group: 'Navigation',
        icon: LucideIcons.messageSquare,
        subtitle: 'Direct messages & school discussion channels',
        onSelect: () {
          appState.setTab(6);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Notifications & Alerts',
        group: 'Navigation',
        icon: LucideIcons.bell,
        subtitle: 'Administrative notices and academic alerts',
        onSelect: () {
          appState.setTab(7);
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: 'Tenant Management Console (SuperAdmin)',
        group: 'Navigation',
        icon: LucideIcons.building2,
        subtitle:
            'Multi-tenant institution registry, accreditation oversight & quotas',
        onSelect: () {
          appState.setTab(8);
          Navigator.of(context).pop();
        },
      ),

      // System Actions
      CommandActionItem(
        title: 'Toggle Theme (Light / Dark)',
        group: 'Actions',
        icon: appState.themeMode == ThemeMode.dark
            ? LucideIcons.sun
            : LucideIcons.moon,
        subtitle:
            'Currently: ${appState.themeMode == ThemeMode.dark ? "Dark" : "Light"}',
        onSelect: () {
          appState.toggleThemeMode();
          Navigator.of(context).pop();
        },
      ),
      CommandActionItem(
        title: apiClient.isMockMode
            ? 'Switch to Live REST Backend'
            : 'Switch to Mock Simulation',
        group: 'Actions',
        icon: LucideIcons.server,
        subtitle: apiClient.isMockMode
            ? 'Connect to backend at ${apiClient.baseUrl}'
            : 'Use fast in-memory simulation',
        onSelect: () {
          apiClient.toggleMockMode();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                apiClient.isMockMode
                    ? 'Switched to Mock In-Memory Simulation'
                    : 'Switched to Live REST Backend Mode (${apiClient.baseUrl})',
              ),
            ),
          );
        },
      ),
      CommandActionItem(
        title: 'Switch to Lincoln High School',
        group: 'Multi-Tenant Context',
        icon: LucideIcons.building,
        subtitle: 'Tenant: tenant-lincoln-high-001',
        onSelect: () async {
          Navigator.of(context).pop();
          await auth.switchTenant('tenant-lincoln-high-001');
        },
      ),
      CommandActionItem(
        title: 'Switch to SMA Negeri 1 Ilmiya',
        group: 'Multi-Tenant Context',
        icon: LucideIcons.building2,
        subtitle: 'Tenant: tenant-sma1-ilmiya-002',
        onSelect: () async {
          Navigator.of(context).pop();
          await auth.switchTenant('tenant-sma1-ilmiya-002');
        },
      ),
      CommandActionItem(
        title: 'Sign In / Switch Persona...',
        group: 'Actions',
        icon: LucideIcons.logIn,
        subtitle: 'Log in with custom credentials or demo RBAC persona',
        onSelect: () {
          Navigator.of(context).pop();
          LoginDialog.show(context);
        },
      ),
    ];
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final actions = _filteredActions(_buildActions(context));
    if (actions.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % actions.length;
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + actions.length) % actions.length;
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < actions.length) {
        actions[_selectedIndex].onSelect();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  List<CommandActionItem> _filteredActions(List<CommandActionItem> all) {
    if (_query.isEmpty) return all;
    return all.where((item) {
      return item.title.toLowerCase().contains(_query) ||
          item.group.toLowerCase().contains(_query) ||
          (item.subtitle?.toLowerCase().contains(_query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = _filteredActions(_buildActions(context));

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 460),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E201E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF3E423E) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Focus(
                  focusNode: _focusNode,
                  onKeyEvent: _handleKey,
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        size: 18,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a command, page, or search...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          'ESC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF3E423E) : const Color(0xFFE2E8F0),
              ),

              // Action List
              Expanded(
                child: actions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No matching commands found',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: actions.length,
                        itemBuilder: (context, index) {
                          final item = actions[index];
                          final isSelected = index == _selectedIndex;

                          return InkWell(
                            onTap: item.onSelect,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF2C2E2A)
                                        : const Color(0xFFF1F5F9))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.forestSage
                                              .withOpacity(0.15)
                                          : (isDark
                                              ? Colors.white10
                                              : const Color(0xFFF8FAFC)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 16,
                                      color: isSelected
                                          ? AppColors.forestSage
                                          : (isDark
                                              ? Colors.white70
                                              : const Color(0xFF475569)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        if (item.subtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.white38
                                                  : const Color(0xFF64748B),
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
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Footer helper
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF191B19)
                      : const Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF3E423E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Navigate with ↑ ↓ and ↵ to select',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ilmiya SIS Quick Search',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
