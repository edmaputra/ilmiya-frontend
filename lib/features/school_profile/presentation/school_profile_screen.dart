import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
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
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Edit Institutional Profile',
                  style: TextStyle(fontFamily: 'serif', fontSize: 18)),
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
                const SizedBox(height: 10),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: npsnCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Govt Reg Number (NPSN)'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: accredStatus,
                  decoration:
                      const InputDecoration(labelText: 'Accreditation Status'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final updated =
                    await schoolService.updateProfile(UpdateSchoolRequest(
                  name: nameCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  contactEmail: emailCtrl.text.trim(),
                  contactPhone: phoneCtrl.text.trim(),
                  governmentRegistrationNumber: npsnCtrl.text.trim().isNotEmpty
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
        ),
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
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Operational Settings',
                  style: TextStyle(fontFamily: 'serif', fontSize: 18)),
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
                  decoration:
                      const InputDecoration(labelText: 'Academic Term Layout'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
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
        ),
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
            const Icon(LucideIcons.circleAlert,
                size: 48, color: AppColors.earthyTerra),
            const SizedBox(height: 12),
            Text(_error!, style: t.p),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      );
    }

    final p = _profile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSuperAdmin) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.forestSage.withOpacity(0.08),
                borderRadius: KiteRadius.allMd,
                border:
                    Border.all(color: AppColors.forestSage.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck,
                      color: AppColors.forestSage, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Platform SuperAdmin Mode: You have global multi-tenant authority. Open the dedicated Tenant Console to provision and manage all institutions.',
                      style: t.small.copyWith(
                        color: AppColors.forestSage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestSage,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => context.read<AppState>().setTab(8),
                    icon: const Icon(LucideIcons.building2, size: 14),
                    label: const Text('Tenant Console',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Header Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      // School icon / logo placeholder
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2D7A82),
                              Color(0xFF1E6570),
                              Color(0xFF144C57),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.landmark,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Text(
                        p.name,
                        style: t.h2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      KiteBadge(
                        p.status,
                        tone: KiteTone.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tenant ID: ${p.tenantId} • Code: ${p.institutionCode}',
                    style: t.muted,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: canEditProfile ? _showEditProfileDialog : null,
                icon: Icon(
                    canEditProfile ? LucideIcons.pencil : LucideIcons.lock,
                    size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.foreground,
                  side: BorderSide(color: c.border),
                  shape: const RoundedRectangleBorder(
                      borderRadius: KiteRadius.allMd),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: KiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.landmark,
                                  color: c.foreground, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Institutional Details',
                                  overflow: TextOverflow.ellipsis,
                                  style: t.large
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24, color: c.border),
                          _infoRow(context, LucideIcons.mapPin, 'Address',
                              p.address),
                          const SizedBox(height: 12),
                          _infoRow(context, LucideIcons.mail, 'Contact Email',
                              p.contactEmail),
                          const SizedBox(height: 12),
                          _infoRow(context, LucideIcons.phone, 'Contact Phone',
                              p.contactPhone),
                          const SizedBox(height: 12),
                          _infoRow(
                              context,
                              LucideIcons.badgeCheck,
                              'Govt Registration (NPSN)',
                              p.governmentRegistrationNumber ?? '-'),
                          const SizedBox(height: 12),
                          _infoRow(context, LucideIcons.award, 'Accreditation',
                              '${p.accreditationStatus ?? '-'} (${p.accreditationBody ?? ''})'),
                        ],
                      ),
                    ),
                  ),

                  if (isWide)
                    const SizedBox(width: 20)
                  else
                    const SizedBox(height: 20),

                  // Operational Settings Card
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: KiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.sliders,
                                        color: c.foreground, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Operational Rules',
                                        overflow: TextOverflow.ellipsis,
                                        style: t.large.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: canManageSettings
                                    ? _showSettingsDialog
                                    : null,
                                icon: Icon(
                                    canManageSettings
                                        ? LucideIcons.settings
                                        : LucideIcons.lock,
                                    size: 14),
                                label: const Text('Configure',
                                    style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                    foregroundColor: c.primary),
                              ),
                            ],
                          ),
                          Divider(height: 24, color: c.border),
                          Text('Active Working Days',
                              style: t.small.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _allDays.map((d) {
                              final active = p.workingDays.contains(d);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: active
                                      ? c.accent
                                      : c.muted.withOpacity(0.5),
                                  borderRadius: KiteRadius.allMd,
                                  border: Border.all(
                                      color: active ? c.primary : c.border),
                                ),
                                child: Text(
                                  d.substring(0, 3),
                                  style: t.small.copyWith(
                                    fontSize: 11,
                                    fontWeight: active
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: active
                                        ? c.foreground
                                        : c.mutedForeground,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('Curriculum & Grading',
                              style: t.small.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground)),
                          const SizedBox(height: 4),
                          Text(
                            p.gradingPreference.replaceAll('_', ' '),
                            style: t.small.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Academic Term Layout',
                              style: t.small.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: c.foreground)),
                          const SizedBox(height: 4),
                          Text(
                            p.termLayout,
                            style: t.small.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
