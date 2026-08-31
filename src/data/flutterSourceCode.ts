import { FlutterCodeFile } from '../types';

export const FLUTTER_CODE_FILES: FlutterCodeFile[] = [
  {
    filename: 'pubspec.yaml',
    path: 'pubspec.yaml',
    language: 'yaml',
    description: 'Multiplatform Flutter dependencies for iOS, Android, and Web with Riverpod, WebSockets, and Local Notifications',
    content: `name: open_sis_app
description: "OpenSIS - Multiplatform Open Source School Information System for iOS, Android, and Web."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management & Architecture
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing & Deep Linking
  go_router: ^14.0.1

  # Networking & Real-Time WebSockets
  dio: ^5.4.1
  web_socket_channel: ^2.4.5

  # Secure Local Storage & Caching
  flutter_secure_storage: ^9.0.0
  hive_flutter: ^1.1.0

  # Real-time Multiplatform Notifications
  flutter_local_notifications: ^17.0.0
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.19

  # Cryptography for Secure Teacher-Student Messaging (E2EE)
  cryptography: ^2.7.0
  encrypt: ^5.0.3

  # UI, Charts & Adaptive Design
  fl_chart: ^0.66.2
  cupertino_icons: ^1.0.8
  lucide_icons: ^0.257.0
  google_fonts: ^6.1.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  riverpod_generator: ^2.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
`
  },
  {
    filename: 'main.dart',
    path: 'lib/main.dart',
    language: 'dart',
    description: 'Main entry point supporting iOS, Android, and Web with Adaptive Theme and Riverpod scope',
    content: `import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/adaptive_theme.dart';
import 'core/routing/app_router.dart';
import 'features/notifications/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize multiplatform push notifications (iOS APNs, Android FCM, Web Push)
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: OpenSISApp(),
    ),
  );
}

class OpenSISApp extends ConsumerWidget {
  const OpenSISApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return MaterialApp.router(
      title: 'OpenSIS - School Information System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Multiplatform Responsive Scaffold wrapper for Web & Desktop layout
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: child!,
                ),
              );
            }
            return child!;
          },
        );
      },
    );
  }
}
`
  },
  {
    filename: 'grades_screen.dart',
    path: 'lib/features/grades/presentation/grades_screen.dart',
    language: 'dart',
    description: 'Grade Tracking screen with GPA overview, course breakdown, category weights, and interactive calculator',
    content: `import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/course_grade_model.dart';
import '../providers/grades_provider.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  String _selectedSemester = 'Spring 2026';

  @override
  Widget build(BuildContext context) {
    final gradesState = ref.watch(gradesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Grades & GPA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'GPA What-If Calculator',
            onPressed: () => _openGpaCalculator(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export Transcript',
            onPressed: () => _exportTranscript(context),
          ),
        ],
      ),
      body: gradesState.when(
        data: (courses) => CustomScrollView(
          slivers: [
            // GPA Summary Hero Header
            SliverToBoxAdapter(
              child: _buildGpaHeaderCard(context, courses),
            ),
            
            // Course List Header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enrolled Courses (6)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedSemester,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Spring 2026', child: Text('Spring 2026')),
                        DropdownMenuItem(value: 'Fall 2025', child: Text('Fall 2025')),
                      ],
                      onChanged: (val) => setState(() => _selectedSemester = val!),
                    ),
                  ],
                ),
              ),
            ),

            // Course Cards List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = courses[index];
                    return _buildCourseGradeCard(context, course);
                  },
                  childCount: courses.length,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading grades: $err')),
      ),
    );
  }

  Widget _buildGpaHeaderCard(BuildContext context, List<CourseGrade> courses) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('CUMULATIVE GPA', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('3.88', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  Text('Weighted: 4.12 / 4.0 scale', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 4),
                    Text('Top 5% (Rank #14)', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGradeCard(BuildContext context, CourseGrade course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: course.color.withOpacity(0.2),
          child: Text(course.code.substring(0, 2), style: TextStyle(color: course.color, fontWeight: FontWeight.bold)),
        ),
        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('\${course.teacher} • \${course.credits} Credits'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(course.letterGrade, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: course.color)),
            Text('\${course.percentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        onTap: () => _showCourseDetail(context, course),
      ),
    );
  }

  void _openGpaCalculator(BuildContext context) {
    // Open interactive bottom sheet for What-If scenario
  }

  void _exportTranscript(BuildContext context) {
    // Generate PDF via pdf package
  }

  void _showCourseDetail(BuildContext context, CourseGrade course) {
    // Show assignments list & weighted breakdown
  }
}
`
  },
  {
    filename: 'chat_screen.dart',
    path: 'lib/features/messaging/presentation/chat_screen.dart',
    language: 'dart',
    description: 'Secure End-to-End Encrypted teacher-student chat with real-time WebSocket channel',
    content: `import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/encryption_service.dart';
import '../models/chat_message_model.dart';
import '../providers/chat_provider.dart';

class SecureChatScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String recipientName;
  final String recipientRole;

  const SecureChatScreen({
    super.key,
    required this.channelId,
    required this.recipientName,
    required this.recipientRole,
  });

  @override
  ConsumerState<SecureChatScreen> createState() => _SecureChatScreenState();
}

class _SecureChatScreenState extends ConsumerState<SecureChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAttaching = false;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.channelId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.recipientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.lock, size: 12, color: Color(0xFF10B981)),
                const SizedBox(width: 4),
                Text(
                  'End-to-End Encrypted (AES-256)',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade300),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Encryption Verification & Security Audit',
            onPressed: _showSecurityAuditDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner for FERPA / Student Privacy Guard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF1E293B),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Official academic communications are logged securely according to school district policies.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),

          // Message Stream
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == 'current_user_id';
                  return _buildMessageBubble(msg, isMe);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Chat error: $err')),
            ),
          ),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : const Color(0xFF334155),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.contextTag != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('📎 \${msg.contextTag!.title}', style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD))),
              ),
            Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(msg.timeString, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 12, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(top: BorderSide(color: Color(0xFF334155))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Color(0xFF94A3B8)),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Message \${widget.recipientName}...',
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF38BDF8)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendEncryptedMessage(
      channelId: widget.channelId,
      rawContent: _textController.text.trim(),
    );
    _textController.clear();
  }

  void _showSecurityAuditDialog() {
    // Show E2EE key fingerprint
  }
}
`
  },
  {
    filename: 'notification_service.dart',
    path: 'lib/features/notifications/services/notification_service.dart',
    language: 'dart',
    description: 'Unified Push Notification Service handling APNs (iOS), FCM (Android), and Web Push Workers',
    content: `import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS Darwin settings
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification
      },
    );

    // 3. Combine initialization
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification deep link routing
        _handleDeepLink(response.payload);
      },
    );

    // 4. Request Platform Permissions
    if (!kIsWeb) {
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    }
  }

  /// Show high-priority local banner when new grade or message arrives
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'opensis_academic_alerts',
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'School Academic & Grade Alerts',
      channelDescription: 'Real-time notifications for grades, assignments, and messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'bell_chime.aiff',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  static void _handleDeepLink(String? payload) {
    if (payload == null) return;
    // e.g. "route:/grades/ap_physics" or "route:/chat/teacher_12"
  }
}
`
  },
  {
    filename: 'adaptive_theme.dart',
    path: 'lib/core/theme/adaptive_theme.dart',
    language: 'dart',
    description: 'Dynamic platform theme matching Apple HIG on iOS and Material 3 on Android/Web',
    content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseDanger = Color(0xFFF43F5E);
  
  static const Color darkBg = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF131C2E);
  static const Color darkCard = Color(0xFF1E293B);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: darkSurface,
        background: darkBg,
        error: roseDanger,
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFFF1F5F9),
        displayColor: Colors.white,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: Colors.white,
        background: Color(0xFFF8FAFC),
        error: roseDanger,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
    );
  }
}
`
  },
  {
    filename: 'README.md',
    path: 'README.md',
    language: 'markdown',
    description: 'Open source project documentation, CLI setup commands, and cross-platform build instructions',
    content: `# 🎓 OpenSIS - Open Source School Information System

OpenSIS is a modern, responsive, multiplatform School Information System (SIS) built for **iOS**, **Android**, and **Web** using **Flutter 3.19+** and clean feature-first architecture.

---

## 🌟 Key Features
- **📊 Real-time Grade Tracking**: Automatic GPA calculation (Weighted & Unweighted), category weighting, assignment feedback rubrics, and what-if simulation.
- **🔔 Multiplatform Push Notifications**: Instant APNs (iOS), FCM (Android), and Service Worker Web Push for grade posts, assignment deadlines, and school broadcasts.
- **💬 Secure Teacher-Student Messaging**: End-to-end encrypted (E2EE) channels with FERPA compliance guardrails, assignment inquiry tags, and file attachments.
- **📅 Interactive Timetable & Attendance**: Daily schedule with room tracking, teacher office hours, and attendance logs.
- **📱 True Multiplatform**: Adaptive Cupertino styling for iOS, Material 3 for Android, and responsive dashboard for Web/Desktop.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.19.0)
- Xcode 15+ (for iOS)
- Android Studio / Android SDK 34+ (for Android)
- Chrome / Safari / Edge (for Web)

### Setup & Run

\`\`\`bash
# 1. Clone the repository
git clone https://github.com/opensis/opensis-flutter.git
cd opensis-flutter

# 2. Install dependencies
flutter pub get

# 3. Generate Riverpod code & Hive adapters
dart run build_runner build --delete-conflicting-outputs

# 4. Run on your desired target:
flutter run -d chrome        # Web
flutter run -d ios           # iOS Simulator or Device
flutter run -d android       # Android Emulator or Device
flutter run -d macos         # macOS Desktop
\`\`\`

### Build Production Releases

\`\`\`bash
# Build Web SPA
flutter build web --release --web-renderer canvaskit

# Build Android APK & App Bundle
flutter build appbundle --release

# Build iOS Archive (Xcode)
flutter build ipa --release
\`\`\`

---

## 📂 Architecture Overview

\`\`\`
lib/
├── core/
│   ├── network/          # Dio & WebSocket stream clients
│   ├── routing/          # GoRouter platform routing
│   ├── services/         # E2EE Crypto & Local Storage
│   └── theme/            # Adaptive Material 3 & Cupertino Theme
└── features/
    ├── grades/           # GPA Calculator, Transcripts & Gradebook
    ├── messaging/        # E2EE Teacher-Student Chat & Attachments
    ├── notifications/    # Push Bridge & Broadcast Hub
    ├── schedule/         # Timetable & Period Management
    └── auth/             # Multi-role Auth (Student/Teacher/Parent/Admin)
\`\`\`

## 📜 License
Released under the **MIT Open Source License**. Free for educational institutions and developers worldwide.
`
  }
];
