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

class StadsGradesProvider extends ChangeNotifier {
  // Grade Auto fetcher
  void autoFetchGrades() {}
  // Grade Fetch On Startup
  void fetchOnStartup() async {
    final Box<CourseGrade> box = Hive.box(HiveBoxes.coursegrades);
    try {
      await fetchGrades();
    } catch (error) {
      print(error);
    }
    print("fetched on startup");
  }

  Future<bool> fetchGrades() async {
    var unescape = new HtmlUnescape();
    Box<CourseGrade> box = Hive.box<CourseGrade>(HiveBoxes.coursegrades);
    const String gradesPage =
        "https://sb.aau.dk/sb-ad/sb/resultater/studresultater.jsp";
    final AuthProvider auth = AuthProvider();
    final dio = Dio();
    (String, String) login = await AuthProvider().getUserLogin();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(appDocPath + "/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));
    await AuthProvider().login(login.$1, login.$2);
    if (await auth.isLoggedIn()) {
      try {
        Map<String, CourseGrade> courses = {};
        final responseRaw = await dio.get(gradesPage,
            options: Options(
              responseType: ResponseType.bytes,
            ));
        final response = latin1.decode(responseRaw.data!);
        final document = html.parse(response);
        final table = document.getElementById('resultTable');
        final tableBody = table!.getElementsByTagName('tbody');
        final tableRows = tableBody[0].getElementsByTagName('tr');
        if (!(tableRows.length == box.length)) {
          for (var row in tableRows) {
            final courseName = unescape.convert(row.children[0].innerHtml);
            final courseGrade = row.children[2].innerHtml;
            if (!box.containsKey(courseName)) {
              final grade = CourseGrade(
                  course: unescape.convert(row.children[0].innerHtml),
                  grade: row.children[2].innerHtml);
              courses[row.children[0].innerHtml] = grade;
              box.put(courseName, grade);
              SendGradeNotification(courseName);
            }
          }
        }
      } catch (e) {
        print(e);
      }

      return true;
    } else {
      print("user not logged in");
      return false;
    }
  }

  // Grade Fetch interval (in minutes)
  int fetchInterval = 15;

  // Notifications Enabled
  bool notificationsEnabled = true;

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
}
