import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../state/auth_notifier.dart';

class LoginDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  final bool isStandalone;

  const LoginDialog({
    super.key,
    this.onSuccess,
    this.isStandalone = false,
  });

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LoginDialog(),
      ),
    );
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantController = TextEditingController(text: apiClient.tenantId);

  bool _obscurePassword = true;
  DemoPersonaKey? _loadingPersona;
  String? _localError;

  @override
  void initState() {
    super.initState();
    apiClient.addListener(_onApiClientChanged);
    _syncTenantController();
  }

  @override
  void dispose() {
    apiClient.removeListener(_onApiClientChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  void _onApiClientChanged() {
    if (mounted) {
      setState(() {
        _syncTenantController();
      });
    }
  }

  void _syncTenantController() {
    if (apiClient.isMockMode &&
        (_tenantController.text.isEmpty ||
            _tenantController.text == '01940000-0000-7000-8000-000000000001')) {
      _tenantController.text = apiClient.tenantId;
    } else if (!apiClient.isMockMode &&
        (_tenantController.text.isEmpty ||
            _tenantController.text == 'tenant-lincoln-high-001')) {
      _tenantController.text = apiClient.tenantId;
    }
  }

  IconData _getPersonaIcon(DemoPersonaKey key) {
    switch (key) {
      case DemoPersonaKey.superadmin:
        return Icons.security_rounded;
      case DemoPersonaKey.principal:
        return Icons.account_balance_rounded;
      case DemoPersonaKey.teacher:
        return Icons.school_rounded;
      case DemoPersonaKey.student:
        return Icons.person_rounded;
      case DemoPersonaKey.parent:
        return Icons.family_restroom_rounded;
    }
  }

  Future<void> _handleManualLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _localError = null;
    });

    final tenantTrimmed = _tenantController.text.trim();
    final emailTrimmed = _emailController.text.trim();
    if (apiClient.isMockMode &&
        (emailTrimmed.contains('@springfield.local') ||
            RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}')
                .hasMatch(tenantTrimmed))) {
      apiClient.isMockMode = false;
    }

    final auth = context.read<AuthNotifier>();
    try {
      await auth.login(LoginRequest(
        email: emailTrimmed,
        password: _passwordController.text,
        tenantId: tenantTrimmed,
      ));
      if (mounted) {
        widget.onSuccess?.call();
        if (!widget.isStandalone) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _localError = e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ApiException(0): ', '');
      });
    }
  }

  Future<void> _handlePersonaLogin(DemoPersonaKey key) async {
    setState(() {
      _loadingPersona = key;
      _localError = null;
    });

    final auth = context.read<AuthNotifier>();
    try {
      await auth.loginAsPersona(key);
      if (mounted) {
        widget.onSuccess?.call();
        if (!widget.isStandalone) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _localError = 'Failed to authenticate persona: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingPersona = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    final content = Container(
      constraints: const BoxConstraints(maxWidth: 880),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderMedium),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warmSand,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.forestSage, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Text(
                            'ED-IAM SECURITY PORTAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ilmiya Institutional Access',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Select a demo persona to test RBAC permissions or sign in with credentials.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!widget.isStandalone)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),

          if (_localError != null || auth.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF8B4B4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFF9B1C1C), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _localError ?? auth.error ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9B1C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Two-column layout on Desktop/Web, Column on mobile
          if (isMobile)
            Column(
              children: [
                _buildDemoPersonasSection(auth),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _buildCredentialsForm(auth),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildDemoPersonasSection(auth)),
                const SizedBox(width: 24),
                Container(width: 1, height: 380, color: AppColors.borderLight),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: _buildCredentialsForm(auth)),
              ],
            ),
        ],
      ),
    );

    return SingleChildScrollView(child: content);
  }

  Widget _buildDemoPersonasSection(AuthNotifier auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.touch_app_outlined,
                size: 16, color: AppColors.forestSage),
            SizedBox(width: 6),
            Text(
              '1-Click Demo Personas',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Instantly authenticate without passwords to test RBAC roles & action guards:',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        ...DemoPersonaKey.values.map((key) {
          final persona = DEMO_PERSONAS[key]!;
          final isSelected = auth.user?.email == persona.email;
          final isLoading = _loadingPersona == key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: auth.isLoading ? null : () => _handlePersonaLogin(key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.warmSand : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forestSage
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelected
                          ? AppColors.forestSage
                          : AppColors.surfaceMuted,
                      child: Icon(
                        _getPersonaIcon(key),
                        size: 18,
                        color: isSelected
                            ? AppColors.surfaceWhite
                            : AppColors.forestSage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                persona.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  persona.roleLabel,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestSage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            persona.description,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.forestSage),
                      )
                    else
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCredentialsForm(AuthNotifier auth) {
    return Form(
      key: _formKey,
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
            controller: _emailController,
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
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.key_outlined, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 18),
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
            controller: _tenantController,
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
            onPressed: auth.isLoading ? null : _handleManualLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestSage,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: auth.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.login_rounded, size: 18),
            label: Text(auth.isLoading ? 'Signing In...' : 'Sign In to Portal'),
          ),

          const SizedBox(height: 12),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                apiClient.toggleMockMode();
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
