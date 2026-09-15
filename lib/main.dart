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
      home: Consumer<AppState>(
        builder: (context, state, _) {
          return AdaptiveScaffold(
            body: IndexedStack(
              index: state.currentTab.clamp(0, 3),
              children: const [
                SchoolProfileScreen(),
                AcademicYearsScreen(),
                IamManagementScreen(),
                PreviewScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}
