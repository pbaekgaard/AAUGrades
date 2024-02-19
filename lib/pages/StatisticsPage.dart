import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stads/providers/StadsGradeProvider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getGrades();
  }

  Future<void> _getGrades() async {
    Provider.of<StadsGradesProvider>(context).fetchGrades();
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider =
        Provider.of<StadsGradesProvider>(context, listen: false);
    List<Color> gradientColors = [
      Theme.of(context).colorScheme.primary,
      Color.lerp(Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.background, 0.65) ??
          Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.background
    ];

    return ChangeNotifierProvider.value(
        value: gradeProvider,
        child: Consumer<StadsGradesProvider>(
          builder: (context, gProvider, _) {
            return (gradeProvider.dataPoints == null ||
                    gradeProvider.dataPoints!.isEmpty ||
                    gradeProvider.courseGradesList.isEmpty)
                ? const Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "You currently have no grades, or they are being fetched!"),
                      CircularProgressIndicator()
                    ],
                  ))
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 18),
                        alignment: Alignment.centerLeft,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your",
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary)),
                              Text("Statistics",
                                  style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground))
                            ]),
                      ),
                      Expanded(
                          child: Container(
                              child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(show: false),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX:
                                gradeProvider.dataPoints!.length.toDouble() - 1,
                            minY: 0,
                            maxY: gradeProvider.maxAverage.ceilToDouble(),
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
                                  spots: gradeProvider.dataPoints!,
                                  isCurved: true,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  dotData: FlDotData(
                                    getDotPainter: (p0, p1, p2, p3) {
                                      return FlDotCirclePainter(
                                          color: Colors.white,
                                          strokeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          strokeWidth: 2);
                                    },
                                  )),
                            ],
                          ),
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 150),
                        ),
                      ))),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "${gradeProvider.passedECTS}",
                                    style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "${gradeProvider.currentAverage}",
                                    style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "${gradeProvider.weightedAverage}",
                                    style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                ],
                              )),
                        ]),
                      ),
                    ],
                  );
          },
        ));
  }
}
