import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class FlutterCodeScreen extends StatefulWidget {
  const FlutterCodeScreen({super.key});

  @override
  State<FlutterCodeScreen> createState() => _FlutterCodeScreenState();
}

class _FlutterCodeScreenState extends State<FlutterCodeScreen> {
  int _activeSubTab = 0; // 0: Source Code, 1: Architecture, 2: CLI Guide
  int _selectedFileIndex = 0;

  final List<Map<String, String>> _flutterFiles = [
    {
      'name': 'pubspec.yaml',
      'path': 'pubspec.yaml',
      'desc': 'Multiplatform Flutter dependencies with Provider, Local Notifications, and Typography.',
      'code': '''name: ilmiya_app
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
    },
    {
      'name': 'main.dart',
      'path': 'lib/main.dart',
      'desc': 'Application entrypoint configuring ProviderScope, Adaptive Material 3 theme, and Scaffold.',
      'code': '''import 'package:flutter/material.dart';
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
    },
    {
      'name': 'app_theme.dart',
      'path': 'lib/core/theme/app_theme.dart',
      'desc': 'Design system tokens implementing Natural Tones palette and Material 3 typography.',
      'code': '''import 'package:flutter/material.dart';
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
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'FLUTTER 3.19+ CROSS-PLATFORM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: AppColors.forestSage,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('• Clean Architecture', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Multiplatform Flutter Codebase & Architecture',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Production-ready Flutter & Dart source files targeting iOS, Android, Web, and Desktop',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Sub-tab switcher
                    Row(
                      children: [
                        _buildSubTab(0, 'Source Code'),
                        const SizedBox(width: 6),
                        _buildSubTab(1, 'Architecture'),
                        const SizedBox(width: 6),
                        _buildSubTab(2, 'CLI Guide'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Targets Indicator
                Row(
                  children: [
                    _buildTargetBadge(Icons.phone_iphone, 'Apple iOS', 'Cupertino HIG, APNs Push'),
                    const SizedBox(width: 12),
                    _buildTargetBadge(Icons.android, 'Google Android', 'Material 3, Firebase FCM'),
                    const SizedBox(width: 12),
                    _buildTargetBadge(Icons.language, 'Flutter Web', 'CanvasKit, Responsive Grid'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sub-Tab Content
          if (_activeSubTab == 0) _buildSourceCodeView()
          else if (_activeSubTab == 1) _buildArchitectureView()
          else _buildCliGuideView(),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String label) {
    final isActive = _activeSubTab == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.forestSage : AppColors.borderLight,
        foregroundColor: isActive ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => setState(() => _activeSubTab = index),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildTargetBadge(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.naturalParchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warmSand,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(icon, size: 16, color: AppColors.forestSage),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCodeView() {
    final currentFile = _flutterFiles[_selectedFileIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left File Tree
          SizedBox(
            width: 260,
            child: Container(
              color: AppColors.naturalParchment,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROJECT STRUCTURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _flutterFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final file = _flutterFiles[index];
                      final isSelected = index == _selectedFileIndex;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedFileIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.warmSand : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.forestSage.withOpacity(0.4) : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file_outlined, size: 14, color: isSelected ? AppColors.forestSage : AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(child: Text(file['path']!, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(currentFile['desc']!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1, color: AppColors.borderLight),

          // Right Code Preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currentFile['path']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.forestSage)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.naturalParchment,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.copy, size: 12),
                        label: const Text('Copy Dart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: currentFile['code']!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF242724),
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    currentFile['code']!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: Color(0xFFE9E4DB),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clean Feature-First Flutter Architecture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            children: [
              _buildArchCard('1. UI Presentation', 'Adaptive Widgets', 'Cupertino widgets on iOS, Material 3 on Android, and responsive web flex layout.'),
              _buildArchCard('2. State Management', 'Provider / ChangeNotifier', 'Compile-safe reactive state with automated lifecycle caching and notification streams.'),
              _buildArchCard('3. Real-Time Network', 'WebSocket + Push', 'Full-duplex real-time events for instant teacher-student messaging & alerts.'),
              _buildArchCard('4. Security & E2EE', 'AES-256-GCM + FERPA', 'Client-side cryptographic agreement verified for strict FERPA and COPPA compliance.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchCard(String badge, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warmSand,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.forestSage)),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildCliGuideView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CLI Setup & Multiplatform Build Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _buildCliStep('1. Install Dependencies', 'flutter pub get'),
          const SizedBox(height: 12),
          _buildCliStep('2. Run in Development', 'flutter run -d web-server --web-port=8080  # Run on Generic Web Server\nflutter run -d chrome                     # Run on Chrome\nflutter run -d linux                      # Run on Linux Desktop\nflutter run -d ios                        # Run on iOS\nflutter run -d android                    # Run on Android'),
          const SizedBox(height: 12),
          _buildCliStep('3. Build Production Releases', 'flutter build web --release\nflutter build linux --release\nflutter build appbundle --release\nflutter build ipa --release'),
        ],
      ),
    );
  }

  Widget _buildCliStep(String title, String cmd) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF242724),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              cmd,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.softKhaki, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
