import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:healthy_pathway/home/exercise_plan/exercise_plan_screen.dart';
import 'package:healthy_pathway/home/medication_reminder/medication_home.dart';
import 'package:healthy_pathway/home/myth_checker/myth_home.dart';
import 'package:healthy_pathway/home/nutration_guide/calories_tracker.dart';
import 'package:healthy_pathway/home/overview_and_prevention/disease_overview_prevention.dart';
import 'package:healthy_pathway/home/health_info/health_info_screen.dart';
import 'dart:ui';
import '../auth/login_screen.dart';
import 'health_tips/health_tips.dart';
import 'dart:math';
import 'dart:async';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  String searchQuery = "";
  String userName = "Loading...";
  String userEmail = "";
  String currentHealthTip = "";
  Timer? _tipTimer;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<String> healthTips = [
    "Drink at least 8 glasses of water a day.",
    "Get 7-8 hours of sleep each night.",
    "Eat a balanced diet with fruits and vegetables.",
    "Exercise for at least 30 minutes daily.",
    "Avoid sugary drinks and junk food.",
    "Wash your hands regularly.",
    "Don't skip breakfast.",
    "Practice deep breathing or meditation.",
    "Avoid smoking and limit alcohol intake.",
    "Take regular breaks from screens.",
    "Stretch after waking up and before bed.",
    "Go for a walk after meals.",
    "Keep your posture straight.",
    "Include nuts and seeds in your diet.",
    "Use stairs instead of elevators.",
    "Limit processed food consumption.",
    "Take sunlight for Vitamin D.",
    "Chew your food slowly.",
    "Avoid late-night meals.",
    "Stay connected with loved ones.",
    "Use natural oils for cooking.",
    "Do regular health checkups.",
    "Stay mentally active (reading, puzzles).",
    "Smile more, stress less.",
    "Avoid eating when not hungry.",
    "Reduce salt and sugar intake.",
    "Keep your surroundings clean.",
    "Don't ignore mental health.",
    "Practice gratitude every day.",
    "Avoid overeating even if the food is healthy."
  ];

  final List<Map<String, dynamic>> allFeatures = [
    {
      'icon': Icons.monitor_heart,
      'image': 'assets/images/icons/icon_health_info.png',
      'title': 'Health Info',
      'description': 'Your health complete information',
      'category': 'Personal Health',
      'screen': const HealthInfoScreen(),
      'color': Color(0xFF4CAF50),
      'bgImage': 'assets/images/health/medical_checkup.jpg',
    },
    {
      'icon': Icons.fitness_center,
      'image': 'assets/images/icons/icon_exercise.png',
      'title': 'Exercise Plan',
      'description': 'Stay fit with personalized workouts',
      'category': 'Fitness',
      'screen': ExercisePlanScreen(),
      'color': Color(0xFF2196F3),
      'bgImage': 'assets/images/health/exercise_workout.jpg',
    },
    {
      'icon': Icons.medication,
      'image': 'assets/images/icons/icon_medication.png',
      'title': 'Medication Reminder',
      'description': 'Never miss a dose again',
      'category': 'Medication',
      'screen': const MedicationHome(),
      'color': Color(0xFFF44336),
      'bgImage': 'assets/images/health/medication_wellness.jpg',
    },
    {
      'icon': Icons.local_fire_department,
      'image': 'assets/images/icons/icon_calories.png',
      'title': 'Calories Counter',
      'description': 'Track your calorie intake easily',
      'category': 'Nutrition',
      'screen': const CalorieTrackerScreen(),
      'color': Color(0xFFFF9800),
      'bgImage': 'assets/images/health/healthy_food.jpg',
    },
    {
      'icon': Icons.health_and_safety,
      'image': 'assets/images/icons/icon_disease.png',
      'title': 'Disease Overview',
      'description': 'Understand and prevent diseases',
      'category': 'Health Education',
      'screen': const DiseaseOverviewPrevention(),
      'color': Color(0xFF9C27B0),
      'bgImage': 'assets/images/health/medical_checkup.jpg',
    },
    {
      'icon': Icons.lightbulb,
      'image': 'assets/images/icons/icon_myth.png',
      'title': 'Myth Buster',
      'description': 'Busting health myths with facts',
      'category': 'Health Education',
      'screen': const MythHomeScreen(),
      'color': Color(0xFF607D8B),
      'bgImage': 'assets/images/health/meditation_wellness.jpg',
    },
    {
      'icon': Icons.tips_and_updates,
      'image': 'assets/images/icons/icon_tips.png',
      'title': 'Daily Health Tips',
      'description': 'Boost your day with a health tip',
      'category': 'Health Education',
      'screen': const HealthTipsScreen(),
      'color': Color(0xFF00BCD4),
      'bgImage': 'assets/images/health/nutrition_balanced.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    getRandomHealthTip();
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getRandomHealthTip();
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserDetails() async {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(currentUser!.uid);

      final snapshot = await userRef.get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot.child('name').value.toString();
          userEmail = snapshot.child('email').value.toString();
        });
      }
    }
  }

  void getRandomHealthTip() {
    final random = Random();
    final index = random.nextInt(healthTips.length);
    setState(() {
      currentHealthTip = healthTips[index];
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredFeatures = allFeatures
        .where((feature) => feature['title']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg_health_gradient.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with enhanced logo
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 50,
                      color: Colors.white,
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Healthy Pathway',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Enhanced feature cards
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildEnhancedFeatureCard(
                      context,
                      'Health Info',
                      'Your complete health information',
                      'assets/images/health/medical_checkup.jpg',
                      Icons.monitor_heart,
                      Colors.green,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Exercise Plan',
                      'Personalized workout routines',
                      'assets/images/health/exercise_workout.jpg',
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Medication Reminder',
                      'Never miss your medications',
                      'assets/images/health/medication_wellness.jpg',
                      Icons.medication,
                      Colors.red,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Calories Counter',
                      'Track your daily nutrition',
                      'assets/images/health/healthy_food.jpg',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Disease Overview',
                      'Learn about prevention',
                      'assets/images/health/medical_checkup.jpg',
                      Icons.health_and_safety,
                      Colors.purple,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Myth Buster',
                      'Separate facts from myths',
                      'assets/images/health/meditation_wellness.jpg',
                      Icons.lightbulb,
                      Colors.teal,
                    ),
                    _buildEnhancedFeatureCard(
                      context,
                      'Daily Health Tips',
                      'Boost your wellness',
                      'assets/images/health/nutrition_balanced.jpg',
                      Icons.tips_and_updates,
                      Colors.cyan,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFeatureCard(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Container(
              height: 120,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Container(
              height: 120,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 