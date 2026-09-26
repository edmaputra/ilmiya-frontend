class FlutterCodeSample {
  final String name;
  final String path;
  final String desc;
  final String code;

  const FlutterCodeSample({
    required this.name,
    required this.path,
    required this.desc,
    required this.code,
  });
}

const List<FlutterCodeSample> flutterCodeSamples = [
  FlutterCodeSample(
    name: 'pubspec.yaml',
    path: 'pubspec.yaml',
    desc:
        'Multiplatform Flutter dependencies with Provider, Local Notifications, and Typography.',
    code: '''name: ilmiya_app
description: "Ilmiya - Multiplatform School Information System for iOS, Android, and Web."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  google_fonts: ^6.2.1
  intl: ">=0.19.0 <1.0.0"
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/''',
  ),
  FlutterCodeSample(
    name: 'main.dart',
    path: 'lib/main.dart',
    desc:
        'Application entrypoint configuring ProviderScope, Adaptive Material 3 theme, and Scaffold.',
    code: '''import 'package:flutter/material.dart';
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
}''',
  ),
  FlutterCodeSample(
    name: 'app_theme.dart',
    path: 'lib/core/theme/app_theme.dart',
    desc:
        'Design system tokens implementing Natural Tones palette and Material 3 typography.',
    code: '''import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.naturalParchment,
      primaryColor: AppColors.forestSage,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestSage,
        secondary: AppColors.softKhaki,
        surface: AppColors.surfaceWhite,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
  }
}''',
  ),
];
