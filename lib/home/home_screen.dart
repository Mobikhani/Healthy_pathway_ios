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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String userName = "Loading...";
  String userEmail = "";

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> allFeatures = [
    {
      'icon': Icons.monitor_heart,
      'title': 'Health Info',
      'description': 'Your health complete information',
      'category': 'Personal Health',
      'screen': const HealthInfoScreen(),
    },
    {
      'icon': Icons.location_on,
      'title': 'Exercise Plan',
      'description': 'Stay fit with personalized workouts',
      'category': 'Fitness',
      'screen': ExercisePlanScreen(),
    },
    {
      'icon': Icons.medication,
      'title': 'Medication Reminder',
      'description': 'Never miss a dose again',
      'category': 'Medication',
      'screen': const MedicationHome(),
    },
    {
      'icon': Icons.local_fire_department,
      'title': 'Calories Counter',
      'description': 'Track your calorie intake easily',
      'category': 'Nutrition',
      'screen': const CalorieTrackerScreen(),
    },
    {
      'icon': Icons.health_and_safety,
      'title': 'Disease Overview',
      'description': 'Understand and prevent diseases',
      'category': 'Health Education',
      'screen': const DiseaseOverviewPrevention(),
    },
    {
      'icon': Icons.lightbulb,
      'title': 'Myth Buster',
      'description': 'Busting health myths with facts',
      'category': 'Health Education',
      'screen': const MythHomeScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
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
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search features...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: buildFeatureSections(filteredFeatures),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Drawer buildDrawer(BuildContext context, String userName, String userEmail, List<Map<String, dynamic>> allFeatures, VoidCallback logout) {
    return Drawer(
      child: Stack(
        children: [
          // Semi-transparent gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xCC004D61), // Dark teal with opacity
                  const Color(0xCC006978), // Blue-grey with opacity
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blur filter for glassmorphism effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Drawer content
          ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ...allFeatures.map((feature) {
                return ListTile(
                  leading: Icon(feature['icon'], color: Colors.white),
                  title: Text(
                    feature['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => feature['screen']),
                    );
                  },
                );
              }).toList(),
              const Divider(color: Colors.white54),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: logout,
              ),
            ],
          ),
        ],
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
          Row(
            children: [
              Icon(
                getCategoryIcon(category),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((feature) => buildFeatureCard(feature)).toList(),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  Widget buildFeatureCard(Map<String, dynamic> feature) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          feature['icon'],
          size: 40,
          color: Colors.blueGrey,
        ),
        title: Text(
          feature['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          feature['description'],
          style: const TextStyle(color: Colors.black54),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => feature['screen']),
          );
        },
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
}
