import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'shared_widgets/adaptive_scaffold.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/grades/presentation/grades_screen.dart';
import 'features/messaging/presentation/messaging_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/flutter_code/presentation/flutter_code_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
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
              index: state.currentTab,
              children: const [
                DashboardScreen(),
                GradesScreen(),
                MessagingScreen(),
                NotificationsScreen(),
                FlutterCodeScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}
