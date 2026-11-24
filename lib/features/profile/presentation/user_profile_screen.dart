import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../state/auth_notifier.dart';
import '../widgets/profile_account_details_card.dart';
import '../widgets/profile_admin_management_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_roles_scopes_card.dart';
import '../widgets/profile_security_card.dart';

class UserProfileScreen extends StatefulWidget {
  final IamService? iamService;

  const UserProfileScreen({
    super.key,
    this.iamService,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final IamService _iamService;
  List<UserResponse> _users = [];
  List<RoleResponse> _roles = [];
  bool _isLoading = false;
  String? _lastTenantId;

  @override
  void initState() {
    super.initState();
    _iamService = widget.iamService ?? IamService(apiClient: apiClient);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTenant = context.watch<AuthNotifier>().tenantId;
    if (_lastTenantId != currentTenant) {
      _lastTenantId = currentTenant;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthNotifier>();
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      if (auth.isSuperAdmin) {
        final tId = auth.tenantId;
        final results = await Future.wait([
          _iamService.listUsers(
              tenantId: tId.isNotEmpty && tId != 'platform' ? tId : null),
          _iamService.listRoles(
              tenantId: tId.isNotEmpty && tId != 'platform' ? tId : null),
        ]);
        if (mounted) {
          setState(() {
            _users = results[0] as List<UserResponse>;
            _roles = results[1] as List<RoleResponse>;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final user = auth.user;
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: c.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.refreshProfile();
          await _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Title Header
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'User Profile & Account Management',
                    style: (isDesktop ? t.h2 : t.h3)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      auth.isSuperAdmin ? 'SUPERADMIN' : 'ACCOUNT',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestSage,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: c.primary,
                    minHeight: 2,
                  ),
                ),

              // Profile Header Card
              ProfileHeaderCard(user: user, auth: auth),
              const SizedBox(height: 16),

              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Account Details & Security
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileAccountDetailsCard(
                            user: user,
                            auth: auth,
                            iamService: _iamService,
                            onProfileUpdated: () => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          ProfileSecurityCard(
                            user: user,
                            iamService: _iamService,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column: Roles/Scopes & Superadmin Management
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileRolesScopesCard(user: user, auth: auth),
                          if (auth.isSuperAdmin) ...[
                            const SizedBox(height: 16),
                            ProfileAdminManagementCard(
                              users: _users,
                              roles: _roles,
                              iamService: _iamService,
                              currentTenantId: auth.tenantId,
                              onDataReload: _loadData,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                ProfileAccountDetailsCard(
                  user: user,
                  auth: auth,
                  iamService: _iamService,
                  onProfileUpdated: () => setState(() {}),
                ),
                const SizedBox(height: 16),
                ProfileSecurityCard(
                  user: user,
                  iamService: _iamService,
                ),
                const SizedBox(height: 16),
                ProfileRolesScopesCard(user: user, auth: auth),
                if (auth.isSuperAdmin) ...[
                  const SizedBox(height: 16),
                  ProfileAdminManagementCard(
                    users: _users,
                    roles: _roles,
                    iamService: _iamService,
                    currentTenantId: auth.tenantId,
                    onDataReload: _loadData,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
