import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/school_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/edit_foundation_dialog.dart';
import '../dialogs/register_foundation_dialog.dart';
import '../dialogs/register_school_dialog.dart';
import '../widgets/foundations_directory_tab.dart';
import '../widgets/tenant_access_restricted_view.dart';
import '../widgets/tenant_quotas_tab.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TenantResponse> _tenants = [];
  List<SchoolResponse> _schools = [];
  bool _isLoading = true;

  // Foundations tab state
  String _foundationSearchQuery = '';
  String _foundationStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tenantsList = await tenantService.listTenants();
      final list = await schoolService.listSchools(bypassTenantHeader: true);
      if (mounted) {
        setState(() {
          _tenants = tenantsList;
          _schools = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegisterFoundationDialog() {
    RegisterFoundationDialog.show(
      context,
      onFoundationRegistered: _loadData,
    );
  }

  void _showRegisterSchoolDialog([String? tenantId]) {
    RegisterSchoolDialog.show(
      context,
      initialTenantId: tenantId,
      onSchoolRegistered: _loadData,
    );
  }

  void _showEditFoundationDialog(TenantResponse tenant) {
    EditFoundationDialog.show(
      context,
      tenant: tenant,
      onUpdated: _loadData,
    );
  }

  Future<void> _toggleFoundationStatus(TenantResponse tenant) async {
    final newStatus =
        tenant.status.toUpperCase() == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    try {
      await tenantService.updateTenantStatus(tenant.id, newStatus);
      await _loadData();
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Foundation ${tenant.name} is now ${newStatus.toLowerCase()}.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update foundation status: $e');
      }
    }
  }

  Future<void> _switchActiveTenant(String tenantId) async {
    final auth = context.read<AuthNotifier>();
    if (auth.tenantId == tenantId) return;

    try {
      await auth.switchTenant(tenantId);
      await _loadData();
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Active session switched to tenant: $tenantId',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to switch tenant session: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();

    final isSuperAdmin = auth.hasRole('SUPERADMIN') ||
        auth.hasPermission('*') ||
        auth.isSuperAdmin;

    if (!isSuperAdmin) {
      return const TenantAccessRestrictedView();
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Tenant Governance & Platform Administration',
                style: (isCompact ? t.h3 : t.h2)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forestSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SUPERADMIN',
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
          const SizedBox(height: 2),
          Text(
            'Multi-tenant Foundation (Yayasan) governance, tenant session control, and platform-wide quotas.',
            style: t.muted,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: c.primary,
              labelColor: c.foreground,
              unselectedLabelColor: c.mutedForeground,
              tabs: const [
                Tab(
                  icon: Icon(LucideIcons.landmark, size: 16),
                  text: 'Foundations (Yayasan)',
                ),
                Tab(
                  icon: Icon(LucideIcons.sliders, size: 16),
                  text: 'System & Quotas',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FoundationsDirectoryTab(
                  allTenants: _tenants,
                  allSchools: _schools,
                  searchQuery: _foundationSearchQuery,
                  selectedStatusFilter: _foundationStatusFilter,
                  currentTenantId: auth.tenantId,
                  onSearchChanged: (v) =>
                      setState(() => _foundationSearchQuery = v),
                  onStatusFilterChanged: (st) =>
                      setState(() => _foundationStatusFilter = st),
                  onRegisterFoundation: _showRegisterFoundationDialog,
                  onSwitchTenant: _switchActiveTenant,
                  onEditFoundation: _showEditFoundationDialog,
                  onToggleStatus: _toggleFoundationStatus,
                  onAddCampus: (tenantId) =>
                      _showRegisterSchoolDialog(tenantId),
                ),
                const TenantQuotasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
