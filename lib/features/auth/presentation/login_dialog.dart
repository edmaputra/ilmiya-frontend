import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/iam.dart';
import '../../../core/utils/app_toast.dart';
import '../../../state/auth_notifier.dart';
import '../widgets/credentials_form.dart';
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

  String? _localError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthNotifier>().resetLoading();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleManualLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _localError = null;
    });

    final emailTrimmed = _emailController.text.trim();
    final auth = context.read<AuthNotifier>();
    try {
      await auth.login(LoginRequest(
        email: emailTrimmed,
        password: _passwordController.text,
      ));
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Signed in successfully as ${auth.user?.fullName ?? emailTrimmed}',
        );
        _passwordController.clear();
        widget.onSuccess?.call();
        if (!widget.isStandalone) Navigator.of(context).pop();
      }
    } catch (e) {
      final msg = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException(0): ', '');
      setState(() {
        _localError = msg;
      });
      if (mounted) {
        AppToast.showError(context, 'Authentication failed: $msg');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderMedium,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
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

          CredentialsForm(
            auth: auth,
            emailController: _emailController,
            passwordController: _passwordController,
            formKey: _formKey,
            onSubmit: _handleManualLogin,
          ),
        ],
      ),
    );

    return SingleChildScrollView(child: content);
  }
}
