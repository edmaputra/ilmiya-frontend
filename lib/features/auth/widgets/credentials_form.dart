import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/auth_notifier.dart';

class CredentialsForm extends StatefulWidget {
  final AuthNotifier auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const CredentialsForm({
    super.key,
    required this.auth,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<CredentialsForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 16, color: AppColors.forestSage),
              const SizedBox(width: 6),
              Text(
                'Institutional Credentials',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email / Username
          TextFormField(
            controller: widget.emailController,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              if (widget.passwordController.text.isNotEmpty &&
                  !widget.auth.isLoading) {
                widget.onSubmit();
              } else {
                FocusScope.of(context).nextFocus();
              }
            },
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Institutional Email or Username',
              hintText: 'name@ilmiya.edu',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Institutional email or username is required'
                : null,
          ),
          const SizedBox(height: 10),

          // Password
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!widget.auth.isLoading) {
                widget.onSubmit();
              }
            },
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.key_outlined, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: widget.auth.isLoading ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestSage,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: widget.auth.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login_rounded, size: 18),
            label: Text(
              widget.auth.isLoading ? 'Signing In...' : 'Sign In to Portal',
            ),
          ),
        ],
      ),
    );
  }
}
