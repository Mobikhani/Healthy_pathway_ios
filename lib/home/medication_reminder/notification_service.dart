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

      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        print('✅ Android notification channel created');
      } else {
        print('⚠️ Android implementation not available');
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

      // Initialize with notification tap callback
      final initialized = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
        },
      );
      
      print('Notification initialization result: $initialized');

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      _isInitialized = false;
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
      print('Service initialized: $_isInitialized');
      
      if (!_isInitialized) {
        print('❌ Notification service not initialized!');
        await init();
      }
      
      final now = DateTime.now();
      print('Current time: $now');

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
          payload: 'medicine_reminder',
        );
        print('✅ Successfully scheduled notification for $day at ${scheduledDate.toLocal()}');
        
        // Schedule the next occurrence for recurring notifications
        await _scheduleNextOccurrence(uniqueId, title, body, time, day);
      }
      
      print('=== ALL NOTIFICATIONS SCHEDULED ===');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  // Helper method to schedule the next occurrence
  static Future<void> _scheduleNextOccurrence(
    int baseId,
    String title,
    String body,
    TimeOfDay time,
    String weekday,
  ) async {
    try {
      // Calculate next week's occurrence
      final nextWeekDate = _nextInstanceOfDayTime(time, weekday).add(const Duration(days: 7));
      final nextWeekId = baseId + 1000; // Different ID for next week
      
      print('📅 Scheduling next week occurrence for $weekday at ${nextWeekDate.toLocal()}');
      
      final tzNextWeekDate = tz.TZDateTime.from(nextWeekDate, tz.local);
      
      await _notifications.zonedSchedule(
        nextWeekId,
        title,
        body,
        tzNextWeekDate,
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
        payload: 'medicine_reminder',
      );
      print('✅ Next week occurrence scheduled successfully');
    } catch (e) {
      print('❌ Error scheduling next occurrence: $e');
    }
  }

  static DateTime _nextInstanceOfDayTime(TimeOfDay time, String weekday) {
    final now = DateTime.now();
    final targetDay = _weekdayToInt(weekday);

    print('🔍 TIME CALCULATION DEBUG:');
    print('Target: $weekday at ${time.hour}:${time.minute}');
    print('Current: ${now.toLocal()} (weekday: ${now.weekday})');
    print('Target weekday number: $targetDay');

    // Start with today at the specified time
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    print('Initial date: $scheduledDate');

    // If today is the target day and time hasn't passed, use today
    if (now.weekday == targetDay && scheduledDate.isAfter(now)) {
      print('✅ Using today - same day and time in future');
      print('Time until notification: ${scheduledDate.difference(now).inMinutes} minutes');
      return scheduledDate;
    }

    // If today is the target day but time has passed, move to next week
    if (now.weekday == targetDay && scheduledDate.isBefore(now)) {
      print('⏰ Same day but time passed, moving to next week');
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    } else {
      // Find next occurrence of target day
      int daysToAdd = 0;
      while (scheduledDate.weekday != targetDay) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        daysToAdd++;
        if (daysToAdd > 7) {
          print('⚠️ Could not find target day, using fallback');
          break;
        }
      }
      print('📅 Added $daysToAdd days to reach target day');
    }

    print('Final scheduled date: ${scheduledDate.toLocal()}');
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

  // Method to check if notification service is initialized
  static bool isInitialized() {
    return _isInitialized;
  }

  // Method to get detailed service status
  static Future<Map<String, dynamic>> getServiceStatus() async {
    final permissions = await checkPermissions();
    final pendingNotifications = await getPendingNotifications();
    
    return {
      'initialized': _isInitialized,
      'permissions': permissions,
      'pendingNotificationsCount': pendingNotifications.length,
      'pendingNotifications': pendingNotifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
      }).toList(),
    };
  }

  // Method to reschedule all notifications from Firebase data
  static Future<void> rescheduleAllNotifications(List<Map<String, dynamic>> medicines) async {
    try {
      print('🔄 Rescheduling all notifications from Firebase data...');
      
      if (!_isInitialized) {
        print('❌ Service not initialized, initializing now...');
        await init();
      }
      
      // Cancel all existing notifications first
      await cancelAllNotifications();
      
      // Reschedule each medicine
      for (final medicine in medicines) {
        final name = medicine['name'] as String? ?? '';
        final timeStr = medicine['time'] as String? ?? '';
        final days = (medicine['days'] as List<dynamic>?)?.cast<String>() ?? [];
        
        if (name.isNotEmpty && timeStr.isNotEmpty && days.isNotEmpty) {
          // Parse time string (format: "18:30")
          final timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            final time = TimeOfDay(hour: hour, minute: minute);
            
            print('🔄 Rescheduling: $name at ${time.hour}:${time.minute.toString().padLeft(2, '0')} on $days');
            
            await scheduleMedicineNotification(
              id: name.hashCode & 0x7FFFFFFF,
              title: 'Time to take $name',
              body: 'Don\'t forget to take your medicine!',
              time: time,
              days: days,
            );
          }
        }
      }
      
      print('✅ All notifications rescheduled successfully');
    } catch (e) {
      print('❌ Error rescheduling notifications: $e');
    }
  }

  // Simple test notification method
  static Future<void> showSimpleTestNotification() async {
    try {
      print('🔔 Showing simple test notification...');
      
      if (!_isInitialized) {
        print('❌ Service not initialized, initializing now...');
        await init();
      }
      
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
      print('✅ Simple test notification sent successfully');
    } catch (e) {
      print('❌ Error sending simple test notification: $e');
      rethrow;
    }
  }

  // Test method to schedule a notification for 30 seconds in the future
  static Future<void> scheduleTestNotification() async {
    try {
      print('🧪 Scheduling test notification for 30 seconds...');
      
      if (!_isInitialized) {
        print('❌ Service not initialized, initializing now...');
        await init();
      }
      
      final now = DateTime.now();
      final scheduledTime = now.add(const Duration(seconds: 30));
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      print('Current time: ${now.toLocal()}');
      print('Scheduled time: ${scheduledTime.toLocal()}');
      print('Time until notification: 30 seconds');
      
      await _notifications.zonedSchedule(
        888,
        'Test Scheduled Notification',
        'This notification was scheduled 30 seconds ago',
        tzScheduledTime,
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
        payload: 'test_notification',
      );
      print('✅ Test notification scheduled for 30 seconds');
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
      rethrow;
    }
  }
}
