import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:html/parser.dart' as html;
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:stads/providers/AuthProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:stads/providers/SettingsProvider.dart';

class StadsGradesProvider extends ChangeNotifier {
  // Notification Sender
  void SendGradeNotification(String course) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 0,
      channelKey: 'stads_channel',
      body: "You just received a new grade in $course!",
      title: "NEW GRADE ALERT!",
    ));
  }

  void clearDb() async {
    Box<CourseGrade> box = Hive.box(HiveBoxes.coursegrades);
    box.clear();
    weightedAverage = 0;
    passedECTS = 0;
    dataPoints = [];
    courseGradesList = [];
    maxAverage = 0;
    currentAverage = 0;

    notifyListeners();
  }

  bool currentlyFetching = false;
  bool isUpdatingStats = false;
  double weightedAverage = 0;
  int passedECTS = 0;
  List<FlSpot> dataPoints = [];
  List<CourseGrade> courseGradesList = [];
  double maxAverage = 0;
  double currentAverage = 0;

  Future<void> updateStats() async {
    Box<CourseGrade> courseGradeBox = await Hive.box(HiveBoxes.coursegrades);
    if (!isUpdatingStats) {
      isUpdatingStats = true;
      courseGradesList = courseGradeBox.values.toList();
      courseGradesList.sort(
        (a, b) => getDate(b.dateString).compareTo(getDate(a.dateString)),
      );
      int passedectses = await calculateECTS();
      double wAverage = await calculateWeightedAverage();
      List<FlSpot> dPoints = await calculateAveragePoints();
      isUpdatingStats = false;
      passedECTS = passedectses;
      weightedAverage = wAverage;
      dataPoints = dPoints;
      isUpdatingStats = false;
      notifyListeners();
    }
  }

  DateTime getDate(String stringDate) {
    String day = stringDate.substring(0, 2);
    String month = stringDate.substring(3, 5);
    String year = stringDate.substring(6, 10);
    String date = "$year-$month-$day";
    DateTime asDate = DateTime.parse(date);
    return asDate;
  }

  Future<int> calculateECTS() async {
    passedECTS = 0;
    for (CourseGrade grade in courseGradesList) {
      if (grade.include) {
        passedECTS += grade.ECTS;
      }
    }
    return passedECTS;
  }

  Future<double> calculateWeightedAverage() async {
    double weightedTotal = 0;
    double totalECTS = 0;
    for (CourseGrade grade in courseGradesList) {
      if (grade.include) {
        double score = double.tryParse(grade.grade) ?? 0;
        if (score != 0) {
          totalECTS += grade.ECTS;
          weightedTotal += score * grade.ECTS;
        }
      }
    }

    weightedAverage =
        double.parse((weightedTotal / totalECTS).toStringAsFixed(2));
    return weightedAverage;
  }

  Future<List<FlSpot>> calculateAveragePoints() async {
    List<FlSpot> dPoints = [];
    _isNumeric(String string) {
      final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
      return numericRegex.hasMatch(string);
    }

    if (courseGradesList.isNotEmpty) {
      double minSemester = courseGradesList.last.semester.toDouble();
      double maxSemester = courseGradesList.first.semester.toDouble();

      for (double i = minSemester; i <= maxSemester; i++) {
        double totalSum = 0;
        double gradeCount = 0;
        for (CourseGrade grade in courseGradesList) {
          if (grade.include) {
            if (grade.semester <= i) {
              double gradeVal;
              if (_isNumeric(grade.grade)) {
                gradeVal = double.tryParse(grade.grade) ?? 0;
                if (gradeVal != 0) {
                  gradeCount++;
                }
                totalSum += gradeVal;
              }
            }
          }
        }

        double semesterAverage = (gradeCount > 0) ? totalSum / gradeCount : 0;
        semesterAverage = double.parse(semesterAverage.toStringAsFixed(2));
        if (semesterAverage > maxAverage) {
          maxAverage = semesterAverage;
        }
        currentAverage = semesterAverage;
        dPoints.add(FlSpot(i, semesterAverage));
      }
    }
    return dPoints;
  }

  // Grade Fetcher
  Future<bool> fetchGrades() async {
    if (!currentlyFetching) {
      currentlyFetching = true;
      var unescape = HtmlUnescape();
      Box<CourseGrade> box = Hive.box<CourseGrade>(HiveBoxes.coursegrades);
      const String gradesPage =
          "https://sb.aau.dk/sb-ad/sb/resultater/studresultater.jsp";
      const String gradeDetailsUrl =
          "https://sb.aau.dk/sb-ad/sb/resultater/visStatistik.jsp?";
      final AuthProvider auth = AuthProvider();
      final dio = Dio();
      (String?, String?) login = await AuthProvider().getUserLogin();

      String getGradeSeason(String stringDate) {
        int gradeMonth = int.parse(stringDate.substring(3, 5));
        if (1 <= gradeMonth && gradeMonth <= 3) {
          return "Winter";
        } else if (6 <= gradeMonth && gradeMonth <= 9) {
          return "Summer";
        } else {
          return "Autumn";
        }
      }

      if (login.$1 != null && login.$2 != null) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        final cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath + "/.cookies/"),
        );
        dio.interceptors.add(CookieManager(cookieJar));
        await AuthProvider().login(login.$1!, login.$2!);

        if (await auth.isLoggedIn()) {
          try {
            Map<String, CourseGrade> courses = {};
            var responseRaw = await dio.get(gradesPage,
                options: Options(
                  responseType: ResponseType.bytes,
                ));
            var response = latin1.decode(responseRaw.data!);
            var document = html.parse(response);
            final table = document.getElementById('resultTable');
            final tableBody = table!.getElementsByTagName('tbody');
            final tableRows = tableBody[0].getElementsByTagName('tr');
            var sendNotification = false;
            var notificationText;
            CourseGrade? latestAddedGrade;

            if (box.isEmpty) {
              latestAddedGrade = null;
            } else {
              latestAddedGrade = box.getAt(box.length - 1);
            }
            int lastGradeSemester = -1;
            String lastGradeSeason = "";

            if (latestAddedGrade != null) {
              lastGradeSemester = latestAddedGrade.semester;
              lastGradeSeason = getGradeSeason(latestAddedGrade.dateString);
            }

            if (!(tableRows.length == box.length)) {
              int index = tableRows.length - 1;
              for (var row in tableRows.reversed) {
                final courseName =
                    unescape.convert(row.children[0].innerHtml).trim();
                int courseKeyIndex = 0;
                bool rexamFound = false;
                sendNotification = true;
                notificationText = courseName;
                String currentGradeSeason =
                    getGradeSeason(row.children[1].innerHtml);
                int semester;

                if (lastGradeSemester == -1) {
                  lastGradeSemester = 0;
                  semester = 0;
                  lastGradeSeason = currentGradeSeason;
                } else {
                  if (currentGradeSeason == lastGradeSeason) {
                    semester = lastGradeSemester;
                  } else {
                    semester = ++lastGradeSemester;
                    lastGradeSeason = currentGradeSeason;
                  }
                }

                String ectsString = row.children[4].innerHtml;
                if (ectsString.contains('&nbsp;')) {
                  ectsString = ectsString.replaceAll('&nbsp;', '');
                }

                /* 
                
                    FETCHING EXTRA DETAILS ABOUT THE COURSE
                
                 */
                responseRaw = await dio.get(gradeDetailsUrl + 'id=${index}',
                    options: Options(
                      responseType: ResponseType.bytes,
                    ));
                var response = latin1.decode(responseRaw.data!);
                var document = html.parse(response);
                final grade = row.children[2].innerHtml;
                if (document.getElementsByClassName('Resdetaljer').isNotEmpty) {
                  final outerTable = document
                      .getElementsByClassName('Resdetaljer')[0]
                      .children[0];
                  int antal = 0;
                  List<int> gradeFrequencies = [];
                  List<String> gradeLabels = [];
                  var antalTd = outerTable.children[7].children[2];
                  antal = int.parse(antalTd.innerHtml);
                  var gradesTable = outerTable
                      .children[outerTable.children.length - 1]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0];
                  var freqsTable = gradesTable.children[0];
                  var labelsTable =
                      gradesTable.children[gradesTable.children.length - 1];
                  // Fetch Grade Frequencies
                  for (int i = 1; i <= freqsTable.children.length - 2; i++) {
                    int freq = int.parse(freqsTable
                        .children[i].children[0].attributes['title']!
                        .substring(
                            0,
                            freqsTable
                                .children[i].children[0].attributes['title']!
                                .indexOf('(')));
                    gradeFrequencies.add(freq);
                  }

                  // Fetch Grade Labels
                  for (int i = 1; i <= labelsTable.children.length - 2; i++) {
                    gradeLabels.add(labelsTable.children[i].innerHtml);
                  }

                  final courseGrade = CourseGrade(
                    course: unescape.convert(row.children[0].innerHtml).trim(),
                    grade: grade,
                    semester: semester,
                    dateString: row.children[1].innerHtml,
                    ECTS: double.parse(ectsString).toInt(),
                    gradeFreqs: gradeFrequencies,
                    amount: antal,
                    gradeLabels: gradeLabels,
                    include: true,
                  );

                  if (box.containsKey(courseName)) {
                    if (box.get(courseName)!.dateString !=
                        courseGrade.dateString) {
                      rexamFound = true;
                      var oldGrade = box.get(courseName);
                      oldGrade!.include = false;
                      oldGrade.save();
                    }
                    while (box.containsKey("$courseName$courseKeyIndex") &&
                        !rexamFound) {
                      if (box.get("$courseName$courseKeyIndex")!.dateString !=
                          courseGrade.dateString) {
                        rexamFound = true;
                        int oldIndexes = 0;
                        while (box.containsKey("$courseName$oldIndexes")) {
                          var oldGrade = box.get("$courseName$oldIndexes");
                          oldGrade!.include = false;
                          oldGrade.save();
                        }
                      } else {
                        rexamFound = false;
                      }
                      courseKeyIndex++;
                    }
                    if (!rexamFound) {
                      continue;
                    }
                  }
                  courses[row.children[0].innerHtml] = courseGrade;
                  box.put(
                      rexamFound ? "$courseName$courseKeyIndex" : courseName,
                      courseGrade);
                } else {
                  final courseGrade = CourseGrade(
                    course: unescape.convert(row.children[0].innerHtml).trim(),
                    grade: grade,
                    semester: semester,
                    dateString: row.children[1].innerHtml,
                    ECTS: double.parse(ectsString).toInt(),
                    gradeFreqs: [],
                    amount: 0,
                    gradeLabels: [],
                    include: true,
                  );
                  courses[row.children[0].innerHtml] = courseGrade;
                  box.put(
                      rexamFound ? "$courseName$courseKeyIndex" : courseName,
                      courseGrade);
                }
                index--;
              }
            }

            if (sendNotification && SettingsProvider().notificationsEnabled) {
              SendGradeNotification(notificationText);
              dio.close();
            }
            await updateStats();
            notifyListeners();
          } catch (e) {
            currentlyFetching = false;

            print('error in fetchGrades');
            print(e);
          }
          currentlyFetching = false;

          return true;
        } else {
          print("user not logged in");
          currentlyFetching = false;

          return false;
        }
      }
      print('user not logged in');
      currentlyFetching = false;
      return false;
    } else {
      return false;
    }
  }
}
