// CourseDetailsPage.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:stads/classes/coursegrade.dart';
import 'dart:math';
import 'package:stads/boxes/boxes.dart';

class CourseDetailsPage extends StatefulWidget {
  CourseGrade gradeData; // Updated parameter

  CourseDetailsPage({required this.gradeData});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Box<CourseGrade> courseGradeBox;
  @override
  void initState() {
    super.initState();
    courseGradeBox = Hive.box(HiveBoxes.coursegrades);
  }

  @override
  Widget build(BuildContext context) {
    double barWidth = 12;
    List<int> frequencies = widget.gradeData.gradeFreqs;

    BarTouchData barTouchData = BarTouchData(
      enabled: false,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 8,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            rod.toY.round().toString(),
            TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );

    Widget getTitlesNumbers(double value, TitleMeta meta) {
      final style = TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      String text;
      text = widget.gradeData.gradeLabels[value.toInt()];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(text, style: style),
      );
    }

    FlBorderData borderData = FlBorderData(
      show: false,
    );

    LinearGradient _barsGradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.primary,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    FlTitlesData titlesDataNumber = FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: getTitlesNumbers,
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );

    List<BarChartGroupData> barGroupsNumbers = List.generate(
      widget.gradeData.gradeFreqs.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: widget.gradeData.gradeFreqs[index].toDouble(),
            gradient: _barsGradient,
            width: barWidth,
          )
        ],
        showingTooltipIndicators: [0],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Course Details"),
        actions: [
          GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.gradeData.include
                        ? "Exclude from statistics calculations"
                        : "Include in statistics calculations"),
                  ),
                );
              },
              child: IconButton(
                icon: widget.gradeData.include
                    ? const Icon(Icons.check)
                    : const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    widget.gradeData.include = !widget.gradeData.include;
                    widget.gradeData.save();
                  });
                },
              ))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        // Use widget.gradeData to access the grade data
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          /*
          
            Course Title

           */
          Container(
            margin: EdgeInsets.only(bottom: 18),
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Course",
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSecondary)),
                Text("${widget.gradeData.course}",
                    style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground))
              ],
            ),
          ),

          /* 
          
            Course Details
          
          */
          Container(
              child:
                  /*
                  
                    Details for Number Grades

                    e.g. 12
                  
                   */
                  Column(
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 15),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Number of participants",
                        style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 18),
                      ),
                      Text(
                        widget.gradeData.amount.toString(),
                        style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )
                    ],
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 25),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          "Grade Frequencies",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: BarChart(
                          BarChartData(
                            barTouchData: barTouchData,
                            titlesData: titlesDataNumber,
                            borderData: borderData,
                            barGroups: barGroupsNumbers,
                            gridData: const FlGridData(show: false),
                            alignment: BarChartAlignment.spaceAround,
                            maxY: widget.gradeData.gradeFreqs
                                    .reduce(max)
                                    .toDouble() *
                                2 /
                                1.5,
                          ),
                        ),
                      )
                    ],
                  )),
            ],
          ))
        ]),
      ),
    );
  }
}
