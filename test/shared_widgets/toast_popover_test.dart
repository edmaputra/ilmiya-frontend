import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ilmiya_app/shared_widgets/toast_popover.dart';
import 'package:ilmiya_app/state/app_state.dart';

void main() {
  testWidgets('ToastPopover renders null state as SizedBox.shrink',
      (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [ToastPopover()],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ToastPopover), findsOneWidget);
    expect(find.textContaining('URGENT'), findsNothing);
  });

  testWidgets('ToastPopover renders active toast and allows dismissal',
      (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [ToastPopover()],
            ),
          ),
        ),
      ),
    );

    // Trigger an emergency notification toast
    appState.simulateNotification('emergency');
    await tester.pumpAndSettle();

    expect(find.textContaining('URGENT'), findsOneWidget);

    // Tap the close button
    final closeBtn = find.byIcon(Icons.close);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('URGENT'), findsNothing);
  });
}
