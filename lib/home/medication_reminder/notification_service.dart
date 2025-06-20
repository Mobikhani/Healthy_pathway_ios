import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';


class NotificationService {

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
      'medicines_channel',
      'Medicine Reminders',
      description: 'Channel for medicine reminder notifications',
      importance: Importance.max,
    ));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
  }

  static Future<void> scheduleMedicineNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<String> days,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    for (String day in days) {
      final scheduledDate = _nextInstanceOfDayTime(time, day);

      await _notifications.zonedSchedule(
        id + day.hashCode, // unique ID
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Scheduling for ${scheduledDate.toLocal()}');
    }
  }

  static tz.TZDateTime _nextInstanceOfDayTime(TimeOfDay time, String weekday) {
    final now = tz.TZDateTime.now(tz.local);
    final targetDay = _weekdayToInt(weekday);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static int _weekdayToInt(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }
}
