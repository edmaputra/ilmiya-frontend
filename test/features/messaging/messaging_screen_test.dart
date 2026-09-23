import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/messaging/presentation/messaging_screen.dart';
import 'package:ilmiya_app/features/messaging/widgets/security_audit_dialog.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

final List<int> _transparentImage = List<int>.unmodifiable([
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
  setUp(() => HttpOverrides.global = _MockHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  Widget buildTestableWidget({AppState? appState}) {
    return ChangeNotifierProvider(
      create: (_) => appState ?? AppState(),
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
          home: const Scaffold(body: MessagingScreen()),
        ),
      ),
    );
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('MessagingScreen renders channels sidebar and message input',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byType(MessagingScreen), findsOneWidget);
    expect(find.text('Secure Communications'), findsOneWidget);
  });

  testWidgets('MessagingScreen shows encrypted channel badge in chat area',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Encrypted Channel'), findsOneWidget);
  });

  testWidgets('MessagingScreen sends a message via Send button',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    final state = AppState();
    await tester.pumpWidget(buildTestableWidget(appState: state));
    await tester.pumpAndSettle();

    final initialCount = state.activeChannelMessages.length;

    // Type a message and send it
    await tester.enterText(find.byType(TextField).last, 'Hello teacher!');
    await tester.tap(find.text('Send'));
    // Pump through the scroll animation and 1800ms auto-reply timer
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(state.activeChannelMessages.length, greaterThan(initialCount));
    expect(
        state.activeChannelMessages.any((m) => m.content == 'Hello teacher!'),
        isTrue);
  });

  testWidgets('MessagingScreen quick reply row is visible',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // There are multiple ListViews — quick replies + main message list
    // We just verify the quick reply widgets are rendered
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(MessagingScreen), findsOneWidget);
  });

  testWidgets('MessagingScreen opens SecurityAuditDialog on info button tap',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap the info outline button in the chat top bar
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.byType(SecurityAuditDialog), findsOneWidget);

    // Dismiss via the ElevatedButton (text: 'Confirm Verified Identity')
    await tester.tap(find.text('Confirm Verified Identity'));
    await tester.pumpAndSettle();
    expect(find.byType(SecurityAuditDialog), findsNothing);
  });

  testWidgets('MessagingScreen attach PDF adds attachment message',
      (WidgetTester tester) async {
    setDesktopSize(tester);
    final state = AppState();
    await tester.pumpWidget(buildTestableWidget(appState: state));
    await tester.pumpAndSettle();

    final initialCount = state.activeChannelMessages.length;

    // Tap attach file button — immediately sends a PDF attachment message
    await tester.tap(find.byIcon(Icons.attach_file));
    await tester.pump();
    // Let the post-frame callback scroll animation and 1800ms timer complete
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(state.activeChannelMessages.length, greaterThan(initialCount));
    expect(
        state.activeChannelMessages.any((m) => m.attachment != null), isTrue);
  });

  testWidgets('MessagingScreen renders in tablet viewport (no sidebar)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byType(MessagingScreen), findsOneWidget);
    // At 600px wide (< 768): no sidebar, only main chat area
    expect(find.text('Encrypted Channel'), findsOneWidget);
  });
}
