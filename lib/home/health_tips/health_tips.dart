import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/round_home_button.dart';
import '../../services/health_tips_api.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  Map<String, dynamic> currentTip = {};
  Timer? _autoChangeTimer;
  int _tipIndex = 0;
  List<String> categories = [];
  String selectedCategory = 'All';
  bool isLoading = false;
  List<Map<String, dynamic>> categoryTips = [];
  int currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize with default tip immediately
    currentTip = {
      'tip': '💡 Stay healthy and happy! Drink water, exercise, and sleep well.',
      'category': 'Health',
      'icon': '💡',
      'source': 'Healthy Pathway',
    };

    // Initialize categories immediately with fallback
    categories = ['All', 'Health', 'Nutrition', 'Fitness', 'Mental Health'];
    
    // Start async initialization
    _init();
  }

  Future<void> _init() async {
    print('🔄 Starting async initialization...'); // Debug print
    
    try {
      // Step 1: Load categories (synchronously)
      _loadCategories();
      print('📋 Categories loaded: $categories'); // Debug print
      
      // Step 2: Await tip loading
      await getRandomTip();
      print('💡 Initial tip loaded: ${currentTip['tip']}'); // Debug print
      
      // Step 3: Start auto-change timer
      startAutoChange();
      print('⏰ Auto-change timer started'); // Debug print
      
    } catch (e) {
      print('❌ Error during initialization: $e');
      // Ensure we have fallback data
      if (currentTip['tip'] == null || currentTip['tip'].toString().isEmpty) {
        setState(() {
          currentTip = {
            'tip': '💡 Stay healthy and happy! Drink water, exercise, and sleep well.',
            'category': 'Health',
            'icon': '💡',
            'source': 'Healthy Pathway',
          };
        });
        print('🛡️ Using fallback tip due to initialization error'); // Debug print
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final apiCategories = HealthTipsApi.getAllCategories();
      if (apiCategories.isNotEmpty) {
        setState(() {
          categories = ['All', ...apiCategories];
        });
        print('Categories updated from API: $categories'); // Debug print
      } else {
        print('API returned empty categories, keeping defaults'); // Debug print
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Keep default categories if API fails
    }
  }

  // Simple category color method
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hydration':
        return Colors.blue;
      case 'sleep':
        return Colors.purple;
      case 'nutrition':
        return Colors.green;
      case 'fitness':
        return Colors.orange;
      case 'mental health':
        return Colors.pink;
      case 'hygiene':
        return Colors.cyan;
      case 'eye health':
        return Colors.brown;
      case 'posture':
        return Colors.teal;
      case 'breathing':
        return Colors.grey;
      case 'social health':
        return Colors.indigo;
      case 'lifestyle':
        return Colors.grey;
      case 'preventive care':
        return Colors.red;
      case 'vitamins':
        return Colors.amber;
      case 'weight management':
        return Colors.brown;
      case 'eating habits':
        return Colors.deepOrange;
      case 'stress management':
        return Colors.pink;
      case 'exercise':
        return Colors.orange;
      case 'gut health':
        return Colors.lightGreen;
      case 'workplace health':
        return Colors.grey;
      case 'foot health':
        return Colors.brown;
      case 'sedentary behavior':
        return Colors.grey;
      case 'skin health':
        return Colors.deepOrange;
      case 'bone health':
        return Colors.brown;
      case 'hearing health':
        return Colors.blueGrey;
      case 'respiratory health':
        return Colors.lightGreen;
      case 'heart health':
        return Colors.red;
      case 'reproductive health':
        return Colors.pink;
      case 'aging':
        return Colors.grey;
      case 'environmental health':
        return Colors.green;
      case 'occupational health':
        return Colors.grey;
      case 'travel health':
        return Colors.blue;
      case 'seasonal health':
        return Colors.orange;
      case 'digital health':
        return Colors.indigo;
      case 'financial health':
        return Colors.amber;
      case 'spiritual health':
        return Colors.purple;
      case 'intellectual health':
        return Colors.teal;
      case 'creative health':
        return Colors.pink;
      case 'community health':
        return Colors.green;
      case 'global health':
        return Colors.cyan;
      case 'quote':
        return Colors.blue;
      case 'advice':
        return Colors.cyan;
      case 'inspiration':
        return Colors.purple;
      case 'wellness':
        return Colors.green;
      case 'dental health':
        return Colors.blue;
      case 'health':
      case 'health tip':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Future<void> getRandomTip() async {
    print('🔄 Getting random tip...'); // Debug print
    setState(() {
      isLoading = true;
    });

    try {
      final tip = await HealthTipsApi.getRandomTip();
      print('📡 API returned tip: $tip'); // Debug print
      
      if (mounted) {
        // Validate the tip data - check for null, empty, or invalid tip
        if (tip != null && 
            tip['tip'] != null && 
            tip['tip'].toString().isNotEmpty &&
            tip['tip'].toString().trim().isNotEmpty) {
          
          setState(() {
            currentTip = {
              'tip': tip['tip'],
              'category': tip['category'] ?? 'Health',
              'icon': tip['icon'] ?? '💡',
              'source': tip['source'] ?? 'Healthy Pathway',
            };
            _tipIndex++;
            isLoading = false;
          });
          print('✅ Tip updated successfully: ${currentTip['tip']}'); // Debug print
          
        } else {
          print('⚠️ API returned invalid/empty tip, using fallback'); // Debug print
          _setFallbackTip();
        }
      }
    } catch (e) {
      print('❌ Error loading health tip: $e');
      if (mounted) {
        _setFallbackTip();
      }
    }
  }

  void _setFallbackTip() {
    setState(() {
      currentTip = {
        'tip': '💡 Stay healthy and happy! Drink water, exercise, and sleep well.',
        'category': 'Health',
        'icon': '💡',
        'source': 'Healthy Pathway',
      };
      isLoading = false;
    });
    print('🛡️ Using fallback tip: ${currentTip['tip']}'); // Debug print
  }

  Future<void> getTipByCategory(String category) async {
    if (category == 'All') {
      setState(() {
        categoryTips = [];
        currentTipIndex = 0;
        selectedCategory = 'All';
      });
      await getRandomTip();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final tips = await HealthTipsApi.getTipsByCategory(category);
      if (tips.isNotEmpty) {
        setState(() {
          categoryTips = tips;
          currentTipIndex = 0;
          currentTip = tips[0];
          selectedCategory = category;
          _tipIndex++;
          isLoading = false;
        });
      } else {
        setState(() {
          categoryTips = [];
          currentTipIndex = 0;
          selectedCategory = category;
        });
        await getRandomTip();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        categoryTips = [];
        currentTipIndex = 0;
        selectedCategory = category;
      });
      await getRandomTip();
    }
  }

  void getNextTipInCategory() {
    if (selectedCategory != 'All' && categoryTips.isNotEmpty) {
      setState(() {
        currentTipIndex = (currentTipIndex + 1) % categoryTips.length;
        currentTip = categoryTips[currentTipIndex];
        _tipIndex++;
      });
    } else if (selectedCategory != 'All' && categoryTips.isEmpty) {
      getTipByCategory(selectedCategory);
    } else {
      getRandomTip();
    }
  }

  void startAutoChange() {
    _autoChangeTimer?.cancel();
    _autoChangeTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        getNextTipInCategory();
      }
    });
  }

  @override
  void dispose() {
    _autoChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ HealthTipsScreen build called'); // Debug print
    print('📋 Categories: $categories'); // Debug print
    print('💡 Current tip: ${currentTip['tip']}'); // Debug print
    print('⏳ Is loading: $isLoading'); // Debug print
    
    // DETAILED DEBUGGING OF currentTip
    print('🔍 DETAILED currentTip DEBUG:');
    print('  - currentTip type: ${currentTip.runtimeType}');
    print('  - currentTip keys: ${currentTip.keys.toList()}');
    print('  - currentTip isEmpty: ${currentTip.isEmpty}');
    print('  - currentTip length: ${currentTip.length}');
    print('  - tip value: "${currentTip['tip']}"');
    print('  - tip is null: ${currentTip['tip'] == null}');
    print('  - tip is empty: ${currentTip['tip']?.toString().isEmpty}');
    print('  - tip trimmed: "${currentTip['tip']?.toString().trim()}"');
    
    // Ensure we have valid data with comprehensive fallback
    final safeCategories = categories.isNotEmpty ? categories : ['All', 'Health'];
    final safeTip = currentTip.isNotEmpty && 
                   currentTip['tip'] != null && 
                   currentTip['tip'].toString().isNotEmpty &&
                   currentTip['tip'].toString().trim().isNotEmpty
                   ? currentTip 
                   : {
                       'tip': '💡 Stay healthy and happy! Drink water, exercise, and sleep well.',
                       'category': 'Health',
                       'icon': '💡',
                       'source': 'Healthy Pathway',
                     };
    
    print('🛡️ Safe categories: $safeCategories'); // Debug print
    print('🛡️ Safe tip: ${safeTip['tip']}'); // Debug print
    print('🛡️ Safe tip type: ${safeTip.runtimeType}'); // Debug print
    
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          "Daily Health Tips",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Health Tips'),
                  content: Text('Tips automatically change every 10 seconds. Tap the refresh button for a new tip anytime!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.yellow,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Today\'s Health Tip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    selectedCategory == 'All' 
                        ? 'Random Tips'
                        : 'Category: $selectedCategory',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Category Dropdown
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade800, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                        items: safeCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != selectedCategory) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                            _autoChangeTimer?.cancel();
                            getTipByCategory(newValue);
                            startAutoChange();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Health Tip Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getCategoryColor(safeTip['category']).withOpacity(0.8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tip Icon and Category
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(safeTip['category']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          safeTip['icon'] ?? '💡',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Text(
                              safeTip['category'] ?? 'Health',
                              style: TextStyle(
                                color: _getCategoryColor(safeTip['category']),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    Text(
                              'Tip #${_tipIndex}',
                      style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh Button
                      Container(
                        decoration: BoxDecoration(
                          color: _getCategoryColor(safeTip['category']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: _getCategoryColor(safeTip['category']),
                            size: 20,
                          ),
                          onPressed: () {
                            getNextTipInCategory();
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Tip Content
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(safeTip['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(safeTip['category']).withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          safeTip['tip'] ?? 'Stay healthy and happy!',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.source,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                    Text(
                              'Source: ${safeTip['source'] ?? 'Healthy Pathway'}',
                      style: TextStyle(
                        fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Share.share(
                              '${safeTip['tip']}\n\nSource: ${safeTip['source']}\nShared from Healthy Pathway App',
                              subject: 'Health Tip: ${safeTip['category']}',
                            );
                          },
                          icon: Icon(Icons.share, size: 18),
                          label: Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCategoryColor(safeTip['category']),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            getNextTipInCategory();
                          },
                          icon: Icon(Icons.skip_next, size: 18),
                          label: Text('Next Tip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade800,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
                ],
              ),
            ),
            
            SizedBox(height: 100), // Bottom padding for home button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: RoundHomeButton(),
        ),
      ),
    );
  }
}