import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';

class StadsGradesProvider extends ChangeNotifier {
  // Grade Auto fetcher
  void autoFetchGrades() {}
  // Grade Fetch On Startup
  void fetchOnStartup() {
    final Box<CourseGrade> box = Hive.box(HiveBoxes.coursegrades);
    box.add(CourseGrade(course: 'test', grade: '7'));
    print("fetched on startup");
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
