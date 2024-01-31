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
    return ValueListenableBuilder(
        valueListenable: courseGradeBox.listenable(),
        builder: (context, Box courseGrades, widget) {
          if (courseGrades.isEmpty) {
            return Center(
              child: Text("You currently have no grades!"),
            );
          } else {
            return ListView.builder(
                itemCount: courseGrades.length,
                itemBuilder: (context, index) {
                  var currentBox = courseGrades;
                  CourseGrade gradeData = currentBox.getAt(index);
                  return ListTile(title: Text(gradeData.course));
                });
          }
        });
  }
}
