import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';

class AllGradesPage extends StatefulWidget {
  const AllGradesPage({Key? key}) : super(key: key);

  @override
  _AllGradesPageState createState() => _AllGradesPageState();
}

class _AllGradesPageState extends State<AllGradesPage> {
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
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 18),
                  alignment: Alignment.centerLeft,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your",
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                color:
                                    Theme.of(context).colorScheme.onSecondary)),
                        Text("Grades",
                            style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onBackground))
                      ]),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: courseGrades.length,
                      itemBuilder: (context, index) {
                        var currentBox = courseGrades;
                        CourseGrade gradeData = currentBox.getAt(index);
                        return ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              gradeData.course.length >= 30
                                  ? '${gradeData.course}...'
                                  : gradeData.course,
                              style: GoogleFonts.inter(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            splashColor: Theme.of(context).colorScheme.primary,
                            trailing: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(gradeData.grade,
                                    style: GoogleFonts.inter(fontSize: 14))),
                            onTap: () =>
                                {print('pressed ${gradeData.course}')});
                      }),
                )
              ],
            );
          }
        });
  }
}
