import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final Box<CourseGrade> courseGradeBox;

  @override
  void initState() {
    super.initState();
    courseGradeBox = Hive.box(HiveBoxes.coursegrades);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Statistics will be here"),
    );
  }
}
