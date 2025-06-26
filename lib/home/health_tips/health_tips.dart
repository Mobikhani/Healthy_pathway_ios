import 'dart:math';
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

class _HealthTipsScreenState extends State<HealthTipsScreen> 
    with TickerProviderStateMixin {
  
  Map<String, dynamic> currentTip = {};
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
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
    
    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize with default tip
    currentTip = {
      'tip': 'Stay healthy and happy!',
      'category': 'Health',
      'icon': '💡',
      'source': 'Healthy Pathway',
    };

    // Load categories and initial tip
    _loadCategories();
    getRandomTip();
    startAutoChange();
  }

  void _loadCategories() {
    categories = ['All', ...HealthTipsApi.getAllCategories()];
    print('Loaded categories: $categories'); // Debug print
    HealthTipsApi.printCategoryStats(); // Print category statistics
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hydration':
        return const Color(0xFF2196F3);
      case 'sleep':
        return const Color(0xFF673AB7);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'fitness':
        return const Color(0xFFFF5722);
      case 'mental health':
        return const Color(0xFF9C27B0);
      case 'hygiene':
        return const Color(0xFF00BCD4);
      case 'eye health':
        return const Color(0xFF795548);
      case 'posture':
        return const Color(0xFF009688);
      case 'breathing':
        return const Color(0xFF607D8B);
      case 'social health':
        return const Color(0xFF3F51B5);
      case 'lifestyle':
        return const Color(0xFF607D8B);
      case 'preventive care':
        return const Color(0xFFE91E63);
      case 'vitamins':
        return const Color(0xFFFF9800);
      case 'weight management':
        return const Color(0xFF8D6E63);
      case 'eating habits':
        return const Color(0xFF5D4037);
      case 'stress management':
        return const Color(0xFF9C27B0);
      case 'exercise':
        return const Color(0xFFFF5722);
      case 'gut health':
        return const Color(0xFF8BC34A);
      case 'workplace health':
        return const Color(0xFF607D8B);
      case 'foot health':
        return const Color(0xFF795548);
      case 'sedentary behavior':
        return const Color(0xFF9E9E9E);
      case 'skin health':
        return const Color(0xFFFFAB91);
      case 'bone health':
        return const Color(0xFFD7CCC8);
      case 'hearing health':
        return const Color(0xFF90A4AE);
      case 'respiratory health':
        return const Color(0xFF81C784);
      case 'heart health':
        return const Color(0xFFE57373);
      case 'reproductive health':
        return const Color(0xFFF8BBD9);
      case 'aging':
        return const Color(0xFFBDBDBD);
      case 'environmental health':
        return const Color(0xFF4CAF50);
      case 'occupational health':
        return const Color(0xFF607D8B);
      case 'travel health':
        return const Color(0xFF42A5F5);
      case 'seasonal health':
        return const Color(0xFFFF8A65);
      case 'digital health':
        return const Color(0xFF5C6BC0);
      case 'financial health':
        return const Color(0xFFFFD54F);
      case 'spiritual health':
        return const Color(0xFF9C27B0);
      case 'intellectual health':
        return const Color(0xFF26A69A);
      case 'creative health':
        return const Color(0xFFEC407A);
      case 'community health':
        return const Color(0xFF66BB6A);
      case 'global health':
        return const Color(0xFF26C6DA);
      default:
        return const Color(0xFF00ACC1);
    }
  }

  Future<void> getRandomTip() async {
    setState(() {
      isLoading = true;
    });

    try {
      final tip = await HealthTipsApi.getRandomTip();
      setState(() {
        currentTip = tip;
        _tipIndex++;
        isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading tip: $e');
    }
  }

  Future<void> getTipByCategory(String category) async {
    if (category == 'All') {
      // Reset category-specific data
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
          selectedCategory = category; // Ensure category is set
          _tipIndex++;
          isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
        print('Loaded ${tips.length} tips for category: $category'); // Debug print
        print('Current tip index: $currentTipIndex, Total tips: ${tips.length}'); // Debug print
      } else {
        // If no tips found for category, get a random tip but keep the category selected
        setState(() {
          categoryTips = [];
          currentTipIndex = 0;
          selectedCategory = category; // Keep the category selected
        });
        await getRandomTip();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        categoryTips = [];
        currentTipIndex = 0;
        selectedCategory = category; // Keep the category selected even on error
      });
      print('Error loading tip by category: $e');
      // Fallback to random tip but keep category selected
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
      _animationController.reset();
      _animationController.forward();
      print('Showing tip ${currentTipIndex + 1} of ${categoryTips.length} for category: $selectedCategory'); // Debug print
    } else if (selectedCategory != 'All' && categoryTips.isEmpty) {
      // If category is selected but no tips loaded, try to load them
      getTipByCategory(selectedCategory);
    } else {
      // Only get random tip if "All" is selected
      getRandomTip();
    }
  }

  void startAutoChange() {
    _autoChangeTimer?.cancel(); // Cancel existing timer
    _autoChangeTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        getNextTipInCategory();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _autoChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  content: Text('Tips automatically change every 8 seconds. Tap the refresh button for a new tip anytime!'),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
              Color(0xFF01579B),
              Color(0xFF006064),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background animated circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // Main content
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header section
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.lightbulb,
                                          color: Colors.amber,
                                          size: 40,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Today\'s Health Tip',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                color: Colors.black.withOpacity(0.2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          selectedCategory == 'All' 
                                              ? 'Random Tips'
                                              : 'Category: $selectedCategory',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                color: Colors.black.withOpacity(0.2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        // Category filter dropdown
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedCategory,
                                              dropdownColor: Colors.white.withOpacity(0.9),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                              items: categories.map((String category) {
                                                return DropdownMenuItem<String>(
                                                  value: category,
                                                  child: Text(
                                                    category,
                                                    style: TextStyle(
                                                      color: category == 'All' ? Colors.white : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null && newValue != selectedCategory) {
                                                  print('Selected category: $newValue'); // Debug print
                                                  setState(() {
                                                    selectedCategory = newValue;
                                                  });
                                                  
                                                  // Cancel current timer and restart with new category
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
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Main tip card
                          Container(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _slideAnimation.value),
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        width: double.infinity,
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
                                                  Colors.white.withOpacity(0.95),
                                                  Colors.white.withOpacity(0.85),
                                                  const Color(0xFF00ACC1).withOpacity(0.05),
                                                ],
                                                stops: [0.0, 0.7, 1.0],
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
                                                          const Color(0xFF00ACC1).withOpacity(0.1),
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
                                                          const Color(0xFF007C91).withOpacity(0.08),
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
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  _getCategoryColor(currentTip['category'] ?? 'Health'),
                                                                  _getCategoryColor(currentTip['category'] ?? 'Health').withOpacity(0.7),
                                                                  _getCategoryColor(currentTip['category'] ?? 'Health').withOpacity(0.5),
                                                                ],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ),
                                                              borderRadius: BorderRadius.circular(18),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: _getCategoryColor(currentTip['category'] ?? 'Health').withOpacity(0.4),
                                                                  blurRadius: 12,
                                                                  offset: const Offset(0, 6),
                                                                  spreadRadius: 2,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              currentTip['icon'] ?? '💡',
                                                              style: const TextStyle(
                                                                fontSize: 32,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 20),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  currentTip['category'] ?? 'Health Tip',
                                                                  style: const TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Color(0xFF1A1A1A),
                                                                    letterSpacing: 0.5,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  selectedCategory == 'All' 
                                                                      ? 'Tip ${_tipIndex}'
                                                                      : 'Tip ${currentTipIndex + 1} of ${categoryTips.length}',
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.grey[600],
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 4),
                                                                Text(
                                                                  selectedCategory == 'All' 
                                                                      ? 'Random Tips'
                                                                      : 'Category: $selectedCategory',
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.grey[500],
                                                                    fontWeight: FontWeight.w400,
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
                                                                  const Color(0xFF00ACC1).withOpacity(0.1),
                                                                  const Color(0xFF007C91).withOpacity(0.1),
                                                                ],
                                                              ),
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Material(
                                                              color: Colors.transparent,
                                                              child: InkWell(
                                                                borderRadius: BorderRadius.circular(20),
                                                                onTap: () {
                                                                  _pulseController.forward().then((_) {
                                                                    _pulseController.reverse();
                                                                  });
                                                                  getNextTipInCategory();
                                                                },
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
                                                              const Color(0xFF00ACC1).withOpacity(0.08),
                                                              const Color(0xFF007C91).withOpacity(0.05),
                                                              Colors.white.withOpacity(0.3),
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(16),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: const Color(0xFF00ACC1).withOpacity(0.1),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: isLoading
                                                            ? Center(
                                                                child: Column(
                                                                  children: [
                                                                    CircularProgressIndicator(
                                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                                        const Color(0xFF00ACC1),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 16),
                                                                    Text(
                                                                      'Loading health tip...',
                                                                      style: TextStyle(
                                                                        color: const Color(0xFF004D61),
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : Column(
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
                                                                          '💡 Daily Wisdom',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: const Color(0xFF1A1A1A),
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
                                                                    currentTip['tip'] ?? 'Stay healthy!',
                                                                    style: const TextStyle(
                                                                      fontSize: 16,
                                                                      color: Color(0xFF1A1A1A),
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
                                                            children: selectedCategory == 'All'
                                                                ? List.generate(5, (index) => Container(
                                                                    width: 6,
                                                                    height: 6,
                                                                    margin: const EdgeInsets.only(right: 4),
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: index == 0 
                                                                          ? const Color(0xFF00ACC1)
                                                                          : const Color(0xFF00ACC1).withOpacity(0.3),
                                                                    ),
                                                                  ))
                                                                : List.generate(
                                                                    categoryTips.length > 5 ? 5 : categoryTips.length,
                                                                    (index) => Container(
                                                                      width: 6,
                                                                      height: 6,
                                                                      margin: const EdgeInsets.only(right: 4),
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                        color: index == currentTipIndex % (categoryTips.length > 5 ? 5 : categoryTips.length)
                                                                            ? const Color(0xFF00ACC1)
                                                                            : const Color(0xFF00ACC1).withOpacity(0.3),
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                  'Auto-refresh every 10s',
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.grey[600],
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // Share button
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  const Color(0xFF00ACC1).withOpacity(0.2),
                                                                  const Color(0xFF007C91).withOpacity(0.2),
                                                                ],
                                                              ),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Material(
                                                              color: Colors.transparent,
                                                              child: InkWell(
                                                                borderRadius: BorderRadius.circular(12),
                                                                onTap: () {
                                                                  Share.share(
                                                                    '💡 Health Tip: ${currentTip['tip']}\n\nFrom Healthy Pathway App',
                                                                    subject: 'Daily Health Tip',
                                                                  );
                                                                },
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.share,
                                                                      size: 14,
                                                                      color: const Color(0xFF004D61),
                                                                    ),
                                                                    const SizedBox(width: 4),
                                                                    Text(
                                                                      'Share',
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: const Color(0xFF004D61),
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
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
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Home button
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: RoundHomeButton(),
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