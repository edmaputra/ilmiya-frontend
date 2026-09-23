import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('LoginDialog renders and allows quick persona selection',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient();
    client.isMockMode = true;
    final storage = MockStorageService();
    final iam = IamService(apiClient: client, mockStorage: storage);
    final authNotifier = AuthNotifier(iamService: iam, apiClient: client);

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

    expect(find.textContaining('Ilmiya Institutional Access'), findsOneWidget);
    expect(find.textContaining('Platform SuperAdmin'), findsOneWidget);
    expect(find.textContaining('School Principal'), findsOneWidget);

    // Tap the School Principal persona
    await tester.tap(find.textContaining('School Principal'));
    await tester.pumpAndSettle();

    expect(authNotifier.user?.fullName, contains('Marcus Chen'));
  });

  testWidgets('LoginDialog manual login form validation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient();
    client.isMockMode = true;
    final storage = MockStorageService();
    final iam = IamService(apiClient: client, mockStorage: storage);
    final authNotifier = AuthNotifier(iamService: iam, apiClient: client);

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

    expect(find.text('Email is required'), findsOneWidget);
  });
}
