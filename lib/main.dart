import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthy_pathway/home/medication_reminder/notification_service.dart';
import 'package:healthy_pathway/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io' show Platform;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first - before running the app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
  
  // Initialize Android Alarm Manager only on Android
  if (Platform.isAndroid) {
    try {
      print('🔧 Initializing Android Alarm Manager...');
      await AndroidAlarmManager.initialize();
      print('✅ Android Alarm Manager initialized successfully');
    } catch (e) {
      print('❌ Error initializing Android Alarm Manager: $e');
    }
  }
  
  // Initialize notification service before running the app
  try {
    print('🔧 Initializing notification service in main...');
    await NotificationService.init();
    print('✅ Notification service initialized successfully in main');
  } catch (e) {
    print('❌ Error initializing notification service in main: $e');
  }
  
  // Request permissions after notification service is initialized
  try {
    print('🔧 Requesting permissions...');
    await requestAllPermissions();
    print('✅ Permissions requested successfully');
  } catch (e) {
    print('❌ Error requesting permissions: $e');
  }
  
  // Start the app after all initialization is complete
  runApp(const MyApp());
}

Future<void> requestAllPermissions() async {
  try {
    print('🔧 Checking current permission status...');
    
    // Check notification permission
    final notificationStatus = await Permission.notification.status;
    print('Current notification permission status: $notificationStatus');
    
    if (!notificationStatus.isGranted) {
      print('🔧 Requesting notification permission...');
      final result = await Permission.notification.request();
      print('Notification permission request result: $result');
    } else {
      print('✅ Notification permission already granted');
    }
    
    // Android-specific permissions
    if (Platform.isAndroid) {
      // Check and request alarm permission for Android
      final alarmStatus = await Permission.ignoreBatteryOptimizations.status;
      print('Current alarm permission status: $alarmStatus');
      
      if (!alarmStatus.isGranted) {
        print('🔧 Requesting alarm permission...');
        final result = await Permission.ignoreBatteryOptimizations.request();
        print('Alarm permission request result: $result');
      } else {
        print('✅ Alarm permission already granted');
      }
      
      // Check and request exact alarm permission for Android 12+
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        print('Current exact alarm permission status: $exactAlarmStatus');
        
        if (!exactAlarmStatus.isGranted) {
          print('🔧 Requesting exact alarm permission...');
          final result = await Permission.scheduleExactAlarm.request();
          print('Exact alarm permission request result: $result');
        } else {
          print('✅ Exact alarm permission already granted');
        }
      } catch (e) {
        print('⚠️ Exact alarm permission not available on this device: $e');
      }
    }
    
    // Final status check
    final finalNotificationStatus = await Permission.notification.status;
    
    print('Final notification permission status: $finalNotificationStatus');
    
    if (finalNotificationStatus.isGranted) {
      print('✅ All required permissions granted');
    } else {
      print('⚠️ Some permissions may not be granted - notifications may not work properly');
    }
  } catch (e) {
    print('❌ Error requesting permissions: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthy Pathway',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00ACC1),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00ACC1),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start directly with splash screen
    );
  }
}
