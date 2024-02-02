import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final Box<CourseGrade> courseGradeBox;
  late List<CourseGrade> courseGradesList;
  List<FlSpot> dataPoints = [];
  double maxAverage = 0;
  int passedECTS = 0;
  double currentAverage = 0;
  double weightedAverage = 0;
  @override
  void initState() {
    super.initState();
    courseGradeBox = Hive.box(HiveBoxes.coursegrades);
    courseGradesList = courseGradeBox.values.toList();
    courseGradesList.sort(
      (a, b) => getDate(b.dateString).compareTo(getDate(a.dateString)),
    );
    calculateECTS();
    calculateWeightedAverage();
    calculateAveragePoints();
  }

  DateTime getDate(String stringDate) {
    String day = stringDate.substring(0, 2);
    String month = stringDate.substring(3, 5);
    String year = stringDate.substring(6, 10);
    String date = "$year-$month-$day";
    DateTime asDate = DateTime.parse(date);
    return asDate;
  }

  void calculateECTS() {
    for (CourseGrade grade in courseGradesList) {
      passedECTS += grade.ECTS;
    }
  }

  void calculateWeightedAverage() {
    double weightedTotal = 0;
    double totalECTS = 0;
    for (CourseGrade grade in courseGradesList) {
      double score = double.tryParse(grade.grade) ?? 0;
      if (score != 0) {
        totalECTS += grade.ECTS;
        weightedTotal += score * grade.ECTS;
      }
    }

    weightedAverage =
        double.parse((weightedTotal / totalECTS).toStringAsFixed(2));
  }

  void calculateAveragePoints() {
    if (courseGradesList.isNotEmpty) {
      double minSemester = courseGradesList.last.semester.toDouble();
      double maxSemester = courseGradesList.first.semester.toDouble();

      for (double i = minSemester; i <= maxSemester; i++) {
        double totalSum = 0;
        int gradeCount = 0;

        for (CourseGrade grade in courseGradesList) {
          if (grade.semester <= i) {
            double gradeValue = double.tryParse(grade.grade) ?? 0;
            if (gradeValue != 0) {
              gradeCount++;
            }
            totalSum += gradeValue;
          }
        }

        double semesterAverage = (gradeCount != 0) ? totalSum / gradeCount : 0;
        semesterAverage = double.parse(semesterAverage.toStringAsFixed(2));
        if (semesterAverage > maxAverage) {
          maxAverage = semesterAverage;
        }
        dataPoints.add(FlSpot(i, semesterAverage));
      }
      currentAverage = double.parse((dataPoints.last.y).toStringAsFixed(2));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Theme.of(context).colorScheme.primary,
      Color.lerp(Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.background, 0.65) ??
          Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.background
    ];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 18),
          alignment: Alignment.centerLeft,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Your",
                style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSecondary)),
            Text("Statistics",
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground))
          ]),
        ),
        (!dataPoints.isEmpty)
            ? Expanded(
                child: Container(
                    child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: dataPoints.length.toDouble() - 1,
                    minY: 0,
                    maxY: maxAverage.ceilToDouble(),
                    lineBarsData: [
                      LineChartBarData(
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          spots: dataPoints,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.secondary,
                          dotData: FlDotData(
                            getDotPainter: (p0, p1, p2, p3) {
                              return FlDotCirclePainter(
                                  color: Colors.white,
                                  strokeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  strokeWidth: 2);
                            },
                          )),
                    ],
                  ),
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 150),
                ),
              )))
            : Center(child: Text("no data")),
        Container(
          height: 300,
          padding: EdgeInsets.only(top: 24),
          child: Column(children: [
            /*
            
                Number of passed ECTS
            
             */
            Container(
                padding: EdgeInsets.only(bottom: 15),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Passed ECTS",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 18),
                    ),
                    Text(
                      "$passedECTS",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ],
                )),
            /*
            
                Current Average Grade

             */
            Container(
                padding: EdgeInsets.only(bottom: 15),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Average",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 18),
                    ),
                    Text(
                      "$currentAverage",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ],
                )),

            /* 
            
                Weighed Average
            
            */
            Container(
                padding: EdgeInsets.only(bottom: 15),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weighed Average",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 18),
                    ),
                    Text(
                      "$weightedAverage",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ],
                )),
          ]),
        ),
      ],
    );
  }
}
