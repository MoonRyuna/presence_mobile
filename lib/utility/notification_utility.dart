import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationUtility {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification
  initializeNotification() async {
    _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    print("INI WAKTU ${scheduleDate.toString()}");
    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Ganti 'your_timezone_here' dengan zona waktu Anda
  }

  /// Scheduled Notification
  scheduledNotification({
    required int hour,
    required int minutes,
    required int id,
    String? sound,
    String? title,
    String? message,
  }) async {
    title ??= 'Default Title'; // Judul default jika tidak ada yang diberikan
    message ??= 'Default Message'; // Pesan default jika tidak ada yang diberikan

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      message,
      _convertTime(hour, minutes),
      NotificationDetails(
        android: AndroidNotificationDetails(
          '9192',
          'Schedule Notification',
          channelDescription: 'Schedule Notification',
          importance: Importance.max,
          priority: Priority.high,
          sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'It could be anything you pass',
    );
  }

  cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();
  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);
}
