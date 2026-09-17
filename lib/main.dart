import 'package:flutter/material.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/academic_years/presentation/academic_years_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/grades/presentation/grades_screen.dart';
import 'features/iam_management/presentation/iam_management_screen.dart';
import 'features/messaging/presentation/messaging_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/preview/presentation/preview_screen.dart';
import 'features/school_profile/presentation/school_profile_screen.dart';
import 'shared_widgets/adaptive_scaffold.dart';
import 'state/app_state.dart';
import 'state/auth_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
      ],
      child: const IlmiyaApp(),
    ),
  );
}

class IlmiyaApp extends StatelessWidget {
  const IlmiyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.themeMode == ThemeMode.dark;

    return ShadTheme(
      data: isDark ? AppTheme.shadDarkTheme : AppTheme.shadLightTheme,
      child: MaterialApp(
        title: 'Ilmiya - School Information System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appState.themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        home: Consumer2<AppState, AuthNotifier>(
          builder: (context, state, auth, _) {
            return AdaptiveScaffold(
              body: IndexedStack(
                index: state.currentTab.clamp(0, 7),
                children: [
                  SchoolProfileScreen(key: ValueKey('school_profile_${auth.tenantId}')),
                  AcademicYearsScreen(key: ValueKey('academic_years_${auth.tenantId}')),
                  IamManagementScreen(key: ValueKey('iam_management_${auth.tenantId}')),
                  const PreviewScreen(),
                  DashboardScreen(key: ValueKey('dashboard_${auth.tenantId}')),
                  const GradesScreen(),
                  const MessagingScreen(),
                  const NotificationsScreen(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
