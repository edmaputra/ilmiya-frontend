import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'state/auth_notifier.dart';
import 'shared_widgets/adaptive_scaffold.dart';
import 'features/school_profile/presentation/school_profile_screen.dart';
import 'features/academic_years/presentation/academic_years_screen.dart';
import 'features/iam_management/presentation/iam_management_screen.dart';
import 'features/preview/presentation/preview_screen.dart';

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
    return MaterialApp(
      title: 'Ilmiya - School Information System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Clamp system font scaling (iOS & Android accessibility "Large Text"
      // setting) to a neutral 1.0 so the UI layout stays predictable across
      // devices. Web and desktop are unaffected because their textScaler is
      // already 1.0 by default.
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
              index: state.currentTab.clamp(0, 3),
              children: [
                SchoolProfileScreen(key: ValueKey('school_profile_${auth.tenantId}')),
                AcademicYearsScreen(key: ValueKey('academic_years_${auth.tenantId}')),
                IamManagementScreen(key: ValueKey('iam_management_${auth.tenantId}')),
                const PreviewScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}
