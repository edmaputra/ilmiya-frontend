import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../state/auth_notifier.dart';

class ProfileAccountDetailsCard extends StatefulWidget {
  final UserProfileResponse? user;
  final AuthNotifier auth;
  final IamService iamService;
  final VoidCallback onProfileUpdated;

  const ProfileAccountDetailsCard({
    super.key,
    required this.user,
    required this.auth,
    required this.iamService,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileAccountDetailsCard> createState() =>
      _ProfileAccountDetailsCardState();
}

class _ProfileAccountDetailsCardState extends State<ProfileAccountDetailsCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileAccountDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.fullName != widget.user?.fullName) {
      _nameCtrl.text = widget.user?.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = widget.user?.id;
    if (userId == null || userId.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await widget.iamService.updateUser(userId, _nameCtrl.text.trim());
      await widget.auth.refreshProfile();
      widget.onProfileUpdated();
      if (mounted) {
        AppToast.showSuccess(context, 'Account details updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update details: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.userCheck,
                      color: AppColors.forestSage, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Personal Information & Self-Management',
                      style: t.large.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Divider(height: 20, color: c.border),
              const SizedBox(height: 8),

              // Full Name field
              Text('Full Name',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('profile_fullname_input'),
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Full name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email field (read-only)
              Text('Email Address',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.mail, size: 16, color: c.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.user?.email ?? 'No email associated',
                        style: t.small.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // User Identifier (read-only with copy)
              Text('Account User ID',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.fingerprint,
                        size: 16, color: c.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.user?.id ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.copy, size: 14),
                      tooltip: 'Copy User ID',
                      onPressed: () {
                        if (widget.user?.id != null) {
                          Clipboard.setData(
                              ClipboardData(text: widget.user!.id));
                          AppToast.showSuccess(
                              context, 'User ID copied to clipboard.');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Save Changes Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  key: const Key('profile_save_changes_btn'),
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.check, size: 16),
                  label: Text(_isSaving ? 'Saving...' : 'Save Profile Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestSage,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
