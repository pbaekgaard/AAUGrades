import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class StadsGradesProvider extends ChangeNotifier {
  // Grade Auto fetcher

  // Grade Fetch On Startup

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
