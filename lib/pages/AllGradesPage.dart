import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:stads/pages/CourseDetailsPage.dart';

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

  DateTime getDate(String stringDate) {
    String day = stringDate.substring(0, 2);
    String month = stringDate.substring(3, 5);
    String year = stringDate.substring(6, 10);
    String date = "$year-$month-$day";
    DateTime asDate = DateTime.parse(date);
    return asDate;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: courseGradeBox.listenable(),
        builder: (context, Box<CourseGrade> courseGrades, widget) {
          if (courseGrades.isEmpty) {
            return const Center(
              child: Text("You currently have no grades!"),
            );
          } else {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 18),
                  color: Theme.of(context).colorScheme.background,
                  padding: const EdgeInsets.only(bottom: 9),
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
                  child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).colorScheme.background,
                          height: 5),
                      itemCount: courseGrades.length,
                      itemBuilder: (context, index) {
                        var currentBox = courseGrades;
                        List<CourseGrade> grades = currentBox.values.toList();
                        grades.sort(
                          (a, b) => getDate(b.dateString)
                              .compareTo(getDate(a.dateString)),
                        );
                        CourseGrade gradeData = grades[index];
                        return ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            tileColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            titleAlignment: ListTileTitleAlignment.center,
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 20),
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
                            onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseDetailsPage(
                                            gradeData: gradeData),
                                      ))
                                });
                      }),
                )
              ],
            );
          }
        });
  }
}
