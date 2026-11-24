import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/iam_service.dart';
import '../../../core/utils/app_toast.dart';

class ProfileSecurityCard extends StatefulWidget {
  final UserProfileResponse? user;
  final IamService iamService;

  const ProfileSecurityCard({
    super.key,
    required this.user,
    required this.iamService,
  });

  @override
  State<ProfileSecurityCard> createState() => _ProfileSecurityCardState();
}

class _ProfileSecurityCardState extends State<ProfileSecurityCard> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = widget.user?.id;
    if (userId == null || userId.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.iamService
          .resetPassword(userId, _newPasswordCtrl.text.trim());
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (mounted) {
        AppToast.showSuccess(context, 'Password updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update password: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                  const Icon(LucideIcons.lock,
                      color: AppColors.forestSage, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Security & Password Management',
                      style: t.large.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Divider(height: 20, color: c.border),
              const SizedBox(height: 8),

              // Current Password
              Text('Current Password',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('profile_current_password_input'),
                controller: _currentPasswordCtrl,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 16,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // New Password
              Text('New Password',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('profile_new_password_input'),
                controller: _newPasswordCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: 'Enter new password (min. 6 characters)',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 16,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'New password cannot be empty';
                  }
                  if (val.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              Text('Confirm New Password',
                  style: t.small.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('profile_confirm_password_input'),
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Re-enter new password',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 16,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (val) {
                  if (val != _newPasswordCtrl.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Update Password Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  key: const Key('profile_update_password_btn'),
                  onPressed: _isSubmitting ? null : _handleUpdatePassword,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.keyRound, size: 16),
                  label:
                      Text(_isSubmitting ? 'Updating...' : 'Update Password'),
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
              const SizedBox(height: 16),
              Divider(color: c.border),
              const SizedBox(height: 12),

              // Active Session Information
              Row(
                children: [
                  Icon(LucideIcons.shieldAlert,
                      size: 16, color: c.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Environment: ${apiClient.isMockMode ? "Mock Simulation Mode" : "Live REST API Mode"}',
                      style: t.muted.copyWith(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    key: const Key('profile_system_version_tag'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Version ${AppVersion.tag}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestSage,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
