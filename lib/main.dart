import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthy_pathway/home/medication_reminder/notification_service.dart';
import 'package:healthy_pathway/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_pathway/auth/login_screen.dart';
import 'package:healthy_pathway/home/home_screen.dart';

import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first - before running the app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  // Start the app after Firebase is initialized
  runApp(const MyApp());
  
  // Initialize notification service in background
  try {
    await NotificationService.init();
    print('Notification service initialized successfully in main');
  } catch (e) {
    print('Error initializing notification service: $e');
  }
  
  // Request permissions in background
  try {
    await requestAllPermissions();
    print('Permissions requested successfully');
  } catch (e) {
    print('Error requesting permissions: $e');
  }
}

Future<void> requestAllPermissions() async {
  try {
    // Request notification permission
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final result = await Permission.notification.request();
      print('Notification permission request result: $result');
    }
    
    // Request additional permissions for Android
    final alarmStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!alarmStatus.isGranted) {
      final result = await Permission.ignoreBatteryOptimizations.request();
      print('Alarm permission request result: $result');
    }
    
    print('Final notification permission status: ${await Permission.notification.status}');
    print('Final alarm permission status: ${await Permission.ignoreBatteryOptimizations.status}');
  } catch (e) {
    print('Error requesting permissions: $e');
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
