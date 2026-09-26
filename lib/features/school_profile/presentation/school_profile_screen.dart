import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/school.dart';
import '../../../core/services/school_service.dart';
import '../../../state/auth_notifier.dart';
import '../dialogs/edit_institutional_profile_dialog.dart';
import '../dialogs/operational_settings_dialog.dart';
import '../widgets/school_institutional_details_card.dart';
import '../widgets/school_operational_rules_card.dart';
import '../widgets/school_superadmin_banner.dart';

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen> {
  SchoolResponse? _profile;
  bool _isLoading = true;
  String? _error;

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
    EditInstitutionalProfileDialog.show(
      context,
      profile: _profile!,
      onProfileUpdated: (updated) {
        setState(() => _profile = updated);
      },
    );
  }

  void _showSettingsDialog() {
    if (_profile == null) return;
    OperationalSettingsDialog.show(
      context,
      profile: _profile!,
      onSettingsUpdated: (updated) {
        setState(() => _profile = updated);
      },
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
          mainAxisSize: MainAxisSize.min,
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
            const SchoolSuperadminBanner(),
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
                        style: t.h2.copyWith(fontWeight: FontWeight.bold),
                      ),
                      KiteBadge(p.status, tone: KiteTone.success),
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
                  size: 16,
                ),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.foreground,
                  side: BorderSide(color: c.border),
                  shape: const RoundedRectangleBorder(
                    borderRadius: KiteRadius.allMd,
                  ),
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
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: SchoolInstitutionalDetailsCard(profile: p),
                  ),
                  if (isWide)
                    const SizedBox(width: 20)
                  else
                    const SizedBox(height: 20),
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: SchoolOperationalRulesCard(
                      profile: p,
                      canManageSettings: canManageSettings,
                      onConfigure: _showSettingsDialog,
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
}
