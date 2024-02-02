import 'dart:convert';
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

  // Grade Fetcher
  Future<bool> fetchGrades() async {
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
              final courseName = unescape.convert(row.children[0].innerHtml);
              if (!box.containsKey(courseName)) {
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
                final outerTable =
                    document.getElementsByClassName('Resdetaljer')[0];
                int antal = 0;
                List<int> gradeFrequencies = [];
                bool isNumberGrade = !RegExp(r'[a-zA-Z]').hasMatch(grade);
                var antalTd = outerTable.children[0].children[7].children[2];
                antal = int.parse(antalTd.innerHtml);
                // If the grade is a number grade e.g. 7, 10 or 12..
                if (isNumberGrade) {
                  var frequenciesTr = outerTable
                      .children[0]
                      .children[10]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0]
                      .children[0];
                  for (int frequencyIndex = 1;
                      frequencyIndex <= 7;
                      frequencyIndex++) {
                    gradeFrequencies.add(int.parse(frequenciesTr
                        .children[frequencyIndex]
                        .children[0]
                        .attributes['title']!
                        .substring(
                            0,
                            frequenciesTr.children[frequencyIndex].children[0]
                                .attributes['title']!
                                .indexOf('('))));
                  }
                }
                // If the grade is a letter e.g. B, I or U..
                else {
                  var frequenciesTr = outerTable
                      .children[0]
                      .children[9]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0]
                      .children[1]
                      .children[0]
                      .children[0]
                      .children[0];
                  for (int frequencyIndex = 1;
                      frequencyIndex <=
                          (frequenciesTr.children.length == 6 ? 4 : 3);
                      frequencyIndex++) {
                    gradeFrequencies.add(int.parse(frequenciesTr
                        .children[frequencyIndex]
                        .children[0]
                        .attributes['title']!
                        .substring(
                            0,
                            frequenciesTr.children[frequencyIndex].children[0]
                                .attributes['title']!
                                .indexOf('('))));
                  }
                }
                if (courseName.contains('Analyse') ||
                    courseName.contains('Problembaseret')) {
                  gradeFrequencies.forEach((element) {
                    print(element);
                  });
                }
                final courseGrade = CourseGrade(
                  course: unescape.convert(row.children[0].innerHtml).trim(),
                  grade: grade,
                  semester: semester,
                  dateString: row.children[1].innerHtml,
                  ECTS: double.parse(ectsString).toInt(),
                  gradeFreqs: gradeFrequencies,
                  amount: antal,
                  isNumberGrade: isNumberGrade,
                );
                courses[row.children[0].innerHtml] = courseGrade;
                box.put(courseName, courseGrade);
              }
              index--;
            }
          }

          if (sendNotification && SettingsProvider().notificationsEnabled) {
            SendGradeNotification(notificationText);
            dio.close();
          }
        } catch (e) {
          print('error in fetchGrades');
          print(e);
        }

        return true;
      } else {
        print("user not logged in");
        return false;
      }
    }
    print('user not logged in');
    return false;
  }
}
