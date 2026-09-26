import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../state/app_state.dart';
import '../../../state/auth_notifier.dart';

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen> {
  SchoolResponse? _profile;
  bool _isLoading = true;
  String? _error;

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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await schoolService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load school profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;
    final nameCtrl = TextEditingController(text: _profile!.name);
    final addrCtrl = TextEditingController(text: _profile!.address);
    final emailCtrl = TextEditingController(text: _profile!.contactEmail);
    final phoneCtrl = TextEditingController(text: _profile!.contactPhone);
    final npsnCtrl = TextEditingController(
        text: _profile!.governmentRegistrationNumber ?? '');
    String accredStatus = _profile!.accreditationStatus ?? 'ACCREDITED_A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final c = KiteColors.of(ctx);
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allLg),
            title: Row(
              children: [
                Icon(LucideIcons.pencilLine, color: c.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Edit Institutional Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'School Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Contact Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Contact Phone'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: npsnCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Govt Reg Number (NPSN)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
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
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(
                    borderRadius: KiteRadius.allMd,
                  ),
                ),
                onPressed: () async {
                  final updated =
                      await schoolService.updateProfile(UpdateSchoolRequest(
                    name: nameCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                    contactEmail: emailCtrl.text.trim(),
                    contactPhone: phoneCtrl.text.trim(),
                    governmentRegistrationNumber:
                        npsnCtrl.text.trim().isNotEmpty
                            ? npsnCtrl.text.trim()
                            : null,
                    accreditationStatus: accredStatus,
                  ));
                  if (mounted) setState(() => _profile = updated);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsDialog() {
    if (_profile == null) return;
    final selectedDays = List<String>.from(_profile!.workingDays);
    String grading = _profile!.gradingPreference;
    String termLayout = _profile!.termLayout;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final c = KiteColors.of(ctx);
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: KiteRadius.allLg),
            title: Row(
              children: [
                Icon(LucideIcons.sliders, color: c.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Operational Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
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
                        selectedColor: c.primary.withOpacity(0.15),
                        checkmarkColor: c.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: KiteRadius.allMd,
                          side: BorderSide(
                            color: isSel ? c.primary : c.border,
                          ),
                        ),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  shape: const RoundedRectangleBorder(
                    borderRadius: KiteRadius.allMd,
                  ),
                ),
                onPressed: () async {
                  final updated = await schoolService
                      .configureSettings(ConfigureSchoolSettingsRequest(
                    workingDays: selectedDays,
                    gradingPreference: grading,
                    termLayout: termLayout,
                  ));
                  if (mounted) setState(() => _profile = updated);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save Settings'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final auth = context.watch<AuthNotifier>();
    final canEditProfile = auth.hasPermission('school:profile:write');
    final canManageSettings = auth.hasPermission('school:settings:manage');
    final isSuperAdmin = auth.hasRole('SUPERADMIN') || auth.hasPermission('*');

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circleAlert, size: 48, color: c.destructive),
            const SizedBox(height: 12),
            Text(_error!, style: t.p),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      );
    }

    final p = _profile!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = isMobile ? 14.0 : 24.0;
        final verticalPadding = isMobile ? 14.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SuperAdmin Multi-Tenant Authority Banner
              if (isSuperAdmin) ...[
                _buildSuperAdminBanner(context, isMobile),
                const SizedBox(height: 16),
              ],

              // Header Hero Card
              _buildHeaderCard(context, p, canEditProfile, isMobile),
              const SizedBox(height: 16),

              // KPI Stats Overview Bar
              _buildStatsBar(context, p, isMobile),
              const SizedBox(height: 16),

              // Responsive Cards Section
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildDetailsCard(context, p, isWide: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: _buildOperationalCard(
                        context,
                        p,
                        canManageSettings,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDetailsCard(context, p, isWide: false),
                    const SizedBox(height: 16),
                    _buildOperationalCard(
                      context,
                      p,
                      canManageSettings,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuperAdminBanner(BuildContext context, bool isMobile) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.primary.withOpacity(0.08),
          borderRadius: KiteRadius.allMd,
          border: Border.all(color: c.primary.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: c.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Platform SuperAdmin Mode',
                    style: t.small.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'You have global multi-tenant authority. Open the dedicated Tenant Console to provision and manage all institutions.',
              style: t.small.copyWith(
                color: c.mutedForeground,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: KiteRadius.allMd,
                  ),
                ),
                onPressed: () => context.read<AppState>().setTab(8),
                icon: const Icon(LucideIcons.building2, size: 14),
                label: const Text('Tenant Console',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.primary.withOpacity(0.08),
        borderRadius: KiteRadius.allMd,
        border: Border.all(color: c.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck, color: c.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Platform SuperAdmin Mode: You have global multi-tenant authority. Open the dedicated Tenant Console to provision and manage all institutions.',
              style: t.small.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: const RoundedRectangleBorder(
                borderRadius: KiteRadius.allMd,
              ),
            ),
            onPressed: () => context.read<AppState>().setTab(8),
            icon: const Icon(LucideIcons.building2, size: 14),
            label: const Text('Tenant Console', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    SchoolResponse p,
    bool canEditProfile,
    bool isMobile,
  ) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: KiteRadius.allLg,
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.primary.withOpacity(0.85),
                        c.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.landmark,
                    color: c.primaryForeground,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: t.h4.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          KiteBadge(
                            p.status,
                            tone: KiteTone.success,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.muted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.institutionCode,
                              style: t.small.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tenant ID: ${p.tenantId} • Code: ${p.institutionCode}',
              style: t.muted.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: canEditProfile ? _showEditProfileDialog : null,
                icon: Icon(
                  canEditProfile ? LucideIcons.pencil : LucideIcons.lock,
                  size: 14,
                ),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.foreground,
                  side: BorderSide(color: c.border),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: KiteRadius.allMd,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: KiteRadius.allLg,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.primary.withOpacity(0.85),
                        c.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.landmark,
                    color: c.primaryForeground,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.name,
                              style: t.h2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          KiteBadge(
                            p.status,
                            tone: KiteTone.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tenant ID: ${p.tenantId} • Code: ${p.institutionCode}',
                        style: t.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: canEditProfile ? _showEditProfileDialog : null,
            icon: Icon(
              canEditProfile ? LucideIcons.pencil : LucideIcons.lock,
              size: 15,
            ),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.foreground,
              side: BorderSide(color: c.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: const RoundedRectangleBorder(
                borderRadius: KiteRadius.allMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, SchoolResponse p, bool isMobile) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final stats = [
      _StatItem(
        icon: LucideIcons.badgeCheck,
        label: 'Govt Reg Number',
        value: p.governmentRegistrationNumber != null &&
                p.governmentRegistrationNumber!.isNotEmpty
            ? p.governmentRegistrationNumber!
            : 'Verified',
      ),
      _StatItem(
        icon: LucideIcons.award,
        label: 'Accreditation',
        value: p.accreditationStatus ?? 'Accredited A',
      ),
      _StatItem(
        icon: LucideIcons.calendarDays,
        label: 'Operating Days',
        value: '${p.workingDays.length} Days / Week',
      ),
      _StatItem(
        icon: LucideIcons.layers,
        label: 'Term Structure',
        value: p.termLayout,
      ),
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, i) => _buildStatTile(context, stats[i], c, t),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _buildStatTile(context, stats[i], c, t)),
        ],
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    _StatItem item,
    KiteColors c,
    KiteText t,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: KiteRadius.allMd,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, size: 15, color: c.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.small.copyWith(
                    color: c.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.foreground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    SchoolResponse p, {
    required bool isWide,
  }) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(LucideIcons.landmark, color: c.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Institutional Details',
                  overflow: TextOverflow.ellipsis,
                  style: t.large.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),
          _infoTile(context, LucideIcons.mapPin, 'Address', p.address,
              isWide: isWide),
          Divider(height: 20, color: c.border.withOpacity(0.4)),
          _infoTile(context, LucideIcons.mail, 'Contact Email', p.contactEmail,
              isWide: isWide),
          Divider(height: 20, color: c.border.withOpacity(0.4)),
          _infoTile(context, LucideIcons.phone, 'Contact Phone', p.contactPhone,
              isWide: isWide),
          Divider(height: 20, color: c.border.withOpacity(0.4)),
          _infoTile(
            context,
            LucideIcons.badgeCheck,
            'Govt Registration (NPSN)',
            p.governmentRegistrationNumber ?? '-',
            isWide: isWide,
          ),
          Divider(height: 20, color: c.border.withOpacity(0.4)),
          _infoTile(
            context,
            LucideIcons.award,
            'Accreditation',
            '${p.accreditationStatus ?? '-'} (${p.accreditationBody ?? ''})',
            isWide: isWide,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalCard(
    BuildContext context,
    SchoolResponse p,
    bool canManageSettings,
  ) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          Icon(LucideIcons.sliders, color: c.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Operational Rules',
                        overflow: TextOverflow.ellipsis,
                        style: t.large.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: canManageSettings ? _showSettingsDialog : null,
                icon: Icon(
                  canManageSettings ? LucideIcons.settings : LucideIcons.lock,
                  size: 14,
                ),
                label: const Text('Configure', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: c.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: c.border),

          // Working Days Section
          Text(
            'Active Working Days',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 10),
          _buildWorkingDaysStrip(context, p.workingDays),
          const SizedBox(height: 16),

          // Operational Rules Subtiles
          Text(
            'Academic Framework',
            style: t.small.copyWith(
              fontWeight: FontWeight.bold,
              color: c.foreground,
            ),
          ),
          const SizedBox(height: 10),
          _buildRuleTile(
            context,
            LucideIcons.graduationCap,
            'Curriculum & Grading',
            _formatGradingPreference(p.gradingPreference),
          ),
          const SizedBox(height: 10),
          _buildRuleTile(
            context,
            LucideIcons.calendar,
            'Academic Term Layout',
            _formatTermLayout(p.termLayout),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDaysStrip(
    BuildContext context,
    List<String> activeDays,
  ) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const totalGaps = 6 * 4;
        final itemWidth = (constraints.maxWidth - totalGaps) / 7;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _allDays.map((d) {
            final active = activeDays.contains(d);
            return Container(
              width: itemWidth.clamp(32.0, 48.0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? c.primary : c.muted.withOpacity(0.4),
                borderRadius: KiteRadius.allMd,
                border: Border.all(
                  color: active ? c.primary : c.border,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.substring(0, 3),
                    textAlign: TextAlign.center,
                    style: t.small.copyWith(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      color: active ? c.primaryForeground : c.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    active ? LucideIcons.check : LucideIcons.minus,
                    size: 11,
                    color: active
                        ? c.primaryForeground.withOpacity(0.85)
                        : c.mutedForeground.withOpacity(0.3),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRuleTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: KiteRadius.allMd,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: c.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.small.copyWith(
                    color: c.mutedForeground,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: t.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.foreground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    required bool isWide,
  }) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.08),
              borderRadius: KiteRadius.allMd,
            ),
            child: Icon(icon, size: 16, color: c.primary),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: t.small.copyWith(
                color: c.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: t.small.copyWith(
                fontWeight: FontWeight.w600,
                color: c.foreground,
              ),
            ),
          ),
        ],
      );
    }

    // Responsive Mobile/Tablet Layout: Stacked next to icon badge so long text has 100% card width
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.primary.withOpacity(0.08),
            borderRadius: KiteRadius.allMd,
          ),
          child: Icon(icon, size: 16, color: c.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.small.copyWith(
                  color: c.mutedForeground,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: t.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.foreground,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatGradingPreference(String raw) {
    switch (raw) {
      case 'DESCRIPTIVE_KURIKULUM_MERDEKA':
        return 'Kurikulum Merdeka (Capaian Pembelajaran)';
      case 'STANDARD_LETTER_GRADE':
        return 'Standard Letter Grade (A-F GPA)';
      case 'NUMERIC_100_POINT':
        return '100-Point Numeric Scale';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  String _formatTermLayout(String raw) {
    switch (raw) {
      case 'SEMESTER':
        return 'Semester (2 Terms / Year)';
      case 'TRIMESTER':
        return 'Trimester (3 Terms / Year)';
      case 'QUARTER':
        return 'Quarter (4 Terms / Year)';
      default:
        return raw;
    }
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
