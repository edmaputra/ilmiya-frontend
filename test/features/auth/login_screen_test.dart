import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/features/auth/presentation/login_screen.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
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

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('LoginScreen Tests', () {
    late ApiClient client;
    late MockStorageService storage;
    late IamService iam;
    late AuthNotifier authNotifier;

    setUp(() {
      client = apiClient;
      client.isMockMode = true;
      storage = MockStorageService();
      iam = IamService(apiClient: client, mockStorage: storage);
      authNotifier = AuthNotifier(iamService: iam, apiClient: client);
    });

    testWidgets('LoginScreen renders brand and app bar elements on desktop',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ilmiya'), findsOneWidget);
      expect(
          find.text('School Information System & IAM Portal'), findsOneWidget);
      expect(find.text('Mock Simulation'), findsWidgets);
    });

    testWidgets(
        'LoginScreen hides app bar subtitle on mobile and displays startup mode status',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // On mobile (< 768), subtitle should be hidden
      expect(find.text('School Information System & IAM Portal'), findsNothing);

      // Mode Status Pill in app bar is displayed as read-only status
      expect(find.text('Mock Simulation'), findsWidgets);
    });

    testWidgets('LoginScreen can toggle dark and light theme',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = AppState();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: appState),
            ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in light mode
      expect(appState.themeMode, equals(ThemeMode.light));
      final themeBtn = find.byTooltip('Dark Mode');
      expect(themeBtn, findsOneWidget);
      expect(find.byIcon(LucideIcons.moon), findsOneWidget);

      // Tap theme toggle -> switch to dark mode
      await tester.tap(themeBtn);
      await tester.pumpAndSettle();

      expect(appState.themeMode, equals(ThemeMode.dark));
      expect(find.byTooltip('Light Mode'), findsOneWidget);
      expect(find.byIcon(LucideIcons.sun), findsOneWidget);

      // Tap again -> switch back to light mode
      await tester.tap(find.byTooltip('Light Mode'));
      await tester.pumpAndSettle();

      expect(appState.themeMode, equals(ThemeMode.light));
      expect(find.byTooltip('Dark Mode'), findsOneWidget);
      expect(find.byIcon(LucideIcons.moon), findsOneWidget);
    });

    testWidgets(
        'After logout, LoginScreen displays Sign In to Portal and is not loading',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Perform logout on authNotifier
      authNotifier.logout();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign In to Portal'), findsOneWidget);
      expect(find.text('Signing In...'), findsNothing);
      expect(authNotifier.isLoading, isFalse);
    });
  });
}
