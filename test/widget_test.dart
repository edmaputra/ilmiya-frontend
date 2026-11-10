import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ilmiya_app/main.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:ilmiya_app/core/services/api_client.dart';

final Uint8List _transparentImage = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  setUp(() {
    apiClient.isMockMode = true;
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
      ],
      child: const IlmiyaApp(),
    );
  }

  testWidgets(
      'IlmiyaApp loads School Profile as default tab and displays navigation pills',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify brand title and navigation pills exist
    expect(find.text('Ilmiya'), findsWidgets);
    expect(find.text('School Profile'), findsWidgets);
    expect(find.text('Academic Years'), findsWidgets);
    expect(find.text('IAM Console'), findsWidgets);
    expect(find.text('Feature Previews'), findsWidgets);

    // Verify School Profile content loaded
    expect(find.textContaining('SMA Negeri 1 Ilmiya'), findsWidgets);
    expect(find.text('Operational Rules'), findsOneWidget);
  });

  testWidgets('IlmiyaApp navigation switches between tabs correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    final authNotifier = AuthNotifier();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ],
        child: const IlmiyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Academic Years
    appState.setTab(1);
    await tester.pumpAndSettle();
    expect(find.text('Academic Years & Terms'), findsOneWidget);

    // Navigate to IAM Console
    appState.setTab(2);
    await tester.pumpAndSettle();
    expect(find.textContaining('Identity & Access Management'), findsOneWidget);

    // Navigate to Feature Previews
    appState.setTab(3);
    await tester.pumpAndSettle();
    expect(find.text('Feature Preview & Prototype Labs'), findsOneWidget);
  });

  testWidgets(
      'IlmiyaApp renders without overflow on iPhone 12 Pro dimensions (390x844)',
      (WidgetTester tester) async {
    // iPhone 12 Pro viewport size: 390 x 844 logical pixels
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    final authNotifier = AuthNotifier();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ],
        child: const IlmiyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and mobile bottom navigation bar render without overflow
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('School'), findsOneWidget);

    // Switch to Academic Years on mobile
    appState.setTab(1);
    await tester.pumpAndSettle();
    expect(find.text('Academic Years & Terms'), findsOneWidget);

    // Switch to IAM Console on mobile
    appState.setTab(2);
    await tester.pumpAndSettle();
    expect(find.textContaining('Identity & Access Management'), findsOneWidget);

    // Open mobile sidebar drawer and verify it is wrapped in SafeArea
    final menuButton = find.byIcon(LucideIcons.menu);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify Drawer and SafeArea inside it exist
    expect(find.byType(Drawer), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
    expect(find.text('Ilmiya'), findsWidgets);
    expect(find.text('School Profile'), findsWidgets);

    // Close the drawer
    Navigator.of(tester.element(find.byType(Drawer))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets(
      'Switching tenant updates dynamic school name in header and state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    final authNotifier = AuthNotifier();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ],
        child: const IlmiyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial tenant is SMA Negeri 1 Ilmiya (Lincoln High Campus)
    expect(find.textContaining('SMA Negeri 1 Ilmiya (Lincoln High Campus)'),
        findsWidgets);

    // Switch tenant to SMAN 1 Ilmiya
    await authNotifier.switchTenant('tenant-sma1-ilmiya-002');
    await tester.pumpAndSettle();

    // Subtitle in header navbar dynamically updates
    expect(find.text('SMA Negeri 1 Ilmiya'), findsWidgets);
  });

  testWidgets(
      'IlmiyaApp renders cleanly and switches between Light and Dark mode without errors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Toggle dark theme mode via topbar button
    final themeToggle = find.byIcon(LucideIcons.moon);
    expect(themeToggle, findsWidgets);
    await tester.tap(themeToggle.first);
    await tester.pumpAndSettle();

    // Verify School Profile content renders cleanly in dark mode
    expect(find.textContaining('SMA Negeri 1 Ilmiya'), findsWidgets);
    expect(find.text('Operational Rules'), findsOneWidget);

    // Switch to Academic Years tab in dark mode
    await tester.tap(find.text('Academic Years').first);
    await tester.pumpAndSettle();
    expect(find.text('Academic Years & Terms'), findsOneWidget);

    // Switch to IAM tab in dark mode
    await tester.tap(find.text('IAM Console').first);
    await tester.pumpAndSettle();
    expect(find.text('Identity & Access Management (IAM)'), findsOneWidget);

    // Switch back to light mode
    final sunToggle = find.byIcon(LucideIcons.sun);
    expect(sunToggle, findsWidgets);
    await tester.tap(sunToggle.first);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Academic Years child term cards render with equal height and aligned action slots',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ApiClient().tenantId = 'tenant-lincoln-high-001';

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Navigate to Academic Years tab
    await tester.tap(find.text('Academic Years').first);
    await tester.pumpAndSettle();

    // Verify Active Term breakdown section renders
    expect(find.text('Terms & Semesters Breakdown'), findsOneWidget);

    // Active term card displays the active indicator
    expect(find.text('Active Term'), findsOneWidget);

    // Planned term card displays the Activate Term button
    expect(find.text('Activate Term'), findsOneWidget);

    // Verify both child cards have equal height and width constraints
    final termCardContainers = find.byWidgetPredicate((w) {
      if (w is Container && w.constraints != null) {
        return w.constraints!.minHeight == 112.0;
      }
      return false;
    });
    expect(termCardContainers, findsNWidgets(2));

    final size1 = tester.getSize(termCardContainers.at(0));
    final size2 = tester.getSize(termCardContainers.at(1));
    expect(size1.height, equals(size2.height));
    expect(size1.width, equals(size2.width));
  });
}
