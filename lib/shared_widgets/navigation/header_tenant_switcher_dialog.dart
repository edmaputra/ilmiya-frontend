import 'package:flutter/material.dart';

import '../../core/services/school_service.dart';
import '../../state/auth_notifier.dart';
import 'app_shell_tenant_dialog.dart';

class HeaderTenantSwitcherDialog extends StatelessWidget {
  final AuthNotifier auth;
  final SchoolService? schoolService;
  final String title;

  const HeaderTenantSwitcherDialog({
    super.key,
    required this.auth,
    this.schoolService,
    this.title = 'Switch Multi-Tenant Context',
  });

  static Future<void> show(
    BuildContext context,
    AuthNotifier auth, {
    SchoolService? schoolService,
    String title = 'Switch Multi-Tenant Context',
  }) {
    return AppShellTenantDialog.show(
      context,
      auth,
      schoolService: schoolService,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellTenantDialog(
      auth: auth,
      schoolService: schoolService,
      title: title,
    );
  }
}
