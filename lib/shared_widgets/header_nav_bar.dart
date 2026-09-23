import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/iam.dart';
import '../core/services/api_client.dart';
import '../features/auth/presentation/login_dialog.dart';
import '../state/app_state.dart';
import '../state/auth_notifier.dart';
import 'ilmiya_logo.dart';

class HeaderNavBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final isTablet = MediaQuery.of(context).size.width >= 640;

    final currentUser = auth.user;
    final actorName = currentUser?.fullName.isNotEmpty == true
        ? currentUser!.fullName
        : appState.currentUser.name;
    final primaryRole = auth.roles.isNotEmpty
        ? auth.roles.first
        : appState.currentUser.role.displayName;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF2FAF9F6),
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            // Brand Logo & Title
            if (isDesktop)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IlmiyaLogo(size: 38, isSquircle: true),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Ilmiya',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warmSand,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Text(
                              'SIS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestSage,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        auth.tenantId == 'tenant-lincoln-high-001'
                            ? 'Lincoln High School'
                            : auth.tenantId == 'tenant-sma1-ilmiya-002'
                                ? 'SMA Negeri 1 Ilmiya'
                                : auth.tenantId
                                    .replaceAll('tenant-', '')
                                    .replaceAll('-', ' ')
                                    .toUpperCase(),
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
                ],
              )
            else
              Expanded(
                child: Row(
                  children: [
                    const IlmiyaLogo(size: 38, isSquircle: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Ilmiya',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmSand,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.borderLight),
                                  ),
                                  child: const Text(
                                    'SIS',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.forestSage,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            auth.tenantId == 'tenant-lincoln-high-001'
                                ? 'Lincoln High School'
                                : auth.tenantId == 'tenant-sma1-ilmiya-002'
                                    ? 'SMA Negeri 1 Ilmiya'
                                    : auth.tenantId
                                        .replaceAll('tenant-', '')
                                        .replaceAll('-', ' ')
                                        .toUpperCase(),
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
                  ],
                ),
              ),

            const SizedBox(width: 8),

            // Navigation Tabs (Desktop Web)
            if (isDesktop)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavPill(
                            context,
                            label: 'School Profile',
                            tabIndex: 0,
                            icon: Icons.account_balance_outlined,
                            isActive: appState.currentTab == 0,
                          ),
                          _buildNavPill(
                            context,
                            label: 'Academic Years',
                            tabIndex: 1,
                            icon: Icons.calendar_month_outlined,
                            isActive: appState.currentTab == 1,
                          ),
                          _buildNavPill(
                            context,
                            label: 'IAM Console',
                            tabIndex: 2,
                            icon: Icons.admin_panel_settings_outlined,
                            isActive: appState.currentTab == 2,
                          ),
                          _buildNavPill(
                            context,
                            label: 'Feature Previews',
                            tabIndex: 3,
                            icon: Icons.science_outlined,
                            isActive: appState.currentTab == 3,
                            tag: 'Labs',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Right Controls: Mode Toggle, Tenant Badge, Actor Profile
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode indicator
                if (isTablet) ...[
                  ListenableBuilder(
                    listenable: apiClient,
                    builder: (context, _) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          apiClient.toggleMockMode();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                apiClient.isMockMode
                                    ? 'Switched to Mock In-Memory Simulation'
                                    : 'Switched to Live REST Backend Mode (${apiClient.baseUrl})',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: apiClient.isMockMode
                                ? const Color(0xFFF3E8FF)
                                : const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: apiClient.isMockMode
                                  ? const Color(0xFFD8B4FE)
                                  : const Color(0xFFA8DAB5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: apiClient.isMockMode
                                      ? const Color(0xFF9333EA)
                                      : const Color(0xFF137333),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                apiClient.isMockMode
                                    ? 'Mock Simulation'
                                    : 'Live REST API',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: apiClient.isMockMode
                                      ? const Color(0xFF7E22CE)
                                      : const Color(0xFF137333),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],

                // Tenant Badge / Switcher
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showTenantSwitcherDialog(context, auth),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.domain_rounded,
                          size: 13,
                          color: AppColors.forestSage,
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: isTablet ? 120 : 75),
                          child: Text(
                            auth.tenantId == 'tenant-lincoln-high-001'
                                ? 'Lincoln High'
                                : auth.tenantId == 'tenant-sma1-ilmiya-002'
                                    ? 'SMAN 1 Ilmiya'
                                    : auth.tenantId,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.swap_vert,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Actor Profile & Persona Switcher Menu
                PopupMenuButton<String>(
                  tooltip: 'Account & Personas',
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  onSelected: (action) {
                    if (action == 'login') {
                      LoginDialog.show(context);
                    } else if (action == 'logout') {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Signed out successfully.')),
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
                        '1-CLICK PERSONAS (RBAC)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
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
                              isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 14,
                              color: isActive
                                  ? AppColors.forestSage
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    persona.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isActive
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${persona.roleLabel} • ${persona.email}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
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
                          Icon(Icons.login,
                              size: 16, color: AppColors.forestSage),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sign In with Custom Credentials...',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout,
                              size: 16, color: AppColors.earthyTerra),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.earthyTerra,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppColors.forestSage.withOpacity(0.2),
                          child: Text(
                            actorName.isNotEmpty
                                ? actorName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ),
                        if (isTablet) ...[
                          const SizedBox(width: 8),
                          // Cap width to prevent unbounded text from overflowing
                          // the available Row space on tablet-range screen sizes.
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  actorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  primaryRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.forestSage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill(
    BuildContext context, {
    required String label,
    required int tabIndex,
    required bool isActive,
    IconData? icon,
    String? tag,
  }) {
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
                  tag,
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

  void _showTenantSwitcherDialog(BuildContext context, AuthNotifier auth) {
    final tenantCtrl = TextEditingController(text: auth.tenantId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.domain_rounded, color: AppColors.forestSage),
            SizedBox(width: 8),
            Text('Switch Multi-Tenant Context', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify target school tenant ID to isolate data partitions:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tenantCtrl,
              decoration: const InputDecoration(
                labelText: 'Tenant ID',
                prefixIcon: Icon(Icons.apartment_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.school,
                      size: 14, color: AppColors.forestSage),
                  label: const Text('Lincoln High (tenant-lincoln-high-001)',
                      style: TextStyle(fontSize: 11)),
                  onPressed: () => tenantCtrl.text = 'tenant-lincoln-high-001',
                ),
                ActionChip(
                  avatar: const Icon(Icons.account_balance,
                      size: 14, color: AppColors.forestSage),
                  label: const Text('SMAN 1 Ilmiya (tenant-sma1-ilmiya-002)',
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
