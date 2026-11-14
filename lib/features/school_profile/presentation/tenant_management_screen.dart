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
import '../dialogs/edit_tenant_dialog.dart';
import '../dialogs/register_school_dialog.dart';
import '../dialogs/register_tenant_dialog.dart';
import '../dialogs/tenant_settings_dialog.dart';
import '../dialogs/tenant_status_confirmation_dialog.dart';
import '../widgets/tenant_access_restricted_view.dart';
import '../widgets/tenant_directory_tab.dart';
import '../widgets/tenant_inspector_tab.dart';
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
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';
  String? _selectedAccreditationFilter;
  SchoolResponse? _inspectedSchool;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchools();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final tenantsList = await tenantService.listTenants();
      final list = await schoolService.listSchools();
      if (mounted) {
        setState(() {
          _tenants = tenantsList;
          _schools = list;
          _isLoading = false;
          final auth = context.read<AuthNotifier>();
          _inspectedSchool = list.firstWhere(
            (s) => s.id == auth.schoolId || s.tenantId == auth.tenantId,
            orElse: () => list.isNotEmpty ? list.first : _schools.first,
          );
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegisterTenantDialog() {
    RegisterTenantDialog.show(
      context,
      onTenantRegistered: _loadSchools,
    );
  }

  void _showRegisterSchoolDialog([String? tenantId]) {
    RegisterSchoolDialog.show(
      context,
      initialTenantId: tenantId,
      onSchoolRegistered: _loadSchools,
    );
  }

  void _showEditProfileDialog(SchoolResponse school) {
    EditTenantDialog.show(
      context,
      school: school,
      onUpdated: _loadSchools,
    );
  }

  void _showSettingsDialog(SchoolResponse school) {
    TenantSettingsDialog.show(
      context,
      school: school,
      onSaved: _loadSchools,
    );
  }

  Future<void> _toggleTenantStatus(SchoolResponse school) async {
    final newStatus = school.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    final confirm = await TenantStatusConfirmationDialog.show(
      context,
      school: school,
      newStatus: newStatus,
    );

    if (confirm == true) {
      try {
        await schoolService.updateSchoolStatus(school.tenantId, newStatus);
        await _loadSchools();
        if (mounted) {
          AppToast.showSuccess(
            context,
            'Tenant ${school.name} is now ${newStatus.toLowerCase()}.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'Failed to update status: $e');
        }
      }
    }
  }

  Future<void> _switchActiveTenant(String tenantId) async {
    final auth = context.read<AuthNotifier>();
    try {
      await auth.switchTenant(tenantId);
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Active session switched to tenant: $tenantId',
        );
        await _loadSchools();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error switching tenant: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();

    final isSuperAdmin = auth.hasRole('SUPERADMIN') ||
        auth.hasPermission('school:profile:write') ||
        auth.hasPermission('*');

    if (!isSuperAdmin) {
      return const TenantAccessRestrictedView();
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    final filteredSchools = _schools.where((s) {
      if (_selectedStatusFilter != 'ALL' &&
          s.status.toUpperCase() != _selectedStatusFilter) {
        return false;
      }
      if (_selectedAccreditationFilter != null &&
          _selectedAccreditationFilter!.isNotEmpty &&
          _selectedAccreditationFilter != 'ALL') {
        if (s.accreditationStatus != _selectedAccreditationFilter) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.tenantId.toLowerCase().contains(q) ||
            s.institutionCode.toLowerCase().contains(q) ||
            (s.governmentRegistrationNumber?.toLowerCase().contains(q) ??
                false) ||
            s.contactEmail.toLowerCase().contains(q);
      }
      return true;
    }).toList();

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
                'Tenant & School Profile Management',
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
            'Multi-tenant institution registry, accreditation oversight, and operational rules.',
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
                    icon: Icon(LucideIcons.building2, size: 16),
                    text: 'Tenants Directory'),
                Tab(
                    icon: Icon(LucideIcons.landmark, size: 16),
                    text: 'Institutional Inspector'),
                Tab(
                    icon: Icon(LucideIcons.sliders, size: 16),
                    text: 'System & Quotas'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TenantDirectoryTab(
                  allSchools: _schools,
                  filteredSchools: filteredSchools,
                  allTenants: _tenants,
                  searchQuery: _searchQuery,
                  selectedStatusFilter: _selectedStatusFilter,
                  currentTenantId: auth.tenantId,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  onStatusFilterChanged: (st) =>
                      setState(() => _selectedStatusFilter = st),
                  onRegisterTenant: _showRegisterTenantDialog,
                  onSwitchTenant: _switchActiveTenant,
                  onEditProfile: _showEditProfileDialog,
                  onSettings: _showSettingsDialog,
                  onToggleStatus: _toggleTenantStatus,
                  onAddCampus: (tenantId) =>
                      _showRegisterSchoolDialog(tenantId),
                ),
                TenantInspectorTab(
                  schools: _schools,
                  inspectedSchool: _inspectedSchool,
                  onSelectSchool: (newId) {
                    setState(() {
                      _inspectedSchool = _schools.firstWhere(
                          (s) => s.id == newId || s.tenantId == newId);
                    });
                  },
                  onEditProfile: _showEditProfileDialog,
                  onSettings: _showSettingsDialog,
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
