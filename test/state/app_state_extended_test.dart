import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/user_profile.dart';
import 'package:ilmiya_app/state/app_state.dart';

void main() {
  group('AppState Extended Unit Tests', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('theme management and toggling', () {
      expect(state.themeMode, ThemeMode.light);
      state.setThemeMode(ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
      state.toggleThemeMode();
      expect(state.themeMode, ThemeMode.light);
    });

    test('notification reading and deletion', () {
      expect(state.notifications, isNotEmpty);
      final firstNotifId = state.notifications.first.id;

      state.markNotificationRead(firstNotifId);
      expect(state.notifications.firstWhere((n) => n.id == firstNotifId).read,
          isTrue);

      state.markAllNotificationsRead();
      expect(state.unreadNotifsCount, equals(0));

      final initialLength = state.notifications.length;
      state.deleteNotification(firstNotifId);
      expect(state.notifications.length, equals(initialLength - 1));
      expect(state.notifications.any((n) => n.id == firstNotifId), isFalse);
    });

    test('toast and sound toggling', () {
      expect(state.soundEnabled, isTrue);
      state.toggleSound();
      expect(state.soundEnabled, isFalse);

      state.simulateNotification('emergency');
      expect(state.activeToast, isNotNull);
      expect(state.activeToast!.title, contains('URGENT'));

      state.dismissToast();
      expect(state.activeToast, isNull);
    });

    test(
        'simulateNotification presets: grade, message, emergency, announcement',
        () {
      state.simulateNotification('grade');
      expect(state.notifications.first.title, contains('New Grade Posted'));

      state.simulateNotification('message');
      expect(state.notifications.first.title, contains('Secure Message'));

      state.simulateNotification('announcement');
      expect(state.notifications.first.title, contains('Class Notice'));
    });

    test('inquiry context and clearing', () {
      final course = state.courses.first;
      final asg = course.assignments.first;

      state.inquireAssignment(course, asg);
      expect(state.pendingInquiryContext, isNotNull);
      expect(state.currentTab, equals(3));

      state.clearInquiryContext();
      expect(state.pendingInquiryContext, isNull);
    });

    test('updateCourseGrade recalculates score, percentage, and letter grade',
        () {
      final course = state.courses.first;
      final asg = course.assignments.first;

      state.updateCourseGrade(
        courseId: course.id,
        assignmentId: asg.id,
        newScore: asg.maxScore,
      );

      final updatedCourse = state.courses.firstWhere((c) => c.id == course.id);
      expect(updatedCourse.assignments.firstWhere((a) => a.id == asg.id).score,
          asg.maxScore);
    });

    test('sendMessage as teacher does not trigger student auto-reply timer',
        () {
      state.setRole(UserRole.teacher);
      final chanId = state.activeChannelId;
      final initialCount = state.activeChannelMessages.length;

      state.sendMessage(
        channelId: chanId,
        content: 'Teacher message to class',
      );

      expect(state.activeChannelMessages.length, equals(initialCount + 1));
      expect(
          state.activeChannelMessages.last.content, 'Teacher message to class');
    });
  });
}
