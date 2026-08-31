import 'package:flutter/material.dart';

class RubricScore {
  final String criterion;
  final double score;
  final double max;

  const RubricScore({
    required this.criterion,
    required this.score,
    required this.max,
  });
}

class Assignment {
  final String id;
  final String title;
  final String category; // 'Homework' | 'Quiz' | 'Exam' | 'Project' | 'Lab'
  final double score;
  final double maxScore;
  final double weight; // percentage e.g. 15.0
  final String dueDate;
  final String? submittedDate;
  final String status; // 'graded' | 'pending' | 'missing' | 'late'
  final String? feedback;
  final List<RubricScore>? rubricScores;

  const Assignment({
    required this.id,
    required this.title,
    required this.category,
    required this.score,
    required this.maxScore,
    required this.weight,
    required this.dueDate,
    this.submittedDate,
    this.status = 'graded',
    this.feedback,
    this.rubricScores,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  Assignment copyWith({
    String? id,
    String? title,
    String? category,
    double? score,
    double? maxScore,
    double? weight,
    String? dueDate,
    String? submittedDate,
    String? status,
    String? feedback,
    List<RubricScore>? rubricScores,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      dueDate: dueDate ?? this.dueDate,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      rubricScores: rubricScores ?? this.rubricScores,
    );
  }
}

class CategoryWeight {
  final String category;
  final double weight;
  final double currentAvg;

  const CategoryWeight({
    required this.category,
    required this.weight,
    required this.currentAvg,
  });
}

class Course {
  final String id;
  final String code;
  final String name;
  final String teacherId;
  final String teacherName;
  final String teacherAvatar;
  final String period;
  final String room;
  final double credits;
  final double currentPercentage;
  final String letterGrade;
  final Color color;
  final String iconName;
  final List<Assignment> assignments;
  final List<CategoryWeight> categoryWeights;
  final double attendanceRate;
  final String officeHours;

  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.teacherAvatar,
    required this.period,
    required this.room,
    required this.credits,
    required this.currentPercentage,
    required this.letterGrade,
    required this.color,
    required this.iconName,
    required this.assignments,
    required this.categoryWeights,
    required this.attendanceRate,
    required this.officeHours,
  });

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? teacherId,
    String? teacherName,
    String? teacherAvatar,
    String? period,
    String? room,
    double? credits,
    double? currentPercentage,
    String? letterGrade,
    Color? color,
    String? iconName,
    List<Assignment>? assignments,
    List<CategoryWeight>? categoryWeights,
    double? attendanceRate,
    String? officeHours,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      teacherAvatar: teacherAvatar ?? this.teacherAvatar,
      period: period ?? this.period,
      room: room ?? this.room,
      credits: credits ?? this.credits,
      currentPercentage: currentPercentage ?? this.currentPercentage,
      letterGrade: letterGrade ?? this.letterGrade,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      assignments: assignments ?? this.assignments,
      categoryWeights: categoryWeights ?? this.categoryWeights,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      officeHours: officeHours ?? this.officeHours,
    );
  }
}
