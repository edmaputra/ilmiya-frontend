import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/notifications/presentation/notifications_screen.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableWidget() {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: NotificationsScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('NotificationsScreen renders broadcast composer and simulator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Real-Time Notification Center'), findsOneWidget);
  });
}
