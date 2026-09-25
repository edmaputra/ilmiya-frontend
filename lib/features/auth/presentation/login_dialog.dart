import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/services/api_client.dart';
import '../../../state/auth_notifier.dart';
import '../widgets/credentials_form.dart';
import '../widgets/demo_personas_section.dart';
import '../widgets/login_dialog_header.dart';

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
          LoginDialogHeader(isStandalone: widget.isStandalone),

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
                DemoPersonasSection(
                  auth: auth,
                  loadingPersona: _loadingPersona,
                  onSelectPersona: _handlePersonaLogin,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                CredentialsForm(
                  auth: auth,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  tenantController: _tenantController,
                  formKey: _formKey,
                  onSubmit: _handleManualLogin,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: DemoPersonasSection(
                    auth: auth,
                    loadingPersona: _loadingPersona,
                    onSelectPersona: _handlePersonaLogin,
                  ),
                ),
                const SizedBox(width: 24),
                Container(width: 1, height: 380, color: AppColors.borderLight),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: CredentialsForm(
                    auth: auth,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    tenantController: _tenantController,
                    formKey: _formKey,
                    onSubmit: _handleManualLogin,
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return SingleChildScrollView(child: content);
  }
}
