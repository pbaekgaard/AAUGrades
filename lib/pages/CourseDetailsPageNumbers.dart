// CourseDetailsPage.dart

// ignore_for_file: file_names, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:AAUGrades/classes/coursegrade.dart';
import 'dart:math';

class CourseDetailsPage extends StatefulWidget {
  final CourseGrade gradeData; // Updated parameter

  const CourseDetailsPage({super.key, required this.gradeData});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double barWidth = 12;
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
      TextStyle style = TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      String text;
      switch (value.toInt()) {
        case 0:
          text = '-3';
          break;
        case 1:
          text = '00';
          break;
        case 2:
          text = '02';
          break;
        case 3:
          text = '4';
          break;
        case 4:
          text = '7';
          break;
        case 5:
          text = '10';
          break;
        case 6:
          text = '12';
          break;
        default:
          text = '';
          break;
      }
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
        title: const Text("Course Details"),
        backgroundColor: Theme.of(context).colorScheme.background,
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
            margin: const EdgeInsets.only(bottom: 18),
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
                Text(widget.gradeData.course,
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
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 15),
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
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: [
                      Text(
                        "Grade Frequencies",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500, fontSize: 18),
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
          )
        ]),
      ),
    );
  }
}
