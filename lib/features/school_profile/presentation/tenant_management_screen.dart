import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../state/auth_notifier.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<SchoolResponse> _schools = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';
  String? _selectedAccreditationFilter;
  SchoolResponse? _inspectedSchool;

  final List<String> _allDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

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
      final list = await schoolService.listSchools();
      if (mounted) {
        setState(() {
          _schools = list;
          _isLoading = false;
          final auth = context.read<AuthNotifier>();
          _inspectedSchool = list.firstWhere(
            (s) => s.tenantId == auth.tenantId,
            orElse: () => list.isNotEmpty ? list.first : _schools.first,
          );
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegisterTenantDialog() {
    final tenantIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final npsnCtrl = TextEditingController();
    String accredStatus = 'ACCREDITED_A';
    String grading = 'STANDARD_LETTER_GRADE';
    String termLayout = 'SEMESTER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(LucideIcons.building2, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text(
                'Register School Tenant',
                style: TextStyle(fontFamily: 'serif', fontSize: 18),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provision a new institutional partition with isolated databases, academic calendar, and IAM scope tree.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tenantIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tenant ID *',
                            hintText: 'e.g. tenant-crest-006',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Institution Code *',
                            hintText: 'e.g. CREST-006',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'School / Institution Name *',
                      hintText: 'e.g. Crescent International Academy',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Campus Address *',
                      hintText: '100 Campus Way, City, State',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contact Email *',
                            hintText: 'admin@crescent.edu',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contact Phone',
                            hintText: '+1 555 0199',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: npsnCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Govt Reg Number (NPSN)',
                            hintText: 'NPSN-50119283',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: accredStatus,
                          decoration:
                              const InputDecoration(labelText: 'Accreditation'),
                          items: const [
                            DropdownMenuItem(
                                value: 'ACCREDITED_A',
                                child: Text('Accredited A')),
                            DropdownMenuItem(
                                value: 'ACCREDITED_B',
                                child: Text('Accredited B')),
                            DropdownMenuItem(
                                value: 'ACCREDITED_C',
                                child: Text('Accredited C')),
                            DropdownMenuItem(
                                value: 'UNACCREDITED',
                                child: Text('Unaccredited')),
                          ],
                          onChanged: (v) => setDlgState(
                              () => accredStatus = v ?? accredStatus),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: grading,
                          decoration: const InputDecoration(
                              labelText: 'Grading Framework'),
                          items: const [
                            DropdownMenuItem(
                              value: 'STANDARD_LETTER_GRADE',
                              child: Text('Standard Letter (GPA)'),
                            ),
                            DropdownMenuItem(
                              value: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
                              child: Text('Kurikulum Merdeka'),
                            ),
                            DropdownMenuItem(
                              value: 'NUMERIC_100_POINT',
                              child: Text('100-Point Numeric'),
                            ),
                          ],
                          onChanged: (v) =>
                              setDlgState(() => grading = v ?? grading),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: termLayout,
                          decoration:
                              const InputDecoration(labelText: 'Term Layout'),
                          items: const [
                            DropdownMenuItem(
                                value: 'SEMESTER', child: Text('Semester')),
                            DropdownMenuItem(
                                value: 'TRIMESTER', child: Text('Trimester')),
                            DropdownMenuItem(
                                value: 'QUARTER', child: Text('Quarter')),
                          ],
                          onChanged: (v) =>
                              setDlgState(() => termLayout = v ?? termLayout),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final tId = tenantIdCtrl.text.trim();
                final name = nameCtrl.text.trim();
                final code = codeCtrl.text.trim();
                final addr = addrCtrl.text.trim();
                final email = emailCtrl.text.trim();

                if (tId.isEmpty || name.isEmpty || code.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please complete Tenant ID, Name, and Institution Code.')),
                  );
                  return;
                }

                await schoolService.registerSchool(RegisterSchoolRequest(
                  tenantId: tId,
                  name: name,
                  institutionCode: code,
                  address: addr.isNotEmpty ? addr : 'Campus Address',
                  contactEmail: email.isNotEmpty ? email : 'admin@$tId.edu',
                  contactPhone: phoneCtrl.text.trim().isNotEmpty
                      ? phoneCtrl.text.trim()
                      : '+1 555 0100',
                ));

                if (ctx.mounted) Navigator.of(ctx).pop();
                await _loadSchools();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'School tenant "$name" successfully registered!')),
                  );
                }
              },
              child: const Text('Register Tenant'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(SchoolResponse school) {
    final nameCtrl = TextEditingController(text: school.name);
    final addrCtrl = TextEditingController(text: school.address);
    final emailCtrl = TextEditingController(text: school.contactEmail);
    final phoneCtrl = TextEditingController(text: school.contactPhone);
    final npsnCtrl =
        TextEditingController(text: school.governmentRegistrationNumber ?? '');
    String accredStatus = school.accreditationStatus ?? 'ACCREDITED_A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.forestSage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit Tenant: ${school.institutionCode}',
                  style: const TextStyle(fontFamily: 'serif', fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'School Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Contact Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Contact Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: npsnCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Govt Reg Number (NPSN)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: accredStatus,
                    decoration: const InputDecoration(
                        labelText: 'Accreditation Status'),
                    items: const [
                      DropdownMenuItem(
                          value: 'ACCREDITED_A',
                          child: Text('Accredited A (Unggul)')),
                      DropdownMenuItem(
                          value: 'ACCREDITED_B',
                          child: Text('Accredited B (Baik Sekali)')),
                      DropdownMenuItem(
                          value: 'ACCREDITED_C',
                          child: Text('Accredited C (Baik)')),
                      DropdownMenuItem(
                          value: 'UNACCREDITED', child: Text('Unaccredited')),
                    ],
                    onChanged: (v) =>
                        setDlgState(() => accredStatus = v ?? accredStatus),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await schoolService.updateProfile(
                  UpdateSchoolRequest(
                    name: nameCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                    contactEmail: emailCtrl.text.trim(),
                    contactPhone: phoneCtrl.text.trim(),
                    governmentRegistrationNumber:
                        npsnCtrl.text.trim().isNotEmpty
                            ? npsnCtrl.text.trim()
                            : null,
                    accreditationStatus: accredStatus,
                  ),
                  tenantId: school.tenantId,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                await _loadSchools();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tenant profile successfully updated.')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(SchoolResponse school) {
    final selectedDays = List<String>.from(school.workingDays);
    String grading = school.gradingPreference;
    String termLayout = school.termLayout;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.forestSage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Operational Rules: ${school.name}',
                  style: const TextStyle(fontFamily: 'serif', fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('School Working Days:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allDays.map((day) {
                      final isSel = selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSel,
                        selectedColor: AppColors.warmSand,
                        checkmarkColor: AppColors.forestSage,
                        onSelected: (val) {
                          setDlgState(() {
                            if (val) {
                              selectedDays.add(day);
                            } else {
                              if (selectedDays.length > 1) {
                                selectedDays.remove(day);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: grading,
                    decoration:
                        const InputDecoration(labelText: 'Grading Framework'),
                    items: const [
                      DropdownMenuItem(
                        value: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
                        child: Text('Kurikulum Merdeka (Capaian Pembelajaran)'),
                      ),
                      DropdownMenuItem(
                        value: 'STANDARD_LETTER_GRADE',
                        child: Text('Standard Letter Grade (A-F GPA)'),
                      ),
                      DropdownMenuItem(
                        value: 'NUMERIC_100_POINT',
                        child: Text('100-Point Numeric Scale'),
                      ),
                    ],
                    onChanged: (v) => setDlgState(() => grading = v ?? grading),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: termLayout,
                    decoration: const InputDecoration(
                        labelText: 'Academic Term Layout'),
                    items: const [
                      DropdownMenuItem(
                          value: 'SEMESTER',
                          child: Text('Semester (2 Terms / Year)')),
                      DropdownMenuItem(
                          value: 'TRIMESTER',
                          child: Text('Trimester (3 Terms / Year)')),
                      DropdownMenuItem(
                          value: 'QUARTER',
                          child: Text('Quarter (4 Terms / Year)')),
                    ],
                    onChanged: (v) =>
                        setDlgState(() => termLayout = v ?? termLayout),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await schoolService.configureSettings(
                  ConfigureSchoolSettingsRequest(
                    workingDays: selectedDays,
                    gradingPreference: grading,
                    termLayout: termLayout,
                  ),
                  tenantId: school.tenantId,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                await _loadSchools();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Operational rules successfully saved.')),
                  );
                }
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTenantStatus(SchoolResponse school) async {
    final newStatus = school.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    final actionName = newStatus == 'ACTIVE' ? 'activate' : 'suspend';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              newStatus == 'ACTIVE'
                  ? LucideIcons.checkCircle2
                  : LucideIcons.alertTriangle,
              color: newStatus == 'ACTIVE'
                  ? AppColors.forestSage
                  : AppColors.earthyTerra,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Confirm Tenant Status Change',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to $actionName institutional tenant "${school.name}" (${school.tenantId})?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: newStatus == 'ACTIVE'
                  ? AppColors.forestSage
                  : AppColors.earthyTerra,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(newStatus == 'ACTIVE' ? 'Activate' : 'Suspend'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await schoolService.updateSchoolStatus(school.tenantId, newStatus);
        await _loadSchools();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Tenant ${school.name} is now ${newStatus.toLowerCase()}.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: $e')),
          );
        }
      }
    }
  }

  Future<void> _switchActiveTenant(String tenantId) async {
    final auth = context.read<AuthNotifier>();
    try {
      await auth.switchTenant(tenantId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Active session switched to tenant: $tenantId'),
          ),
        );
        await _loadSchools();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching tenant: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();

    // RBAC Security Check
    final isSuperAdmin = auth.hasRole('SUPERADMIN') ||
        auth.hasPermission('school:profile:write') ||
        auth.hasPermission('*');

    if (!isSuperAdmin) {
      return _buildAccessRestrictedView(context);
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
                // Tab 1: Directory
                _buildDirectoryTab(context, filteredSchools, auth),

                // Tab 2: Inspector
                _buildInspectorTab(context, auth),

                // Tab 3: System Quotas
                _buildQuotasTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRestrictedView(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.read<AuthNotifier>();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.earthyTerra.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(LucideIcons.shieldAlert,
                    color: AppColors.earthyTerra, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SuperAdmin Access Required',
              style: t.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The Tenant & School Profile Management console is restricted to Platform SuperAdmins with unrestricted multi-tenant authority.',
              textAlign: TextAlign.center,
              style: t.muted,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () => auth.loginAsPersona(DemoPersonaKey.superadmin),
              icon: const Icon(LucideIcons.userCheck, size: 16),
              label: const Text('Switch to Platform SuperAdmin Persona'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTab(
      BuildContext context, List<SchoolResponse> schools, AuthNotifier auth) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final totalCount = _schools.length;
    final activeCount = _schools.where((s) => s.status == 'ACTIVE').length;
    final pendingCount = _schools.where((s) => s.status == 'PENDING').length;
    final suspendedCount =
        _schools.where((s) => s.status == 'SUSPENDED').length;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardPadding = screenWidth < 600 ? 12.0 : 16.0;

    return KiteCard(
      padding: EdgeInsets.all(cardPadding),
      child: ListView(
        children: [
          // Metric Summary Row
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final pill1 = _metricPill(context, 'TOTAL TENANTS', '$totalCount',
                  LucideIcons.building2);
              final pill2 = _metricPill(context, 'ACTIVE SCHOOLS',
                  '$activeCount', LucideIcons.checkCircle2,
                  color: AppColors.forestSage);
              final pill3 = _metricPill(context, 'PENDING ONBOARDING',
                  '$pendingCount', LucideIcons.clock,
                  color: Colors.amber.shade700);
              final pill4 = _metricPill(
                  context, 'SUSPENDED', '$suspendedCount', LucideIcons.ban,
                  color: AppColors.earthyTerra);

              if (w >= 760) {
                return Row(
                  children: [
                    Expanded(child: pill1),
                    const SizedBox(width: 12),
                    Expanded(child: pill2),
                    const SizedBox(width: 12),
                    Expanded(child: pill3),
                    const SizedBox(width: 12),
                    Expanded(child: pill4),
                  ],
                );
              } else if (w >= 400) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: pill1),
                        const SizedBox(width: 12),
                        Expanded(child: pill2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: pill3),
                        const SizedBox(width: 12),
                        Expanded(child: pill4),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    pill1,
                    const SizedBox(height: 8),
                    pill2,
                    const SizedBox(height: 8),
                    pill3,
                    const SizedBox(height: 8),
                    pill4,
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 16),

          // Search and Filters Bar
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final searchField = TextField(
                decoration: InputDecoration(
                  hintText:
                      'Search by school name, tenant ID, code, or NPSN...',
                  prefixIcon: Icon(LucideIcons.search,
                      size: 16, color: c.mutedForeground),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: KiteRadius.allMd,
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              );

              final filtersAndAction = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...['ALL', 'ACTIVE', 'PENDING', 'SUSPENDED'].map((st) {
                    final isSel = _selectedStatusFilter == st;
                    return ChoiceChip(
                      label: Text(st, style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      selectedColor: AppColors.warmSand,
                      onSelected: (val) {
                        if (val) setState(() => _selectedStatusFilter = st);
                      },
                    );
                  }),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestSage,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: _showRegisterTenantDialog,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Register School'),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    filtersAndAction,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  filtersAndAction,
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Schools List
          if (schools.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.building,
                        size: 40, color: c.mutedForeground),
                    const SizedBox(height: 8),
                    Text('No school tenants matched the criteria.', style: t.p),
                  ],
                ),
              ),
            )
          else
            ...schools.map((s) {
              final isCurrentTenant = s.tenantId == auth.tenantId;

              KiteTone statusTone = KiteTone.neutral;
              if (s.status == 'ACTIVE') statusTone = KiteTone.success;
              if (s.status == 'SUSPENDED') statusTone = KiteTone.danger;
              if (s.status == 'PENDING') statusTone = KiteTone.warning;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LayoutBuilder(
                  builder: (ctx, itemConstraints) {
                    final isCompact = itemConstraints.maxWidth < 650;

                    final avatar = Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.forestSage.withOpacity(0.12),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.landmark,
                            size: 20, color: AppColors.forestSage),
                      ),
                    );

                    final nameAndBadges = Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          s.name,
                          style: t.small.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        KiteBadge(s.status, tone: statusTone),
                        if (isCurrentTenant)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.forestSage.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE SESSION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestSage,
                              ),
                            ),
                          ),
                      ],
                    );

                    final metadataWrap = Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text('Tenant: ${s.tenantId}',
                            style: t.muted.copyWith(fontSize: 11)),
                        Text('Code: ${s.institutionCode}',
                            style: t.muted.copyWith(fontSize: 11)),
                        if (s.governmentRegistrationNumber != null)
                          Text('NPSN: ${s.governmentRegistrationNumber}',
                              style: t.muted.copyWith(fontSize: 11)),
                        Text('Accreditation: ${s.accreditationStatus ?? '-'}',
                            style: t.muted.copyWith(fontSize: 11)),
                      ],
                    );

                    final contactInfo = Text(
                      '${s.address} • ${s.contactEmail} • ${s.contactPhone}',
                      style: t.muted.copyWith(fontSize: 11),
                    );

                    final actionButtons = Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (!isCurrentTenant)
                          OutlinedButton.icon(
                            onPressed: () => _switchActiveTenant(s.tenantId),
                            icon: const Icon(LucideIcons.arrowRightLeft,
                                size: 13),
                            label: const Text('Switch',
                                style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              foregroundColor: AppColors.forestSage,
                            ),
                          ),
                        IconButton(
                          iconSize: 16,
                          tooltip: 'Edit Profile',
                          icon: const Icon(LucideIcons.pencil),
                          onPressed: () => _showEditProfileDialog(s),
                        ),
                        IconButton(
                          iconSize: 16,
                          tooltip: 'Operational Settings',
                          icon: const Icon(LucideIcons.settings),
                          onPressed: () => _showSettingsDialog(s),
                        ),
                        IconButton(
                          iconSize: 16,
                          tooltip: s.status == 'ACTIVE'
                              ? 'Suspend Tenant'
                              : 'Activate Tenant',
                          icon: Icon(
                            s.status == 'ACTIVE'
                                ? LucideIcons.ban
                                : LucideIcons.checkCircle,
                            color: s.status == 'ACTIVE'
                                ? AppColors.earthyTerra
                                : AppColors.forestSage,
                          ),
                          onPressed: () => _toggleTenantStatus(s),
                        ),
                      ],
                    );

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentTenant
                            ? AppColors.forestSage.withOpacity(0.04)
                            : c.card,
                        borderRadius: KiteRadius.allMd,
                        border: Border.all(
                          color: isCurrentTenant
                              ? AppColors.forestSage.withOpacity(0.4)
                              : c.border,
                        ),
                      ),
                      child: isCompact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    avatar,
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          nameAndBadges,
                                          const SizedBox(height: 4),
                                          metadataWrap,
                                          const SizedBox(height: 4),
                                          contactInfo,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: actionButtons,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                avatar,
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      nameAndBadges,
                                      const SizedBox(height: 4),
                                      metadataWrap,
                                      const SizedBox(height: 4),
                                      contactInfo,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                actionButtons,
                              ],
                            ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _metricPill(
      BuildContext context, String label, String value, IconData icon,
      {Color? color}) {
    final c = KiteColors.of(context);
    final themeColor = color ?? c.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: themeColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: c.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorTab(BuildContext context, AuthNotifier auth) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final inspected =
        _inspectedSchool ?? (_schools.isNotEmpty ? _schools.first : null);

    if (inspected == null) {
      return Center(
          child: Text('No tenant available for inspection.', style: t.p));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tenant Selector Header
          LayoutBuilder(
            builder: (ctx, selectorConstraints) {
              final isCompact = selectorConstraints.maxWidth < 600;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: KiteRadius.allMd,
                  border: Border.all(color: c.border),
                ),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.searchCode,
                                  size: 18, color: AppColors.forestSage),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Select Tenant to Inspect:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: inspected.tenantId,
                                    isExpanded: true,
                                    items: _schools
                                        .map((s) => DropdownMenuItem(
                                              value: s.tenantId,
                                              child: Text(
                                                  '${s.name} (${s.tenantId})',
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (newId) {
                                      if (newId != null) {
                                        setState(() {
                                          _inspectedSchool =
                                              _schools.firstWhere(
                                                  (s) => s.tenantId == newId);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showEditProfileDialog(inspected),
                                icon: const Icon(LucideIcons.pencil, size: 14),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(LucideIcons.searchCode,
                              size: 18, color: AppColors.forestSage),
                          const SizedBox(width: 10),
                          const Text(
                            'Select Tenant to Inspect:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: inspected.tenantId,
                                isExpanded: true,
                                items: _schools
                                    .map((s) => DropdownMenuItem(
                                          value: s.tenantId,
                                          child: Text(
                                              '${s.name} (${s.tenantId} • ${s.institutionCode})'),
                                        ))
                                    .toList(),
                                onChanged: (newId) {
                                  if (newId != null) {
                                    setState(() {
                                      _inspectedSchool = _schools.firstWhere(
                                          (s) => s.tenantId == newId);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showEditProfileDialog(inspected),
                            icon: const Icon(LucideIcons.pencil, size: 14),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final leftCard = KiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.landmark,
                            color: AppColors.forestSage, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Legal & Institutional Identity',
                            style:
                                t.large.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: c.border),
                    _infoRow(context, LucideIcons.fingerprint, 'Tenant ID',
                        inspected.tenantId),
                    const SizedBox(height: 10),
                    _infoRow(context, LucideIcons.barcode, 'Institution Code',
                        inspected.institutionCode),
                    const SizedBox(height: 10),
                    _infoRow(
                        context,
                        LucideIcons.badgeCheck,
                        'Govt Registration (NPSN)',
                        inspected.governmentRegistrationNumber ?? '-'),
                    const SizedBox(height: 10),
                    _infoRow(context, LucideIcons.award, 'Accreditation',
                        '${inspected.accreditationStatus ?? '-'} (${inspected.accreditationBody ?? ''})'),
                    const SizedBox(height: 10),
                    _infoRow(
                        context,
                        LucideIcons.calendarCheck,
                        'Accreditation Valid Until',
                        inspected.accreditationValidUntil ?? '-'),
                    const SizedBox(height: 10),
                    _infoRow(context, LucideIcons.mapPin, 'Campus Address',
                        inspected.address),
                    const SizedBox(height: 10),
                    _infoRow(context, LucideIcons.mail, 'Contact Email',
                        inspected.contactEmail),
                    const SizedBox(height: 10),
                    _infoRow(context, LucideIcons.phone, 'Contact Phone',
                        inspected.contactPhone),
                  ],
                ),
              );

              final rightCard = KiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sliders,
                            color: AppColors.forestSage, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Operational Policies',
                            style:
                                t.large.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _showSettingsDialog(inspected),
                          icon: const Icon(LucideIcons.settings, size: 13),
                          label: const Text('Configure',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: c.border),
                    Text('Working Days',
                        style: t.small.copyWith(
                            fontWeight: FontWeight.bold, color: c.foreground)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _allDays.map((d) {
                        final active = inspected.workingDays.contains(d);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: active ? c.accent : c.muted.withOpacity(0.5),
                            borderRadius: KiteRadius.allMd,
                            border: Border.all(
                                color: active ? c.primary : c.border),
                          ),
                          child: Text(
                            d.substring(0, 3),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  active ? FontWeight.bold : FontWeight.normal,
                              color: active ? c.foreground : c.mutedForeground,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Grading Preference',
                        style: t.small.copyWith(
                            fontWeight: FontWeight.bold, color: c.foreground)),
                    const SizedBox(height: 4),
                    Text(
                      inspected.gradingPreference.replaceAll('_', ' '),
                      style: t.small.copyWith(
                          color: c.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    Text('Academic Term Layout',
                        style: t.small.copyWith(
                            fontWeight: FontWeight.bold, color: c.foreground)),
                    const SizedBox(height: 4),
                    Text(
                      inspected.termLayout,
                      style: t.small.copyWith(
                          color: c.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    Text('Tenant Status',
                        style: t.small.copyWith(
                            fontWeight: FontWeight.bold, color: c.foreground)),
                    const SizedBox(height: 4),
                    KiteBadge(
                      inspected.status,
                      tone: inspected.status == 'ACTIVE'
                          ? KiteTone.success
                          : KiteTone.danger,
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: leftCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: rightCard),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  leftCard,
                  const SizedBox(height: 16),
                  rightCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuotasTab(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final governanceCard = KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shieldCheck,
                  size: 20, color: AppColors.forestSage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Multi-Tenant Platform Governance & Quotas',
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Platform-level default resource quotas, storage thresholds, and cross-tenant data isolation rules.',
            style: t.muted,
          ),
          Divider(height: 24, color: c.border),
          _quotaRow(
              context, 'Max Active Student Accounts', '1,000 / Tenant', 0.65),
          const SizedBox(height: 16),
          _quotaRow(
              context, 'Max Faculty & Staff Accounts', '150 / Tenant', 0.42),
          const SizedBox(height: 16),
          _quotaRow(context, 'Cloud Storage Volume', '50 GB / Tenant', 0.28),
          const SizedBox(height: 16),
          _quotaRow(context, 'Monthly REST API Calls', '500,000 reqs', 0.19),
        ],
      ),
    );

    final securityCard = KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.lock,
                  size: 18, color: AppColors.forestSage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data Isolation & Security Policies',
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          _policyTile(
            context,
            'Row-Level Tenant Isolation',
            'Every SQL and storage query enforces strict X-Tenant-ID isolation preventing cross-school leakage.',
            true,
          ),
          const SizedBox(height: 10),
          _policyTile(
            context,
            'End-to-End Chat Encryption (E2EE)',
            'Direct messages between teachers and parents are cryptographically signed and encrypted.',
            true,
          ),
          const SizedBox(height: 10),
          _policyTile(
            context,
            'Multi-Campus Hierarchical Scopes',
            'Allows enterprise institutions to establish subsidiary branches (SMP/SMA) under one parent tenant.',
            true,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return SingleChildScrollView(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: governanceCard),
                    const SizedBox(width: 16),
                    Expanded(child: securityCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    governanceCard,
                    const SizedBox(height: 16),
                    securityCard,
                  ],
                ),
        );
      },
    );
  }

  Widget _quotaRow(
      BuildContext context, String title, String limit, double progress) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: t.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(limit, style: t.muted.copyWith(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: c.muted,
          color: AppColors.forestSage,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _policyTile(
      BuildContext context, String title, String subtitle, bool isEnabled) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isEnabled ? LucideIcons.checkCircle2 : LucideIcons.circle,
          size: 16,
          color: isEnabled ? AppColors.forestSage : c.mutedForeground,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: t.muted.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.mutedForeground),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: Text(label, style: t.small.copyWith(color: c.mutedForeground)),
        ),
        Expanded(
          child: Text(
            value,
            style: t.small
                .copyWith(fontWeight: FontWeight.w600, color: c.foreground),
          ),
        ),
      ],
    );
  }
}
