import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/features/auth/presentation/login_dialog.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

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

class _FailingIamService extends IamService {
  _FailingIamService({required super.apiClient, required super.mockStorage});

  @override
  Future<TokenResponse> login(LoginRequest req) async {
    throw Exception('Invalid credentials provided');
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('LoginDialog Tests', () {
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

    testWidgets('LoginDialog renders clean credentials form without personas',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: const Scaffold(
              body: LoginDialog(isStandalone: true),
            ),
          ),
        ),
      );

      expect(
          find.textContaining('Ilmiya Institutional Access'), findsOneWidget);
      expect(find.text('Institutional Credentials'), findsOneWidget);
      expect(find.text('Institutional Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to Portal'), findsOneWidget);

      // Personas section must NOT be rendered
      expect(find.text('Platform SuperAdmin'), findsNothing);
      expect(find.text('Demo Personas'), findsNothing);
    });

    testWidgets(
        'LoginDialog manual login form validation and visibility toggle',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: const Scaffold(
              body: LoginDialog(isStandalone: true),
            ),
          ),
        ),
      );

      final signInBtn = find.text('Sign In to Portal');
      expect(signInBtn, findsOneWidget);

      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();

      expect(find.text('Institutional email or username is required'),
          findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Toggle password visibility
      final visibilityBtn = find.byIcon(Icons.visibility_off);
      expect(visibilityBtn, findsOneWidget);
      await tester.tap(visibilityBtn);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets(
        'LoginDialog.show opens dialog, displays close button, and pops on close',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthNotifier>.value(
          value: authNotifier,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => LoginDialog.show(context),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginDialog), findsOneWidget);
      final closeBtn = find.byIcon(Icons.close);
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginDialog), findsNothing);
    });

    testWidgets('LoginDialog manual login succeeds and triggers onSuccess',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool successCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: authNotifier,
            child: Scaffold(
              body: LoginDialog(
                isStandalone: true,
                onSuccess: () => successCalled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'admin.utama@ilmiya.edu');
      await tester.enterText(textFields.at(1), 'Superadmin@123');

      final signInBtn = find.text('Sign In to Portal');
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      expect(authNotifier.isAuthenticated, isTrue);
    });

    testWidgets('LoginDialog failure displays error banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final failingIam =
          _FailingIamService(apiClient: client, mockStorage: storage);
      final failingAuthNotifier =
          AuthNotifier(iamService: failingIam, apiClient: client);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthNotifier>.value(
            value: failingAuthNotifier,
            child: const Scaffold(
              body: LoginDialog(isStandalone: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'unknown@domain.com');
      await tester.enterText(textFields.at(1), 'wrongpass');

      final signInBtn = find.text('Sign In to Portal');
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Invalid credentials provided'), findsOneWidget);
    });
  });
}
