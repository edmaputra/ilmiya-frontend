enum UserRole {
  student,
  teacher,
  parent,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

class GpaInfo {
  final double unweighted;
  final double weighted;
  final String trend; // 'up', 'down', 'stable'
  final String classRank;

  const GpaInfo({
    required this.unweighted,
    required this.weighted,
    required this.trend,
    required this.classRank,
  });
}

class UserProfile {
  final String id;
  final String name;
  final UserRole role;
  final String avatar;
  final String email;
  final String schoolId;
  final String? gradeLevel;
  final String? department;
  final GpaInfo? gpa;
  final int unreadNotifications;
  final int unreadMessages;

  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.email,
    required this.schoolId,
    this.gradeLevel,
    this.department,
    this.gpa,
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? avatar,
    String? email,
    String? schoolId,
    String? gradeLevel,
    String? department,
    GpaInfo? gpa,
    int? unreadNotifications,
    int? unreadMessages,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      department: department ?? this.department,
      gpa: gpa ?? this.gpa,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
}
