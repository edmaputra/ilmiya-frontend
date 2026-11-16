import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../../state/auth_notifier.dart';
import '../../auth/presentation/login_dialog.dart';
import '../models/command_action_item.dart';

List<CommandActionItem> buildCommandActions(BuildContext context) {
  final appState = context.read<AppState>();
  final auth = context.read<AuthNotifier>();

  return [
    // Navigation
    CommandActionItem(
      title: 'School Profile',
      group: 'Navigation',
      icon: LucideIcons.school,
      subtitle: 'Institution details, accreditation & leadership',
      onSelect: () {
        appState.setTab(0);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Academic Years & Terms',
      group: 'Navigation',
      icon: LucideIcons.calendarDays,
      subtitle: 'Academic calendar, semesters, and term schedules',
      onSelect: () {
        appState.setTab(1);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'IAM Console (Identity & Access)',
      group: 'Navigation',
      icon: LucideIcons.shieldCheck,
      subtitle: 'Manage staff, student, and admin credentials & roles',
      onSelect: () {
        appState.setTab(2);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Feature Previews & Labs',
      group: 'Navigation',
      icon: LucideIcons.flaskConical,
      subtitle: 'Experimental components and preview sandbox',
      onSelect: () {
        appState.setTab(3);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Dashboard Overview',
      group: 'Navigation',
      icon: LucideIcons.layoutDashboard,
      subtitle: 'Executive school metrics, attendance & timetable',
      onSelect: () {
        appState.setTab(4);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Courses & Gradebook',
      group: 'Navigation',
      icon: LucideIcons.graduationCap,
      subtitle: 'Curriculum, grade calculations & coursework',
      onSelect: () {
        appState.setTab(5);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Messages & Communications',
      group: 'Navigation',
      icon: LucideIcons.messageSquare,
      subtitle: 'Direct messages & school discussion channels',
      onSelect: () {
        appState.setTab(6);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Notifications & Alerts',
      group: 'Navigation',
      icon: LucideIcons.bell,
      subtitle: 'Administrative notices and academic alerts',
      onSelect: () {
        appState.setTab(7);
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Tenant Management Console (SuperAdmin)',
      group: 'Navigation',
      icon: LucideIcons.building2,
      subtitle:
          'Multi-tenant institution registry, accreditation oversight & quotas',
      onSelect: () {
        appState.setTab(8);
        Navigator.of(context).pop();
      },
    ),

    // System Actions
    CommandActionItem(
      title: 'Toggle Theme (Light / Dark)',
      group: 'Actions',
      icon: appState.themeMode == ThemeMode.dark
          ? LucideIcons.sun
          : LucideIcons.moon,
      subtitle:
          'Currently: ${appState.themeMode == ThemeMode.dark ? "Dark" : "Light"}',
      onSelect: () {
        appState.toggleThemeMode();
        Navigator.of(context).pop();
      },
    ),
    CommandActionItem(
      title: 'Switch to Lincoln High School',
      group: 'Multi-Tenant Context',
      icon: LucideIcons.building,
      subtitle: 'Tenant: tenant-lincoln-high-001',
      onSelect: () async {
        Navigator.of(context).pop();
        await auth.switchTenant('tenant-lincoln-high-001');
      },
    ),
    CommandActionItem(
      title: 'Switch to SMA Negeri 1 Ilmiya',
      group: 'Multi-Tenant Context',
      icon: LucideIcons.building2,
      subtitle: 'Tenant: tenant-sma1-ilmiya-002',
      onSelect: () async {
        Navigator.of(context).pop();
        await auth.switchTenant('tenant-sma1-ilmiya-002');
      },
    ),
    CommandActionItem(
      title: 'Sign In / Switch Persona...',
      group: 'Actions',
      icon: LucideIcons.logIn,
      subtitle: 'Log in with custom credentials or demo RBAC persona',
      onSelect: () {
        Navigator.of(context).pop();
        LoginDialog.show(context);
      },
    ),
  ];
}
