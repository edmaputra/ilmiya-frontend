import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/user_profile.dart';
import '../core/models/course.dart';
import '../core/models/notification_item.dart';
import '../core/models/chat_message.dart';
import '../core/models/schedule_period.dart';
import '../core/data/mock_data.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_theme.dart';

class AppState extends ChangeNotifier {
  UserRole _currentRole = UserRole.student;
  int _currentTab =
      0; // 0: Dashboard, 1: Grades, 2: Messaging, 3: Notifications, 4: Flutter Code

  List<Course> _courses = List.from(initialCourses);
  List<NotificationItem> _notifications = List.from(initialNotifications);
  List<ChatChannel> _channels = List.from(initialChannels);
  final Map<String, List<ChatMessage>> _messages = {
    for (var entry in initialMessages.entries)
      entry.key: List.from(entry.value),
  };

  String _activeChannelId = 'chan_vance_direct';
  Map<String, dynamic>?
      _pendingInquiryContext; // {'course': Course, 'assignment': Assignment}
  NotificationItem? _activeToast;
  bool _soundEnabled = true;
  Timer? _toastTimer;
  ThemeMode _themeMode = ThemeMode.light;
  KiteAccent _accent = KiteAccent.slate;

  // Getters
  UserRole get currentRole => _currentRole;
  int get currentTab => _currentTab;
  ThemeMode get themeMode => _themeMode;
  KiteAccent get accent => _accent;
  List<Course> get courses => _courses;
  List<NotificationItem> get notifications => _notifications;
  List<ChatChannel> get channels => _channels;
  Map<String, List<ChatMessage>> get messages => _messages;
  String get activeChannelId => _activeChannelId;
  Map<String, dynamic>? get pendingInquiryContext => _pendingInquiryContext;
  NotificationItem? get activeToast => _activeToast;
  bool get soundEnabled => _soundEnabled;
  List<SchedulePeriod> get schedule => weeklySchedule;

  UserProfile get currentUser =>
      mockProfiles[_currentRole] ?? mockProfiles[UserRole.student]!;

  int get unreadNotifsCount => _notifications.where((n) => !n.read).length;
  int get unreadMessagesCount =>
      _channels.fold(0, (sum, c) => sum + c.unreadCount);

  ChatChannel get activeChannel {
    return _channels.firstWhere(
      (c) => c.id == _activeChannelId,
      orElse: () => _channels.first,
    );
  }

  List<ChatMessage> get activeChannelMessages {
    return _messages[_activeChannelId] ?? [];
  }

  Map<String, String> get cumulativeGpa {
    double totalUnweighted = 0;
    double totalWeighted = 0;
    double totalCredits = 0;

    final gradePointsMap = {
      'A+': {'unweighted': 4.0, 'weighted': 5.0},
      'A': {'unweighted': 4.0, 'weighted': 5.0},
      'A-': {'unweighted': 3.7, 'weighted': 4.7},
      'B+': {'unweighted': 3.3, 'weighted': 4.3},
      'B': {'unweighted': 3.0, 'weighted': 4.0},
      'B-': {'unweighted': 2.7, 'weighted': 3.7},
      'C+': {'unweighted': 2.3, 'weighted': 3.3},
      'C': {'unweighted': 2.0, 'weighted': 3.0},
      'F': {'unweighted': 0.0, 'weighted': 0.0},
    };

    for (var c in _courses) {
      final pts =
          gradePointsMap[c.letterGrade] ?? {'unweighted': 3.0, 'weighted': 4.0};
      totalUnweighted += (pts['unweighted'] ?? 3.0) * c.credits;
      totalWeighted += (pts['weighted'] ?? 4.0) * c.credits;
      totalCredits += c.credits;
    }

    return {
      'unweighted': totalCredits > 0
          ? (totalUnweighted / totalCredits).toStringAsFixed(2)
          : '3.88',
      'weighted': totalCredits > 0
          ? (totalWeighted / totalCredits).toStringAsFixed(2)
          : '4.12',
    };
  }

  // Setters & Actions
  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setAccent(KiteAccent accent) {
    if (_accent != accent) {
      _accent = accent;
      notifyListeners();
    }
  }

  void setActiveChannel(String channelId) {
    _activeChannelId = channelId;
    _channels = _channels.map((c) {
      if (c.id == channelId) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();
    notifyListeners();
  }

  void inquireAssignment(Course course, Assignment assignment) {
    _pendingInquiryContext = {
      'course': course,
      'assignment': assignment,
    };
    _currentTab = 3; // Switch to Feature Previews Tab
    notifyListeners();
  }

  void clearInquiryContext() {
    _pendingInquiryContext = null;
    notifyListeners();
  }

  void dismissToast() {
    _toastTimer?.cancel();
    _activeToast = null;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void _showToast(NotificationItem notif) {
    if (_soundEnabled) {
      NotificationService.playNotificationChime();
    }
    _activeToast = notif;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 4500), () {
      _activeToast = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void markAllNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  void markNotificationRead(String id) {
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(read: true) : n)
        .toList();
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications = _notifications.where((n) => n.id != id).toList();
    notifyListeners();
  }

  void simulateNotification(String preset) {
    const timestamp = 'Just now';
    NotificationItem newNotif;

    if (preset == 'grade') {
      newNotif = NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Grade Posted: AP Physics Exam',
        message:
            'Dr. Sarah Jenkins graded "Unit 5 Test: Simple Harmonic Motion" with 92/100 (A-). Feedback rubric available.',
        timestamp: timestamp,
        category: NotificationCategory.grade,
        priority: NotificationPriority.high,
        read: false,
        courseCode: 'PHYS-302',
        senderName: 'Dr. Sarah Jenkins',
        senderAvatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
      );
    } else if (preset == 'message') {
      newNotif = NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Secure Message from Dr. Vance',
        message:
            '"I reviewed your recursive tree rotation test cases. Looks solid for the capstone proposal!"',
        timestamp: timestamp,
        category: NotificationCategory.message,
        priority: NotificationPriority.medium,
        read: false,
        courseCode: 'CS-301',
        senderName: 'Dr. Eleanor Vance',
        senderAvatar:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
      );
    } else if (preset == 'emergency') {
      newNotif = NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'URGENT: Weather Alert & Early Dismissal',
        message:
            'All after-school laboratory sessions and athletics rescheduled due to regional storm advisory.',
        timestamp: timestamp,
        category: NotificationCategory.emergency,
        priority: NotificationPriority.urgent,
        read: false,
        senderName: 'Lincoln High Administration',
      );
    } else {
      newNotif = NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Class Notice: AP Calculus BC Study Session',
        message:
            'Prof. Marcus Chen announced extra office hours this Thursday at 3:30 PM in Hall B-210.',
        timestamp: timestamp,
        category: NotificationCategory.announcement,
        priority: NotificationPriority.medium,
        read: false,
        courseCode: 'MATH-401',
        senderName: 'Prof. Marcus Chen',
      );
    }

    _notifications.insert(0, newNotif);
    _showToast(newNotif);
  }

  void broadcastAnnouncement({
    required String title,
    required String message,
    required NotificationPriority priority,
    required String target,
  }) {
    final newNotif = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: '[Broadcast to $target] $title',
      message: message,
      timestamp: 'Just now',
      category: NotificationCategory.announcement,
      priority: priority,
      read: false,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatar,
    );

    _notifications.insert(0, newNotif);
    _showToast(newNotif);
  }

  void sendMessage({
    required String channelId,
    required String content,
    ChatContextTag? contextTag,
    ChatAttachment? attachment,
  }) {
    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderRole: _currentRole,
      senderAvatar: currentUser.avatar,
      content: content,
      timestamp: 'Just now',
      isEncrypted: true,
      status: 'delivered',
      contextTag: contextTag,
      attachment: attachment,
    );

    final currentChannelMsgs =
        List<ChatMessage>.from(_messages[channelId] ?? []);
    currentChannelMsgs.add(newMsg);
    _messages[channelId] = currentChannelMsgs;

    // Update last message in channel preview
    _channels = _channels.map((c) {
      if (c.id == channelId) {
        return c.copyWith(
          lastMessage: ChatLastMessage(
            text: content,
            timestamp: 'Just now',
            senderId: currentUser.id,
          ),
        );
      }
      return c;
    }).toList();

    notifyListeners();

    // Auto-reply simulation if student
    if (_currentRole == UserRole.student) {
      Timer(const Duration(milliseconds: 1800), () {
        final autoReply = ChatMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user_teacher_1',
          senderName: 'Dr. Eleanor Vance',
          senderRole: UserRole.teacher,
          senderAvatar:
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
          content:
              'Thank you for following up, Alex! I’ve reviewed your note and logged it into the grade tracking portal.',
          timestamp: 'Just now',
          isEncrypted: true,
          status: 'delivered',
        );

        final updatedMsgs = List<ChatMessage>.from(_messages[channelId] ?? []);
        updatedMsgs.add(autoReply);
        _messages[channelId] = updatedMsgs;

        final notif = NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Dr. Vance replied to your message',
          message:
              'Thank you for following up, Alex! I’ve reviewed your note and logged it into the portal.',
          timestamp: 'Just now',
          category: NotificationCategory.message,
          priority: NotificationPriority.medium,
          read: false,
          courseCode: 'CS-301',
          senderName: 'Dr. Eleanor Vance',
          senderAvatar:
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
        );

        _notifications.insert(0, notif);
        _showToast(notif);
      });
    }
  }

  void updateCourseGrade({
    required String courseId,
    required String assignmentId,
    required double newScore,
  }) {
    _courses = _courses.map((course) {
      if (course.id == courseId) {
        final updatedAssignments = course.assignments.map((asg) {
          if (asg.id == assignmentId) {
            return asg.copyWith(score: newScore);
          }
          return asg;
        }).toList();

        // Recalculate average percentage
        double earnedPoints = 0;
        double maxPoints = 0;
        for (var a in updatedAssignments) {
          earnedPoints += a.score;
          maxPoints += a.maxScore;
        }
        final newPct = maxPoints > 0
            ? (earnedPoints / maxPoints) * 100
            : course.currentPercentage;

        String letter = 'A';
        if (newPct >= 97) {
          letter = 'A+';
        } else if (newPct >= 93) {
          letter = 'A';
        } else if (newPct >= 90) {
          letter = 'A-';
        } else if (newPct >= 87) {
          letter = 'B+';
        } else if (newPct >= 83) {
          letter = 'B';
        } else if (newPct >= 80) {
          letter = 'B-';
        } else if (newPct >= 75) {
          letter = 'C+';
        } else {
          letter = 'C';
        }

        return course.copyWith(
          assignments: updatedAssignments,
          currentPercentage: double.parse(newPct.toStringAsFixed(1)),
          letterGrade: letter,
        );
      }
      return course;
    }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
