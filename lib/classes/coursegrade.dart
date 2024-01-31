import 'package:hive/hive.dart';

part 'coursegrade.g.dart';

@HiveType(typeId: 1)
class CourseGrade {
  CourseGrade({
    required this.course,
    required this.grade,
  });
  @HiveField(0)
  String course;

  @HiveField(1)
  String grade;
}
