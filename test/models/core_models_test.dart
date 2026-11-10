import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/chat_message.dart';
import 'package:ilmiya_app/core/models/course.dart';
import 'package:ilmiya_app/core/models/notification_item.dart';
import 'package:ilmiya_app/core/models/user_profile.dart';

void main() {
  group('UserProfile and UserRole Models', () {
    test('UserRole displayName returns appropriate title', () {
      expect(UserRole.student.displayName, equals('Student'));
      expect(UserRole.teacher.displayName, equals('Teacher'));
      expect(UserRole.parent.displayName, equals('Parent'));
      expect(UserRole.admin.displayName, equals('Administrator'));
    });

    test('GpaInfo holds data correctly', () {
      const gpa = GpaInfo(
        unweighted: 3.85,
        weighted: 4.12,
        trend: 'up',
        classRank: 'Top 5%',
      );
      expect(gpa.unweighted, equals(3.85));
      expect(gpa.weighted, equals(4.12));
      expect(gpa.trend, equals('up'));
      expect(gpa.classRank, equals('Top 5%'));
    });

    test('UserProfile copyWith updates selected fields', () {
      const profile = UserProfile(
        id: 'user-001',
        name: 'Jane Doe',
        role: UserRole.student,
        avatar: 'avatar.png',
        email: 'jane@ilmiya.edu',
        schoolId: 'school-1',
        gradeLevel: '10th',
        department: 'Science',
        unreadNotifications: 2,
        unreadMessages: 1,
      );

      final updated = profile.copyWith(
        name: 'Jane Smith',
        unreadNotifications: 5,
        unreadMessages: 3,
        gradeLevel: '11th',
        department: 'Arts',
      );

      expect(updated.id, equals('user-001'));
      expect(updated.name, equals('Jane Smith'));
      expect(updated.unreadNotifications, equals(5));
      expect(updated.unreadMessages, equals(3));
      expect(updated.gradeLevel, equals('11th'));
      expect(updated.department, equals('Arts'));
      expect(updated.role, equals(UserRole.student));

      // Test copyWith with no arguments to exercise default fallback branches
      final unchanged = profile.copyWith();
      expect(unchanged.name, equals(profile.name));
      expect(unchanged.gradeLevel, equals(profile.gradeLevel));
      expect(unchanged.department, equals(profile.department));
      expect(
          unchanged.unreadNotifications, equals(profile.unreadNotifications));
      expect(unchanged.unreadMessages, equals(profile.unreadMessages));
    });
  });

  group('ChatMessage Models', () {
    test('ChatAttachment and ChatContextTag retain properties', () {
      const attachment = ChatAttachment(
        name: 'syllabus.pdf',
        type: 'pdf',
        size: '1.2 MB',
        url: 'https://example.com/syllabus.pdf',
      );
      expect(attachment.name, equals('syllabus.pdf'));
      expect(attachment.type, equals('pdf'));
      expect(attachment.size, equals('1.2 MB'));
      expect(attachment.url, equals('https://example.com/syllabus.pdf'));

      const contextTag = ChatContextTag(
        type: 'assignment',
        title: 'Midterm Essay',
        id: 'assign-101',
      );
      expect(contextTag.type, equals('assignment'));
      expect(contextTag.title, equals('Midterm Essay'));
      expect(contextTag.id, equals('assign-101'));
    });

    test('ChatMessage copyWith creates accurate clones', () {
      const message = ChatMessage(
        id: 'msg-01',
        senderId: 'user-01',
        senderName: 'Alex',
        senderRole: UserRole.student,
        senderAvatar: 'alex.png',
        content: 'Hello World',
        timestamp: '10:00 AM',
      );

      final cloned = message.copyWith(
        content: 'Updated Content',
        status: 'read',
        isEncrypted: false,
      );

      expect(cloned.id, equals('msg-01'));
      expect(cloned.senderId, equals('user-01'));
      expect(cloned.senderName, equals('Alex'));
      expect(cloned.content, equals('Updated Content'));
      expect(cloned.status, equals('read'));
      expect(cloned.isEncrypted, isFalse);
    });

    test('ChatParticipant, ChatLastMessage, ChatChannel copyWith', () {
      const participant = ChatParticipant(
        id: 'p-1',
        name: 'Marcus',
        role: UserRole.teacher,
        avatar: 'marcus.png',
        online: true,
      );
      expect(participant.name, equals('Marcus'));
      expect(participant.online, isTrue);

      const lastMsg = ChatLastMessage(
        text: 'Class starts soon',
        timestamp: '09:00 AM',
        senderId: 'p-1',
      );
      expect(lastMsg.text, equals('Class starts soon'));

      const channel = ChatChannel(
        id: 'chan-01',
        name: 'Math 101',
        type: 'class_group',
        participants: [participant],
        courseCode: 'MATH101',
        lastMessage: lastMsg,
        unreadCount: 1,
      );

      final clonedChannel = channel.copyWith(
        name: 'Math 101 Honors',
        unreadCount: 0,
      );
      expect(clonedChannel.name, equals('Math 101 Honors'));
      expect(clonedChannel.unreadCount, equals(0));
      expect(clonedChannel.courseCode, equals('MATH101'));
      expect(clonedChannel.lastMessage, equals(lastMsg));
    });
  });

  group('NotificationItem Models', () {
    test('NotificationCategory displayName', () {
      expect(NotificationCategory.grade.displayName, equals('Academic Grade'));
      expect(NotificationCategory.message.displayName, equals('Message'));
      expect(NotificationCategory.announcement.displayName,
          equals('Announcement'));
      expect(NotificationCategory.attendance.displayName, equals('Attendance'));
      expect(
          NotificationCategory.emergency.displayName, equals('Urgent Alert'));
    });

    test('NotificationPriority displayName', () {
      expect(NotificationPriority.low.displayName, equals('Low Priority'));
      expect(NotificationPriority.medium.displayName, equals('Standard'));
      expect(NotificationPriority.high.displayName, equals('High Priority'));
      expect(NotificationPriority.urgent.displayName, equals('Urgent'));
    });

    test('NotificationItem copyWith', () {
      const notif = NotificationItem(
        id: 'notif-1',
        title: 'Grade Updated',
        message: 'Your physics quiz has been graded.',
        timestamp: '10m ago',
        category: NotificationCategory.grade,
        priority: NotificationPriority.high,
        read: false,
      );

      final updated = notif.copyWith(
        read: true,
        priority: NotificationPriority.medium,
        actionUrl: '/grades',
      );

      expect(updated.id, equals('notif-1'));
      expect(updated.title, equals('Grade Updated'));
      expect(updated.read, isTrue);
      expect(updated.priority, equals(NotificationPriority.medium));
      expect(updated.actionUrl, equals('/grades'));
    });
  });

  group('Course Models', () {
    test('Course and Assignment copyWith and percentage', () {
      const assignment = Assignment(
        id: 'a-1',
        title: 'Midterm',
        category: 'Exam',
        score: 90.0,
        maxScore: 100.0,
        weight: 30.0,
        dueDate: '2026-10-10',
      );
      expect(assignment.percentage, equals(90.0));

      final clonedAssign = assignment.copyWith(
        score: 95.0,
        status: 'graded',
      );
      expect(clonedAssign.score, equals(95.0));

      const course = Course(
        id: 'c-1',
        code: 'CS101',
        name: 'Intro to CS',
        teacherId: 't-1',
        teacherName: 'Eleanor',
        teacherAvatar: 'eleanor.png',
        period: '1st',
        room: 'Lab 4',
        credits: 3.0,
        currentPercentage: 92.5,
        letterGrade: 'A',
        color: Color(0xFF2563EB),
        iconName: 'code',
        assignments: [assignment],
        categoryWeights: [],
        attendanceRate: 98.0,
        officeHours: 'Mon 2-4 PM',
      );

      final clonedCourse = course.copyWith(
        name: 'Intro to Computer Science',
        currentPercentage: 95.0,
      );

      expect(clonedCourse.code, equals('CS101'));
      expect(clonedCourse.name, equals('Intro to Computer Science'));
      expect(clonedCourse.currentPercentage, equals(95.0));
      expect(clonedCourse.letterGrade, equals('A'));
    });
  });
}
