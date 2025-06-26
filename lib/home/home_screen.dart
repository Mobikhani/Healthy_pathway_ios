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
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'health_tips/health_tips.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    },
    {
      'icon': Icons.location_on,
      'image': 'assets/images/icons/icon_exercise.png',
      'title': 'Exercise Plan',
      'description': 'Stay fit with personalized workouts',
      'category': 'Fitness',
      'screen': ExercisePlanScreen(),
      'color': Color(0xFF2196F3),
    },
    {
      'icon': Icons.medication,
      'image': 'assets/images/icons/icon_medication.png',
      'title': 'Medication Reminder',
      'description': 'Never miss a dose again',
      'category': 'Medication',
      'screen': const MedicationHome(),
      'color': Color(0xFFF44336),
    },
    {
      'icon': Icons.local_fire_department,
      'image': 'assets/images/icons/icon_calories.png',
      'title': 'Calories Counter',
      'description': 'Track your calorie intake easily',
      'category': 'Nutrition',
      'screen': const CalorieTrackerScreen(),
      'color': Color(0xFFFF9800),
    },
    {
      'icon': Icons.health_and_safety,
      'image': 'assets/images/icons/icon_disease.png',
      'title': 'Disease Overview',
      'description': 'Understand and prevent diseases',
      'category': 'Health Education',
      'screen': const DiseaseOverviewPrevention(),
      'color': Color(0xFF9C27B0),
    },
    {
      'icon': Icons.lightbulb,
      'image': 'assets/images/icons/icon_myth.png',
      'title': 'Myth Buster',
      'description': 'Busting health myths with facts',
      'category': 'Health Education',
      'screen': const MythHomeScreen(),
      'color': Color(0xFF607D8B),
    },
    {
      'icon': Icons.tips_and_updates,
      'image': 'assets/images/icons/icon_tips.png',
      'title': 'Daily Health Tips',
      'description': 'Boost your day with a health tip',
      'category': 'Health Education',
      'screen': const HealthTipsScreen(),
      'color': Color(0xFF00BCD4),
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    getRandomHealthTip();
    // Start automatic tip cycling every 5 seconds
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Healthy Pathway',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: buildDrawer(context, userName, userEmail, allFeatures, logout),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2),
              Color(0xFF00ACC1),
              Color(0xFF007C91),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            children: [
              // Enhanced Search Bar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search features...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white, size: 24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    buildHealthTipCard(currentHealthTip),
                    ...buildFeatureSections(filteredFeatures),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context, String userName, String userEmail, List<Map<String, dynamic>> allFeatures, VoidCallback logout) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007C91),
              Color(0xFF00ACC1),
              Color(0xFFB2EBF2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ...allFeatures.map((feature) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: feature['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(feature['icon'], color: Colors.white, size: 24),
                  ),
                  title: Text(
                    feature['title'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => feature['screen']),
                    );
                  },
                ),
              );
            }).toList(),
            const Divider(color: Colors.white54, height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red.withOpacity(0.2),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 24),
                ),
                title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildFeatureSections(List<Map<String, dynamic>> features) {
    final categories = <String>{};
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var feature in features) {
      final category = feature['category'] ?? 'Others';
      categories.add(category);
      grouped.putIfAbsent(category, () => []).add(feature);
    }

    return categories.map((category) {
      final items = grouped[category]!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getCategoryIcon(category),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((feature) => buildFeatureCard(feature)).toList(),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  Widget buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Enhanced Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      feature['color'],
                      feature['color'].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: feature['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  feature['icon'],
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: feature['color'],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Personal Health':
        return Icons.favorite;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Medication':
        return Icons.medical_services;
      case 'Nutrition':
        return Icons.restaurant;
      case 'Health Education':
        return Icons.menu_book;
      default:
        return Icons.star;
    }
  }

  Widget buildHealthTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00ACC1), Color(0xFF007C91)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00ACC1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Daily Health Tip',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D61),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACC1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: getRandomHealthTip,
                      icon: const Icon(Icons.refresh, color: Color(0xFF00ACC1)),
                      tooltip: 'Get new tip',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACC1).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00ACC1).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tips automatically change every 5 seconds!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
