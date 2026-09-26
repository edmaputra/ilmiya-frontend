import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';
import '../../../state/auth_notifier.dart';

class CredentialsForm extends StatefulWidget {
  final AuthNotifier auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController tenantController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const CredentialsForm({
    super.key,
    required this.auth,
    required this.emailController,
    required this.passwordController,
    required this.tenantController,
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
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppColors.forestSage),
              SizedBox(width: 6),
              Text(
                'Direct Credentials',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: widget.emailController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Institutional Email',
              hintText: 'name@ilmiya.edu',
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Email is required' : null,
          ),
          const SizedBox(height: 10),

          // Password
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
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
          const SizedBox(height: 10),

          // Tenant ID
          TextFormField(
            controller: widget.tenantController,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: 'Tenant ID',
              prefixIcon: const Icon(Icons.business_outlined, size: 18),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 12),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  apiClient.toggleMockMode();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: apiClient.isMockMode
                      ? const Color(0xFFF3E8FF)
                      : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: apiClient.isMockMode
                        ? const Color(0xFFD8B4FE)
                        : const Color(0xFFA8DAB5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: apiClient.isMockMode
                            ? const Color(0xFF9333EA)
                            : const Color(0xFF137333),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      apiClient.isMockMode
                          ? 'Mode: Mock Simulation'
                          : 'Mode: Live REST API',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: apiClient.isMockMode
                            ? const Color(0xFF7E22CE)
                            : const Color(0xFF137333),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.sync_rounded,
                      size: 12,
                      color: apiClient.isMockMode
                          ? const Color(0xFF7E22CE)
                          : const Color(0xFF137333),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
