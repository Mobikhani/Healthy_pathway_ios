import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled successfully');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  static Future<void> init() async {
    if (_isInitialized) {
      print('Notification service already initialized');
      return;
    }

    try {
      print('🔧 Initializing notification service...');
      
      // Initialize timezone
      tz.initializeTimeZones();
      final deviceTimezone = DateTime.now().timeZoneName;
      print('Device timezone: $deviceTimezone');
      
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
        print('Set timezone to Asia/Karachi');
      } catch (e) {
        print('Failed to set Asia/Karachi timezone, using local: $e');
      }

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'medicines_channel',
        'Medicine Reminders',
        description: 'Channel for medicine reminder notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

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

      // Initialize with notification tap callback
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
        },
      );

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  static Future<void> scheduleMedicineNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<String> days,
  }) async {
    try {
      print('=== SCHEDULING MEDICINE NOTIFICATION ===');
      print('Title: $title');
      print('Time: ${time.hour}:${time.minute}');
      print('Days: $days');
      
      final now = DateTime.now();
      print('Current time: $now');
      print('Current weekday: ${now.weekday}');

      // Cancel any existing notifications for this medicine
      for (String day in days) {
        final existingId = id + day.hashCode;
        await _notifications.cancel(existingId);
        print('Cancelled existing notification with ID: $existingId');
      }

      for (String day in days) {
        final scheduledDate = _nextInstanceOfDayTime(time, day);
        final uniqueId = id + day.hashCode;

        print('Scheduling for day: $day');
        print('Scheduled date: ${scheduledDate.toLocal()}');
        print('Unique ID: $uniqueId');
        print('Time until notification: ${scheduledDate.difference(now).inMinutes} minutes');

        // If the time is very close (within 1 minute), schedule it for 30 seconds from now for testing
        if (scheduledDate.difference(now).inMinutes < 1) {
          final testDate = DateTime.now().add(const Duration(seconds: 30));
          print('⚠️ Time is too close, scheduling for testing in 30 seconds: $testDate');
          
          await _notifications.zonedSchedule(
            uniqueId,
            title,
            body,
            tz.TZDateTime.from(testDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medicines_channel',
                'Medicine Reminders',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                icon: '@mipmap/ic_launcher',
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                channelShowBadge: true,
                enableLights: true,
                color: Color(0xFF00ACC1),
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } else {
          // Convert to TZDateTime for scheduling
          final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

          await _notifications.zonedSchedule(
            uniqueId,
            title,
            body,
            tzScheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medicines_channel',
                'Medicine Reminders',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                icon: '@mipmap/ic_launcher',
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                channelShowBadge: true,
                enableLights: true,
                color: Color(0xFF00ACC1),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'medicine_reminder',
          );
        }
        
        print('✅ Successfully scheduled notification for $day');
      }
      
      print('=== ALL NOTIFICATIONS SCHEDULED ===');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  static DateTime _nextInstanceOfDayTime(TimeOfDay time, String weekday) {
    final now = DateTime.now();
    final targetDay = _weekdayToInt(weekday);

    print('Calculating next occurrence for $weekday at ${time.hour}:${time.minute}');
    print('Current time: $now (weekday: ${now.weekday})');
    print('Target weekday: $targetDay');

    // Create a date for today at the specified time
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    print('Initial scheduled date: $scheduledDate');

    // If the time has already passed today, move to next occurrence
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print('Time already passed today, moving to tomorrow: $scheduledDate');
    }

    // Find the next occurrence of the target day
    int daysAdded = 0;
    while (scheduledDate.weekday != targetDay) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      daysAdded++;
      if (daysAdded > 7) {
        print('⚠️ Warning: Could not find target day, using fallback');
        break;
      }
    }

    print('Final calculated date: $scheduledDate');
    print('Days added: $daysAdded');
    print('Time until notification: ${scheduledDate.difference(now).inMinutes} minutes');
    
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

  // Method to test notification immediately
  static Future<void> showTestNotification() async {
    try {
      print('Sending test notification...');
      await _notifications.show(
        999,
        'Test Medicine Reminder',
        'This is a test notification to verify the system is working',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      print('✅ Test notification sent successfully');
    } catch (e) {
      print('❌ Error sending test notification: $e');
      rethrow;
    }
  }

  // Method to force show a medicine notification immediately
  static Future<void> showMedicineNotificationNow(String medicineName) async {
    try {
      print('Showing medicine notification immediately for: $medicineName');
      await _notifications.show(
        996,
        'Time to take $medicineName',
        'Don\'t forget to take your medicine!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            channelShowBadge: true,
            enableLights: true,
            color: Color(0xFF00ACC1),
          ),
        ),
      );
      print('✅ Medicine notification shown immediately');
    } catch (e) {
      print('❌ Error showing medicine notification: $e');
      rethrow;
    }
  }

  // Method to schedule a test notification for 10 seconds from now
  static Future<void> scheduleTestNotification() async {
    try {
      print('Scheduling test notification for 10 seconds from now...');
      final scheduledDate = DateTime.now().add(const Duration(seconds: 10));
      
      await _notifications.zonedSchedule(
        998,
        'Test Scheduled Notification',
        'This notification was scheduled 10 seconds ago',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('✅ Test notification scheduled for ${scheduledDate.toLocal()}');
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
      rethrow;
    }
  }

  // Method to schedule a test medicine notification for 2 minutes from now
  static Future<void> scheduleTestMedicineNotification() async {
    try {
      print('Scheduling test medicine notification for 2 minutes from now...');
      final scheduledDate = DateTime.now().add(const Duration(minutes: 2));
      
      await _notifications.zonedSchedule(
        997,
        'Test Medicine Reminder',
        'This is a test medicine notification scheduled 2 minutes ago',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicines_channel',
            'Medicine Reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            channelShowBadge: true,
            enableLights: true,
            color: Color(0xFF00ACC1),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('✅ Test medicine notification scheduled for ${scheduledDate.toLocal()}');
    } catch (e) {
      print('❌ Error scheduling test medicine notification: $e');
      rethrow;
    }
  }

  // Method to check notification permissions
  static Future<Map<String, bool>> checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final alarmStatus = await Permission.ignoreBatteryOptimizations.status;
    
    print('Notification permission: $notificationStatus');
    print('Alarm permission: $alarmStatus');
    
    return {
      'notification': notificationStatus.isGranted,
      'alarm': alarmStatus.isGranted,
    };
  }

  // Method to request all permissions
  static Future<void> requestPermissions() async {
    print('Requesting permissions...');
    final notificationStatus = await Permission.notification.request();
    final alarmStatus = await Permission.ignoreBatteryOptimizations.request();
    
    print('Notification permission result: $notificationStatus');
    print('Alarm permission result: $alarmStatus');
  }

  // Method to get all pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    print('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print('ID: ${notification.id}, Title: ${notification.title}');
    }
    return pendingNotifications;
  }
}
