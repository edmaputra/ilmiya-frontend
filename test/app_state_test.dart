import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/user_profile.dart';
import 'package:ilmiya_app/core/models/notification_item.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Unit Tests', () {
    test('Initial state loads student role and calculate GPA correctly', () {
      final state = AppState();
      expect(state.currentRole, equals(UserRole.student));
      expect(state.currentUser.name, equals('Alex Rivera'));
      expect(state.courses.length, equals(6));
      expect(
          double.parse(state.cumulativeGpa['unweighted']!), greaterThan(3.5));
      expect(double.parse(state.cumulativeGpa['weighted']!), greaterThan(4.0));
    });

    test('Role switching updates current user profile', () {
      final state = AppState();
      state.setRole(UserRole.teacher);
      expect(state.currentRole, equals(UserRole.teacher));
      expect(state.currentUser.name, equals('Dr. Eleanor Vance'));

      state.setRole(UserRole.parent);
      expect(state.currentRole, equals(UserRole.parent));
      expect(state.currentUser.name, equals('Marco Rivera'));
    });

    test('Messaging send and receive updates active channel', () {
      final state = AppState();
      final initialCount = state.activeChannelMessages.length;

      state.sendMessage(
        channelId: state.activeChannelId,
        content: 'Test message for instructor',
      );

      expect(state.activeChannelMessages.length, equals(initialCount + 1));
      expect(state.activeChannelMessages.last.content,
          equals('Test message for instructor'));
    });

    test('Broadcast announcement adds new high priority notification', () {
      final state = AppState();
      final initialCount = state.notifications.length;

      state.broadcastAnnouncement(
        title: 'Midterm Schedule Updated',
        message: 'Please review room allocations.',
        priority: NotificationPriority.high,
        target: 'All Students',
      );

      expect(state.notifications.length, equals(initialCount + 1));
      expect(state.notifications.first.title,
          contains('Midterm Schedule Updated'));
      expect(state.notifications.first.priority,
          equals(NotificationPriority.high));
    });

    test('KiteAccent switching updates accent state and notifies listeners',
        () {
      final state = AppState();
      expect(state.accent, equals(KiteAccent.slate));

      bool notified = false;
      state.addListener(() => notified = true);

      state.setAccent(KiteAccent.blue);
      expect(state.accent, equals(KiteAccent.blue));
      expect(notified, isTrue);

      state.setAccent(KiteAccent.violet);
      expect(state.accent, equals(KiteAccent.violet));
    });

    test('AppTheme generates valid themes for all KiteAccent options', () {
      for (final accent in KiteAccent.values) {
        final lightTheme = AppTheme.lightTheme(accent);
        final darkTheme = AppTheme.darkTheme(accent);
        final shadLight = AppTheme.shadTheme(accent, Brightness.light);
        final shadDark = AppTheme.shadTheme(accent, Brightness.dark);

        expect(lightTheme.brightness, equals(Brightness.light));
        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(shadLight.brightness, equals(Brightness.light));
        expect(shadDark.brightness, equals(Brightness.dark));
        expect(accent.primaryColor(Brightness.light), isNotNull);
        expect(accent.primaryColor(Brightness.dark), isNotNull);
      }
    });
  });
}
