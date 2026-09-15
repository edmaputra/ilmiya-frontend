enum NotificationCategory {
  grade,
  message,
  announcement,
  attendance,
  emergency;

  String get displayName {
    switch (this) {
      case NotificationCategory.grade:
        return 'Academic Grade';
      case NotificationCategory.message:
        return 'Message';
      case NotificationCategory.announcement:
        return 'Announcement';
      case NotificationCategory.attendance:
        return 'Attendance';
      case NotificationCategory.emergency:
        return 'Urgent Alert';
    }
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low Priority';
      case NotificationPriority.medium:
        return 'Standard';
      case NotificationPriority.high:
        return 'High Priority';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationCategory category;
  final NotificationPriority priority;
  final bool read;
  final String? actionUrl;
  final String? courseCode;
  final String? senderName;
  final String? senderAvatar;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.priority = NotificationPriority.medium,
    this.read = false,
    this.actionUrl,
    this.courseCode,
    this.senderName,
    this.senderAvatar,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timestamp,
    NotificationCategory? category,
    NotificationPriority? priority,
    bool? read,
    String? actionUrl,
    String? courseCode,
    String? senderName,
    String? senderAvatar,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      read: read ?? this.read,
      actionUrl: actionUrl ?? this.actionUrl,
      courseCode: courseCode ?? this.courseCode,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }
}
