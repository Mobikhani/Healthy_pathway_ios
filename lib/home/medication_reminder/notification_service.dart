import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Android-specific initialization
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
        'medicines_channel',
        'Medicine Reminders',
        description: 'Channel for medicine reminder notifications',
        importance: Importance.max,
      ));
    }

    // iOS-specific initialization
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
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
    for (String day in days) {
      final scheduledDate = _nextInstanceOfDayTime(time, day);

      NotificationDetails notificationDetails;
      
      if (Platform.isAndroid) {
        notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        );
      } else {
        notificationDetails = const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );
      }

      await _notifications.zonedSchedule(
        id + day.hashCode, // unique ID
        title,
        body,
        scheduledDate,
        notificationDetails,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: Platform.isAndroid 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('Scheduling for ${scheduledDate.toLocal()}');
    }
  }

  // Add missing methods for debug screen
  static Future<String> getServiceStatus() async {
    try {
      // Check if notifications are working by trying to show a test notification
      await _notifications.show(
        999,
        'Status Check',
        'Service is working',
        const NotificationDetails(),
      );
      return 'Initialized';
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification',
      platformChannelSpecifics,
    );
  }

  static Future<void> scheduleTestFor1Minute() async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      1,
      '1 Minute Test',
      'Scheduled for 1 minute from now',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleTestFor2Minutes() async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2));
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      2,
      '2 Minutes Test',
      'Scheduled for 2 minutes from now',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleTestForExactTime() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1, // Schedule for next minute
    );
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      3,
      'Exact Time Test',
      'Scheduled for exact time',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
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

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 