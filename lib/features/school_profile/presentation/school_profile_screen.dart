import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
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
    final npsnCtrl = TextEditingController(text: _profile!.governmentRegistrationNumber ?? '');
    String accredStatus = _profile!.accreditationStatus ?? 'ACCREDITED_A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Edit Institutional Profile', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
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
                  decoration: const InputDecoration(labelText: 'Govt Reg Number (NPSN)'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: accredStatus,
                  decoration: const InputDecoration(labelText: 'Accreditation Status'),
                  items: const [
                    DropdownMenuItem(value: 'ACCREDITED_A', child: Text('Accredited A (Unggul)')),
                    DropdownMenuItem(value: 'ACCREDITED_B', child: Text('Accredited B (Baik Sekali)')),
                    DropdownMenuItem(value: 'ACCREDITED_C', child: Text('Accredited C (Baik)')),
                    DropdownMenuItem(value: 'UNACCREDITED', child: Text('Unaccredited')),
                  ],
                  onChanged: (v) => setDlgState(() => accredStatus = v ?? accredStatus),
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
                final updated = await schoolService.updateProfile(UpdateSchoolRequest(
                  name: nameCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  contactEmail: emailCtrl.text.trim(),
                  contactPhone: phoneCtrl.text.trim(),
                  governmentRegistrationNumber: npsnCtrl.text.trim().isNotEmpty ? npsnCtrl.text.trim() : null,
                  accreditationStatus: accredStatus,
                ));
                setState(() => _profile = updated);
                if (mounted) Navigator.of(ctx).pop();
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
    List<String> selectedDays = List.from(_profile!.workingDays);
    String grading = _profile!.gradingPreference;
    String termLayout = _profile!.termLayout;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text('Operational Settings', style: TextStyle(fontFamily: 'serif', fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('School Working Days:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                            if (selectedDays.length > 1) selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: grading,
                  decoration: const InputDecoration(labelText: 'Grading Framework'),
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
                  decoration: const InputDecoration(labelText: 'Academic Term Layout'),
                  items: const [
                    DropdownMenuItem(value: 'SEMESTER', child: Text('Semester (2 Terms / Year)')),
                    DropdownMenuItem(value: 'TRIMESTER', child: Text('Trimester (3 Terms / Year)')),
                    DropdownMenuItem(value: 'QUARTER', child: Text('Quarter (4 Terms / Year)')),
                  ],
                  onChanged: (v) => setDlgState(() => termLayout = v ?? termLayout),
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
                final updated = await schoolService.configureSettings(ConfigureSchoolSettingsRequest(
                  workingDays: selectedDays,
                  gradingPreference: grading,
                  termLayout: termLayout,
                ));
                setState(() => _profile = updated);
                if (mounted) Navigator.of(ctx).pop();
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
    final auth = context.watch<AuthNotifier>();
    final canEditProfile = auth.hasPermission('school:profile:write');
    final canManageSettings = auth.hasPermission('school:settings:manage');

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.forestSage));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.earthyTerra),
            const SizedBox(height: 12),
            Text(_error!),
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
                    spacing: 8,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF7EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.status,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF03543F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tenant ID: ${p.tenantId} • Code: ${p.institutionCode}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: canEditProfile ? _showEditProfileDialog : null,
                icon: Icon(canEditProfile ? Icons.edit : Icons.lock_outline, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestSage,
                  side: const BorderSide(color: AppColors.borderMedium),
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
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_outlined, color: AppColors.forestSage, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Institutional Details',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _infoRow(Icons.pin_drop_outlined, 'Address', p.address),
                          const SizedBox(height: 12),
                          _infoRow(Icons.email_outlined, 'Contact Email', p.contactEmail),
                          const SizedBox(height: 12),
                          _infoRow(Icons.phone_outlined, 'Contact Phone', p.contactPhone),
                          const SizedBox(height: 12),
                          _infoRow(Icons.verified_outlined, 'Govt Registration (NPSN)', p.governmentRegistrationNumber ?? '-'),
                          const SizedBox(height: 12),
                          _infoRow(Icons.workspace_premium_outlined, 'Accreditation', '${p.accreditationStatus ?? '-'} (${p.accreditationBody ?? ''})'),
                        ],
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Operational Settings Card
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.tune_rounded, color: AppColors.forestSage, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Operational Rules',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: canManageSettings ? _showSettingsDialog : null,
                                icon: Icon(canManageSettings ? Icons.settings : Icons.lock_outline, size: 14),
                                label: const Text('Configure', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text('Active Working Days', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _allDays.map((d) {
                              final active = p.workingDays.contains(d);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: active ? AppColors.warmSand : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: active ? AppColors.forestSage : AppColors.borderLight),
                                ),
                                child: Text(
                                  d.substring(0, 3),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                    color: active ? AppColors.forestSage : AppColors.textMuted,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text('Curriculum & Grading', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            p.gradingPreference.replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 12, color: AppColors.forestSage, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Text('Academic Term Layout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            p.termLayout,
                            style: const TextStyle(fontSize: 12, color: AppColors.forestSage, fontWeight: FontWeight.w600),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
