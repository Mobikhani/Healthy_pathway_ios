import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../auth/login_screen.dart';
import 'exercise_plan/exercise_plan_screen.dart';
import 'medication_reminder/medication_home.dart';
import 'health_info/health_info_screen.dart';
import 'health_tips/health_tips.dart';
import 'myth_checker/myth_home.dart';
import 'nutration_guide/calories_tracker.dart';
import 'overview_and_prevention/disease_overview_prevention.dart';
import '../services/unlimited_health_tips_service.dart';

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
  String selectedCategory = "All";

  final User? currentUser = FirebaseAuth.instance.currentUser;

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
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    getRandomHealthTip();
    // Start automatic tip cycling every 30 seconds
    _tipTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      getRandomHealthTip();
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserDetails() async {
    try {
      if (currentUser != null) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('Users')
            .child(currentUser!.uid);

        final snapshot = await userRef.get();
        if (snapshot.exists) {
          final data = snapshot.value;
          
          // Safe type checking and conversion
          if (data is Map<dynamic, dynamic>) {
            final userData = Map<String, dynamic>.from(data);
            setState(() {
              userName = userData['name']?.toString() ?? 'User';
              userEmail = userData['email']?.toString() ?? '';
            });
          } else {
            // Fallback if data structure is unexpected
            setState(() {
              userName = 'User';
              userEmail = currentUser!.email ?? '';
            });
          }
        } else {
          // User data doesn't exist, use Firebase user info
          setState(() {
            userName = 'User';
            userEmail = currentUser!.email ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
      // Fallback to Firebase user info
      setState(() {
        userName = currentUser?.displayName ?? 'User';
        userEmail = currentUser?.email ?? '';
      });
    }
  }

  Future<void> getRandomHealthTip() async {
    try {
      final tip = await UnlimitedHealthTipsService.generateHealthTip(selectedCategory);
      if (mounted) {
        setState(() {
          currentHealthTip = tip;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentHealthTip = 'Stay healthy and happy!';
        });
      }
      print('Error loading health tip: $e');
    }
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Auth state listener will automatically navigate to LoginScreen
      // No need for manual navigation here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredFeatures = allFeatures
        .where((feature) => feature['title']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    // Get all unique categories from all features (not just filtered)
    final allCategories = <String>{};
    for (var feature in allFeatures) {
      final category = feature['category'] ?? 'Others';
      allCategories.add(category);
    }
    final categoryList = ['All', ...allCategories.toList()..sort()];

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
              
              const SizedBox(height: 16),
              
              // Fixed Category Tab Bar - Show all categories
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryList[index];
                    final isSelected = selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: isSelected 
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getCategoryIcon(category),
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              // Scrollable Content Area
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
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    // Group features by category
    for (var feature in features) {
      final category = feature['category'] ?? 'Others';
      grouped.putIfAbsent(category, () => []).add(feature);
    }

    // Build sections based on selected category
    List<Widget> sections = [];
    
    if (selectedCategory == 'All') {
      // Show all categories with their headers
      grouped.forEach((category, items) {
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                margin: const EdgeInsets.only(bottom: 12),
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
              // Feature Cards
              ...items.map((feature) => buildFeatureCard(feature)).toList(),
              const SizedBox(height: 24),
            ],
          ),
        );
      });
    } else {
      // Show only the selected category
      if (grouped.containsKey(selectedCategory)) {
        final items = grouped[selectedCategory]!;
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getCategoryIcon(selectedCategory),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedCategory,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Feature Cards
              ...items.map((feature) => buildFeatureCard(feature)).toList(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    }

    return sections;
  }

  Widget buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => feature['screen']),
        );
      },
      child: Container(
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF00ACC1).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade100,
                Colors.cyan.shade100,
                Colors.teal.shade100,
                Colors.blue.shade50,
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00ACC1).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF007C91).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with enhanced design
                    Row(
                      children: [
                        // Animated icon container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00ACC1),
                                Color(0xFF007C91),
                                Color(0xFF004D61),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00ACC1).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Health Tip',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004D61),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stay healthy, stay happy!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Enhanced refresh button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00ACC1).withOpacity(0.2),
                                const Color(0xFF007C91).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00ACC1).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: getRandomHealthTip,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF00ACC1),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Enhanced tip content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            const Color(0xFF00ACC1).withOpacity(0.1),
                            const Color(0xFF007C91).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00ACC1).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00ACC1).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00ACC1).withOpacity(0.2),
                                      const Color(0xFF007C91).withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '💡 Tip of the Day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF004D61),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.favorite,
                                color: const Color(0xFF00ACC1).withOpacity(0.6),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Enhanced footer with progress indicator
                    Row(
                      children: [
                        // Progress dots
                        Row(
                          children: List.generate(5, (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0 
                                  ? const Color(0xFF00ACC1)
                                  : const Color(0xFF00ACC1).withOpacity(0.3),
                            ),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Auto-refresh every 30s',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
