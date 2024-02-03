// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'coursegrade.g.dart';

@HiveType(typeId: 1)
class CourseGrade {
  CourseGrade({
    required this.course,
    required this.grade,
    required this.semester,
    required this.dateString,
    required this.ECTS,
    required this.gradeFreqs,
    required this.amount,
    required this.isNumberGrade,
  });
  @HiveField(0)
  String course;

  @HiveField(1)
  String grade;

  @HiveField(2)
  int semester;

  @HiveField(3)
  String dateString;

  @HiveField(4)
  int ECTS;

  @HiveField(5)
  List<int> gradeFreqs;

  @HiveField(6)
  int amount;

  @HiveField(7)
  bool isNumberGrade;
}
