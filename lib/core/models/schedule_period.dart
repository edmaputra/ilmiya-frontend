import 'package:flutter/material.dart';

class SchedulePeriod {
  final String id;
  final String period;
  final String time;
  final String courseCode;
  final String courseName;
  final String room;
  final String teacher;
  final Color color;
  final String day;

  const SchedulePeriod({
    required this.id,
    required this.period,
    required this.time,
    required this.courseCode,
    required this.courseName,
    required this.room,
    required this.teacher,
    required this.color,
    this.day = 'Mon',
  });
}
