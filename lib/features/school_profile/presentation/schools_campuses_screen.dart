import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_permissions.dart';
import '../../../core/models/school.dart';
import '../../../core/models/tenant.dart';
import '../../../core/services/school_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../shared_widgets/tenant_session_required_view.dart';
import '../../../state/action_permissions.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/edit_tenant_dialog.dart';
import '../dialogs/register_foundation_dialog.dart';
import '../dialogs/register_school_dialog.dart';
import '../dialogs/tenant_settings_dialog.dart';
import '../dialogs/tenant_status_confirmation_dialog.dart';
import '../widgets/tenant_directory_tab.dart';
import '../widgets/tenant_inspector_tab.dart';

class SchoolsCampusesScreen extends StatefulWidget {
  const SchoolsCampusesScreen({super.key});

  @override
  State<SchoolsCampusesScreen> createState() => _SchoolsCampusesScreenState();
}

class _SchoolsCampusesScreenState extends State<SchoolsCampusesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TenantResponse> _tenants = [];
  List<SchoolResponse> _schools = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';
  String _selectedFoundationFilter = 'ALL';
  String? _selectedAccreditationFilter;
  SchoolResponse? _inspectedSchool;
  String? _lastObservedTenantId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final auth = context.read<AuthNotifier>();
    _selectedFoundationFilter =
        auth.tenantId.isNotEmpty ? auth.tenantId : 'ALL';
    _lastObservedTenantId = auth.tenantId;
    _loadSchools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTenant = context.read<AuthNotifier>().tenantId;
    if (_lastObservedTenantId != null &&
        _lastObservedTenantId != currentTenant &&
        currentTenant.isNotEmpty) {
      _selectedFoundationFilter = currentTenant;
      _loadSchools();
    }
    _lastObservedTenantId = currentTenant;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthNotifier>();
      final effectiveTenant =
          auth.tenantId.isNotEmpty && auth.tenantId != 'platform'
              ? auth.tenantId
              : null;
      final tenantsList = await tenantService.listTenants();
      final list = await schoolService.listSchools(
          tenantId: effectiveTenant, bypassTenantHeader: true);
      if (mounted) {
        setState(() {
          _tenants = tenantsList;
          _schools = list;
          _isLoading = false;
          _inspectedSchool = list.isNotEmpty
              ? list.firstWhere(
                  (s) => s.id == auth.schoolId || s.tenantId == auth.tenantId,
                  orElse: () => list.first,
                )
              : null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegisterSchoolDialog([String? tenantId]) {
    final effectiveTenantId = (tenantId != null && tenantId.isNotEmpty)
        ? tenantId
        : (_selectedFoundationFilter != 'ALL'
            ? _selectedFoundationFilter
            : null);
    RegisterSchoolDialog.show(
      context,
      initialTenantId: effectiveTenantId,
      onSchoolRegistered: () async {
        await _loadSchools();
        if (effectiveTenantId != null && mounted) {
          setState(() => _selectedFoundationFilter = effectiveTenantId);
        }
      },
    );
  }

  void _showRegisterFoundationDialog() {
    RegisterFoundationDialog.show(
      context,
      onFoundationRegistered: _loadSchools,
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

  Future<void> _toggleSchoolStatus(SchoolResponse school) async {
    final newStatus =
        school.status.toUpperCase() == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    final confirmed = await TenantStatusConfirmationDialog.show(
      context,
      school: school,
      newStatus: newStatus,
    );
    if (confirmed != true) return;

    try {
      await schoolService.updateSchoolStatus(school.tenantId, newStatus);
      await _loadSchools();
      if (mounted) {
        AppToast.showSuccess(
          context,
          '${school.name} is now ${newStatus.toLowerCase()}.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update campus status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();

    if (auth.isPlatformSession && auth.isSuperAdmin) {
      // Superadmin in platform session needs to select or switch to manage specific tenant entities,
      // or can view all schools with the filter
    } else if (auth.isPlatformSession) {
      return const TenantSessionRequiredView(
        sectionName: 'Schools & Campuses Management',
      );
    }

    // Every action requires its own specific permission; SUPERADMIN and
    // wildcard permissions resolve inside ActionPermissions.
    bool can(String permission) =>
        ActionPermissions.can(auth, permission, allowTenantAdmin: true);
    final canRegisterCampus = can(AppPermissions.schoolCampusCreate);
    final canRegisterFoundation = can(AppPermissions.tenantWrite);
    final canEditProfile = can(AppPermissions.schoolProfileWrite);
    final canManageSettings = can(AppPermissions.schoolSettingsManage);
    final canToggleStatus = can(AppPermissions.schoolStatusManage);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    final effectiveFoundationFilter =
        auth.tenantId.isNotEmpty && auth.tenantId != 'platform'
            ? auth.tenantId
            : _selectedFoundationFilter;

    final filteredSchools = _schools.where((s) {
      if (effectiveFoundationFilter != 'ALL' &&
          s.tenantId != effectiveFoundationFilter) {
        return false;
      }
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
                'Schools & Campuses Management',
                style: (isCompact ? t.h3 : t.h2)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              if (auth.tenantId.isNotEmpty && auth.tenantId != 'platform')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.forestSage.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TENANT: ${auth.tenantId}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestSage,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Institutional directory of schools, branch campuses, accreditation, and inspection.',
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
                  icon: Icon(LucideIcons.school, size: 16),
                  text: 'Schools & Campuses',
                ),
                Tab(
                  icon: Icon(LucideIcons.building2, size: 16),
                  text: 'Institutional Inspector',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  selectedFoundationFilter: effectiveFoundationFilter,
                  currentTenantId: auth.tenantId,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  onStatusFilterChanged: (st) =>
                      setState(() => _selectedStatusFilter = st),
                  onFoundationFilterChanged: (val) =>
                      setState(() => _selectedFoundationFilter = val ?? 'ALL'),
                  onRegisterTenant: _showRegisterFoundationDialog,
                  onSwitchTenant: (_) {},
                  onEditProfile: _showEditProfileDialog,
                  onSettings: _showSettingsDialog,
                  onToggleStatus: _toggleSchoolStatus,
                  onAddCampus: (tenantId) => _showRegisterSchoolDialog(
                      tenantId.isEmpty ? null : tenantId),
                  canRegisterCampus: canRegisterCampus,
                  canRegisterFoundation: canRegisterFoundation,
                  canEditProfile: canEditProfile,
                  canManageSettings: canManageSettings,
                  canToggleStatus: canToggleStatus,
                ),
                TenantInspectorTab(
                  schools:
                      filteredSchools.isNotEmpty ? filteredSchools : _schools,
                  inspectedSchool: _inspectedSchool,
                  onSelectSchool: (newId) {
                    setState(() {
                      _inspectedSchool = _schools.firstWhere(
                          (s) => s.id == newId || s.tenantId == newId);
                    });
                  },
                  onEditProfile: _showEditProfileDialog,
                  onSettings: _showSettingsDialog,
                  canEditProfile: canEditProfile,
                  canManageSettings: canManageSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
