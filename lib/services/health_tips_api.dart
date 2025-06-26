import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class HealthTipsApi {
  static const String _baseUrl = 'https://health.gov/api';
  
  // Multiple reliable health tips sources
  static const List<String> _healthTipsSources = [
    'https://health.gov/our-work/national-health-initiatives/health-literacy/consumer-health-content/free-web-content/apis',
    'https://www.who.int/health-topics',
    'https://www.cdc.gov/healthy-living',
  ];

  // Comprehensive local tips database as fallback
  static const List<Map<String, dynamic>> _localTips = [
    {
      'tip': 'Drink at least 8 glasses of water daily to stay hydrated and support your body\'s functions.',
      'category': 'Hydration',
      'source': 'WHO Guidelines',
      'icon': '💧',
    },
    {
      'tip': 'Get 7-9 hours of quality sleep each night to improve memory, mood, and overall health.',
      'category': 'Sleep',
      'source': 'Sleep Foundation',
      'icon': '😴',
    },
    {
      'tip': 'Eat a rainbow of fruits and vegetables to get diverse nutrients and antioxidants.',
      'category': 'Nutrition',
      'source': 'CDC Nutrition Guidelines',
      'icon': '🥗',
    },
    {
      'tip': 'Exercise for at least 150 minutes of moderate activity or 75 minutes of vigorous activity weekly.',
      'category': 'Fitness',
      'source': 'WHO Physical Activity Guidelines',
      'icon': '🏃‍♂️',
    },
    {
      'tip': 'Practice mindfulness or meditation for 10-15 minutes daily to reduce stress and improve mental health.',
      'category': 'Mental Health',
      'source': 'Mental Health Foundation',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Limit added sugars to less than 10% of your daily calories for better health outcomes.',
      'category': 'Nutrition',
      'source': 'WHO Sugar Guidelines',
      'icon': '🍯',
    },
    {
      'tip': 'Wash your hands frequently with soap and water for at least 20 seconds to prevent illness.',
      'category': 'Hygiene',
      'source': 'CDC Hygiene Guidelines',
      'icon': '🧼',
    },
    {
      'tip': 'Take regular breaks from screens every 20 minutes to protect your eye health.',
      'category': 'Eye Health',
      'source': 'American Academy of Ophthalmology',
      'icon': '👁️',
    },
    {
      'tip': 'Include protein-rich foods in every meal to support muscle health and satiety.',
      'category': 'Nutrition',
      'source': 'Nutrition Academy',
      'icon': '🥩',
    },
    {
      'tip': 'Practice good posture to prevent back pain and improve breathing efficiency.',
      'category': 'Posture',
      'source': 'Physical Therapy Association',
      'icon': '🧍‍♂️',
    },
    {
      'tip': 'Spend time in nature regularly to reduce stress and improve mental well-being.',
      'category': 'Mental Health',
      'source': 'Environmental Psychology Research',
      'icon': '🌳',
    },
    {
      'tip': 'Limit processed foods and choose whole, unprocessed foods when possible.',
      'category': 'Nutrition',
      'source': 'Nutrition Science',
      'icon': '🥑',
    },
    {
      'tip': 'Practice deep breathing exercises to reduce anxiety and improve lung function.',
      'category': 'Breathing',
      'source': 'Respiratory Health Institute',
      'icon': '🫁',
    },
    {
      'tip': 'Stay socially connected with friends and family to support mental and emotional health.',
      'category': 'Social Health',
      'source': 'Social Psychology Research',
      'icon': '👥',
    },
    {
      'tip': 'Use stairs instead of elevators when possible to increase daily physical activity.',
      'category': 'Fitness',
      'source': 'Physical Activity Guidelines',
      'icon': '🏢',
    },
    {
      'tip': 'Limit alcohol consumption to moderate levels for better liver and overall health.',
      'category': 'Lifestyle',
      'source': 'WHO Alcohol Guidelines',
      'icon': '🍷',
    },
    {
      'tip': 'Practice gratitude daily by writing down three things you\'re thankful for.',
      'category': 'Mental Health',
      'source': 'Positive Psychology Research',
      'icon': '🙏',
    },
    {
      'tip': 'Get regular health check-ups and screenings as recommended for your age and gender.',
      'category': 'Preventive Care',
      'source': 'Preventive Medicine Guidelines',
      'icon': '🏥',
    },
    {
      'tip': 'Include omega-3 rich foods like fish, nuts, and seeds in your diet for heart health.',
      'category': 'Nutrition',
      'source': 'Heart Health Association',
      'icon': '🐟',
    },
    {
      'tip': 'Practice good dental hygiene by brushing twice daily and flossing regularly.',
      'category': 'Dental Health',
      'source': 'American Dental Association',
      'icon': '🦷',
    },
    {
      'tip': 'Take vitamin D supplements or get 15-20 minutes of sunlight daily for bone health.',
      'category': 'Vitamins',
      'source': 'Endocrinology Society',
      'icon': '☀️',
    },
    {
      'tip': 'Practice portion control to maintain a healthy weight and prevent overeating.',
      'category': 'Weight Management',
      'source': 'Nutrition Science',
      'icon': '⚖️',
    },
    {
      'tip': 'Limit caffeine intake, especially in the afternoon, to improve sleep quality.',
      'category': 'Sleep',
      'source': 'Sleep Medicine Research',
      'icon': '☕',
    },
    {
      'tip': 'Practice stretching exercises daily to improve flexibility and prevent injuries.',
      'category': 'Fitness',
      'source': 'Sports Medicine',
      'icon': '🤸‍♀️',
    },
    {
      'tip': 'Eat slowly and mindfully to improve digestion and prevent overeating.',
      'category': 'Eating Habits',
      'source': 'Digestive Health Research',
      'icon': '🍽️',
    },
    {
      'tip': 'Practice good hand hygiene and avoid touching your face to prevent infections.',
      'category': 'Hygiene',
      'source': 'Infectious Disease Guidelines',
      'icon': '🤲',
    },
    {
      'tip': 'Include fiber-rich foods in your diet to support digestive health and satiety.',
      'category': 'Nutrition',
      'source': 'Gastroenterology Association',
      'icon': '🌾',
    },
    {
      'tip': 'Practice stress management techniques like yoga, tai chi, or progressive muscle relaxation.',
      'category': 'Stress Management',
      'source': 'Stress Research Institute',
      'icon': '🧘‍♂️',
    },
    {
      'tip': 'Stay hydrated before, during, and after exercise to maintain performance and prevent dehydration.',
      'category': 'Exercise',
      'source': 'Sports Nutrition Guidelines',
      'icon': '🏋️‍♂️',
    },
    {
      'tip': 'Practice good sleep hygiene by maintaining a consistent sleep schedule and creating a relaxing bedtime routine.',
      'category': 'Sleep',
      'source': 'Sleep Medicine',
      'icon': '🛏️',
    },
    {
      'tip': 'Include probiotic-rich foods like yogurt, kefir, and sauerkraut to support gut health.',
      'category': 'Gut Health',
      'source': 'Microbiome Research',
      'icon': '🦠',
    },
    {
      'tip': 'Practice good ergonomics at work to prevent musculoskeletal disorders.',
      'category': 'Workplace Health',
      'source': 'Occupational Health Guidelines',
      'icon': '💼',
    },
    {
      'tip': 'Limit exposure to blue light from screens in the evening to improve sleep quality.',
      'category': 'Sleep',
      'source': 'Circadian Rhythm Research',
      'icon': '📱',
    },
    {
      'tip': 'Practice good foot hygiene and wear comfortable, supportive shoes to prevent foot problems.',
      'category': 'Foot Health',
      'source': 'Podiatry Association',
      'icon': '👟',
    },
    {
      'tip': 'Include antioxidant-rich foods like berries, dark chocolate, and green tea in your diet.',
      'category': 'Nutrition',
      'source': 'Antioxidant Research',
      'icon': '🫐',
    },
    {
      'tip': 'Practice good posture while sitting and standing to prevent back and neck pain.',
      'category': 'Posture',
      'source': 'Physical Therapy',
      'icon': '🧍‍♀️',
    },
    {
      'tip': 'Take regular breaks from sitting every 30 minutes to improve circulation and reduce health risks.',
      'category': 'Sedentary Behavior',
      'source': 'Physical Activity Research',
      'icon': '🪑',
    },
    {
      'tip': 'Practice good skin care by using sunscreen daily and keeping your skin moisturized.',
      'category': 'Skin Health',
      'source': 'Dermatology Association',
      'icon': '🧴',
    },
    {
      'tip': 'Include calcium-rich foods in your diet to support bone health and prevent osteoporosis.',
      'category': 'Bone Health',
      'source': 'Osteoporosis Foundation',
      'icon': '🥛',
    },
    {
      'tip': 'Practice good hearing protection by avoiding loud noises and using ear protection when necessary.',
      'category': 'Hearing Health',
      'source': 'Audiology Association',
      'icon': '👂',
    },
    {
      'tip': 'Practice good vision care by having regular eye exams and protecting your eyes from UV radiation.',
      'category': 'Eye Health',
      'source': 'Ophthalmology Association',
      'icon': '👓',
    },
    {
      'tip': 'Practice good respiratory health by avoiding smoking and maintaining good indoor air quality.',
      'category': 'Respiratory Health',
      'source': 'Respiratory Medicine',
      'icon': '🫁',
    },
    {
      'tip': 'Practice good cardiovascular health by maintaining a healthy diet and regular exercise routine.',
      'category': 'Heart Health',
      'source': 'Cardiology Association',
      'icon': '❤️',
    },
    {
      'tip': 'Practice good mental health by seeking help when needed and maintaining social connections.',
      'category': 'Mental Health',
      'source': 'Mental Health Association',
      'icon': '🧠',
    },
    {
      'tip': 'Practice good reproductive health by having regular check-ups and practicing safe behaviors.',
      'category': 'Reproductive Health',
      'source': 'Reproductive Health Guidelines',
      'icon': '👶',
    },
    {
      'tip': 'Practice good aging health by staying active, eating well, and maintaining social connections.',
      'category': 'Aging',
      'source': 'Gerontology Research',
      'icon': '👴',
    },
    {
      'tip': 'Practice good environmental health by reducing exposure to pollutants and maintaining a clean living space.',
      'category': 'Environmental Health',
      'source': 'Environmental Health Institute',
      'icon': '🌍',
    },
    {
      'tip': 'Practice good occupational health by following safety guidelines and taking regular breaks.',
      'category': 'Occupational Health',
      'source': 'Occupational Safety Guidelines',
      'icon': '🏭',
    },
    {
      'tip': 'Practice good travel health by staying hydrated, moving regularly, and following destination health guidelines.',
      'category': 'Travel Health',
      'source': 'Travel Medicine Association',
      'icon': '✈️',
    },
    {
      'tip': 'Practice good seasonal health by adapting your routine to weather changes and seasonal health risks.',
      'category': 'Seasonal Health',
      'source': 'Seasonal Health Guidelines',
      'icon': '🍂',
    },
    {
      'tip': 'Practice good digital health by managing screen time and maintaining good posture while using devices.',
      'category': 'Digital Health',
      'source': 'Digital Wellness Research',
      'icon': '💻',
    },
    {
      'tip': 'Practice good financial health by managing stress related to finances and seeking help when needed.',
      'category': 'Financial Health',
      'source': 'Financial Wellness Institute',
      'icon': '💰',
    },
    {
      'tip': 'Practice good spiritual health by engaging in activities that provide meaning and purpose in life.',
      'category': 'Spiritual Health',
      'source': 'Spiritual Wellness Research',
      'icon': '🙏',
    },
    {
      'tip': 'Practice good intellectual health by engaging in lifelong learning and challenging your mind regularly.',
      'category': 'Intellectual Health',
      'source': 'Cognitive Health Research',
      'icon': '📚',
    },
    {
      'tip': 'Practice good creative health by engaging in artistic activities and expressing yourself creatively.',
      'category': 'Creative Health',
      'source': 'Art Therapy Association',
      'icon': '🎨',
    },
    {
      'tip': 'Practice good community health by participating in community activities and supporting local health initiatives.',
      'category': 'Community Health',
      'source': 'Community Health Guidelines',
      'icon': '🏘️',
    },
    {
      'tip': 'Practice good global health by staying informed about global health issues and supporting health initiatives.',
      'category': 'Global Health',
      'source': 'Global Health Organization',
      'icon': '🌎',
    },
    // Additional Nutrition tips
    {
      'tip': 'Eat breakfast within an hour of waking up to jumpstart your metabolism and improve concentration.',
      'category': 'Nutrition',
      'source': 'Nutrition Science',
      'icon': '🍳',
    },
    {
      'tip': 'Include healthy fats like avocados, nuts, and olive oil in your diet for brain health and satiety.',
      'category': 'Nutrition',
      'source': 'Nutrition Research',
      'icon': '🥑',
    },
    {
      'tip': 'Choose whole grains over refined grains to get more fiber and nutrients.',
      'category': 'Nutrition',
      'source': 'Whole Grain Council',
      'icon': '🌾',
    },
    {
      'tip': 'Eat mindfully by focusing on your food and avoiding distractions during meals.',
      'category': 'Nutrition',
      'source': 'Mindful Eating Research',
      'icon': '🍽️',
    },
    {
      'tip': 'Include a variety of colorful vegetables in your diet to get different antioxidants and nutrients.',
      'category': 'Nutrition',
      'source': 'Vegetable Nutrition Institute',
      'icon': '🥬',
    },
    // Additional Fitness tips
    {
      'tip': 'Start your day with a 10-minute stretching routine to improve flexibility and reduce stiffness.',
      'category': 'Fitness',
      'source': 'Sports Medicine',
      'icon': '🤸‍♀️',
    },
    {
      'tip': 'Include strength training exercises at least twice a week to build muscle and improve bone density.',
      'category': 'Fitness',
      'source': 'Strength Training Guidelines',
      'icon': '💪',
    },
    {
      'tip': 'Take a 30-minute walk during your lunch break to increase daily physical activity.',
      'category': 'Fitness',
      'source': 'Physical Activity Guidelines',
      'icon': '🚶‍♀️',
    },
    {
      'tip': 'Try high-intensity interval training (HIIT) for efficient calorie burning and cardiovascular fitness.',
      'category': 'Fitness',
      'source': 'Exercise Science',
      'icon': '⚡',
    },
    {
      'tip': 'Join a sports team or fitness class to make exercise more enjoyable and social.',
      'category': 'Fitness',
      'source': 'Social Fitness Research',
      'icon': '🏀',
    },
    // Additional Mental Health tips
    {
      'tip': 'Practice journaling daily to process emotions and improve self-awareness.',
      'category': 'Mental Health',
      'source': 'Psychology Research',
      'icon': '📝',
    },
    {
      'tip': 'Set aside time for hobbies and activities you enjoy to reduce stress and improve mood.',
      'category': 'Mental Health',
      'source': 'Mental Wellness Institute',
      'icon': '🎨',
    },
    {
      'tip': 'Practice positive self-talk and challenge negative thoughts to improve mental well-being.',
      'category': 'Mental Health',
      'source': 'Cognitive Behavioral Therapy',
      'icon': '💭',
    },
    {
      'tip': 'Learn to say no to commitments that cause unnecessary stress and prioritize your well-being.',
      'category': 'Mental Health',
      'source': 'Stress Management Research',
      'icon': '🙅‍♀️',
    },
    {
      'tip': 'Practice progressive muscle relaxation to reduce tension and improve sleep quality.',
      'category': 'Mental Health',
      'source': 'Relaxation Therapy',
      'icon': '😌',
    },
    // Additional Sleep tips
    {
      'tip': 'Create a relaxing bedtime routine that includes reading, gentle stretching, or meditation.',
      'category': 'Sleep',
      'source': 'Sleep Medicine',
      'icon': '📖',
    },
    {
      'tip': 'Keep your bedroom cool, dark, and quiet to create optimal sleep conditions.',
      'category': 'Sleep',
      'source': 'Sleep Environment Research',
      'icon': '🌙',
    },
    {
      'tip': 'Avoid large meals and alcohol close to bedtime to improve sleep quality.',
      'category': 'Sleep',
      'source': 'Sleep Nutrition Research',
      'icon': '🍽️',
    },
    {
      'tip': 'Use a white noise machine or app to block out distracting sounds and improve sleep.',
      'category': 'Sleep',
      'source': 'Sleep Technology Research',
      'icon': '🔊',
    },
    {
      'tip': 'Try the 4-7-8 breathing technique to help you fall asleep faster and reduce anxiety.',
      'category': 'Sleep',
      'source': 'Breathing Exercise Research',
      'icon': '🫁',
    },
    // Additional Hydration tips
    {
      'tip': 'Start your day with a glass of water to rehydrate after sleep and boost metabolism.',
      'category': 'Hydration',
      'source': 'Hydration Research',
      'icon': '🌅',
    },
    {
      'tip': 'Carry a reusable water bottle with you to make it easier to stay hydrated throughout the day.',
      'category': 'Hydration',
      'source': 'Environmental Health',
      'icon': '💧',
    },
    {
      'tip': 'Eat water-rich foods like cucumbers, watermelon, and celery to increase hydration.',
      'category': 'Hydration',
      'source': 'Nutrition Science',
      'icon': '🥒',
    },
    {
      'tip': 'Monitor your urine color - pale yellow indicates good hydration, dark yellow means you need more water.',
      'category': 'Hydration',
      'source': 'Medical Guidelines',
      'icon': '🔍',
    },
    {
      'tip': 'Drink water before, during, and after exercise to maintain performance and prevent dehydration.',
      'category': 'Hydration',
      'source': 'Sports Nutrition',
      'icon': '🏃‍♂️',
    },
    // Additional Stress Management tips
    {
      'tip': 'Practice time management techniques to reduce stress from feeling overwhelmed.',
      'category': 'Stress Management',
      'source': 'Time Management Research',
      'icon': '⏰',
    },
    {
      'tip': 'Learn to delegate tasks and ask for help when needed to reduce stress and workload.',
      'category': 'Stress Management',
      'source': 'Workplace Psychology',
      'icon': '🤝',
    },
    {
      'tip': 'Practice visualization techniques to imagine yourself in a peaceful, relaxing place.',
      'category': 'Stress Management',
      'source': 'Mindfulness Research',
      'icon': '🌴',
    },
    {
      'tip': 'Take regular breaks throughout the day to prevent stress buildup and maintain focus.',
      'category': 'Stress Management',
      'source': 'Productivity Research',
      'icon': '☕',
    },
    {
      'tip': 'Practice laughter yoga or watch funny videos to release endorphins and reduce stress.',
      'category': 'Stress Management',
      'source': 'Laughter Therapy Research',
      'icon': '😄',
    },
    // Additional Exercise tips
    {
      'tip': 'Try swimming for a full-body workout that\'s easy on your joints.',
      'category': 'Exercise',
      'source': 'Aquatic Exercise Research',
      'icon': '🏊‍♀️',
    },
    {
      'tip': 'Practice yoga to improve flexibility, strength, and mental clarity.',
      'category': 'Exercise',
      'source': 'Yoga Research Institute',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Go for a bike ride to improve cardiovascular health and leg strength.',
      'category': 'Exercise',
      'source': 'Cycling Health Association',
      'icon': '🚴‍♀️',
    },
    {
      'tip': 'Try dancing as a fun way to get your heart rate up and improve coordination.',
      'category': 'Exercise',
      'source': 'Dance Fitness Research',
      'icon': '💃',
    },
    {
      'tip': 'Practice martial arts to improve strength, flexibility, and mental discipline.',
      'category': 'Exercise',
      'source': 'Martial Arts Health Institute',
      'icon': '🥋',
    },
    // Additional Bone Health tips
    {
      'tip': 'Get regular weight-bearing exercise like walking or jogging to strengthen bones.',
      'category': 'Bone Health',
      'source': 'Osteoporosis Prevention',
      'icon': '🚶‍♀️',
    },
    {
      'tip': 'Include vitamin K-rich foods like leafy greens to support bone health.',
      'category': 'Bone Health',
      'source': 'Bone Nutrition Research',
      'icon': '🥬',
    },
    {
      'tip': 'Limit salt intake to prevent calcium loss from bones.',
      'category': 'Bone Health',
      'source': 'Bone Health Guidelines',
      'icon': '🧂',
    },
    {
      'tip': 'Get regular bone density screenings as recommended by your doctor.',
      'category': 'Bone Health',
      'source': 'Preventive Medicine',
      'icon': '🏥',
    },
  ];

  // Get a random health tip
  static Future<Map<String, dynamic>> getRandomTip() async {
    try {
      // Try to fetch from external API first
      final externalTip = await _fetchExternalTip();
      if (externalTip != null) {
        return externalTip;
      }
    } catch (e) {
      print('External API failed, using local tips: $e');
    }

    // Fallback to local tips
    return _getLocalTip();
  }

  // Get tips by category
  static Future<List<Map<String, dynamic>>> getTipsByCategory(String category) async {
    final filteredTips = _localTips.where((tip) => 
      tip['category'].toString().toLowerCase() == category.toLowerCase()
    ).toList();
    
    print('Category "$category" has ${filteredTips.length} tips'); // Debug print
    if (filteredTips.isNotEmpty) {
      print('Tips for "$category": ${filteredTips.map((t) => t['tip'].toString().substring(0, 30) + '...').toList()}');
    }
    
    return filteredTips;
  }

  // Get all available categories
  static List<String> getAllCategories() {
    final categories = _localTips.map((tip) => tip['category'] as String).toSet().toList();
    categories.sort();
    print('Available categories: $categories'); // Debug print
    return categories;
  }

  // Fetch tip from external API
  static Future<Map<String, dynamic>?> _fetchExternalTip() async {
    try {
      // Try multiple external sources
      final sources = [
        'https://api.quotable.io/random?tags=health,fitness',
        'https://api.adviceslip.com/advice',
        'https://api.goprogram.ai/inspiration',
      ];

      for (String source in sources) {
        try {
          final response = await http.get(Uri.parse(source)).timeout(
            const Duration(seconds: 5),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            // Parse different API formats
            String tip = '';
            String category = 'Wellness';
            
            if (source.contains('quotable')) {
              tip = data['content'] ?? '';
              category = 'Quote';
            } else if (source.contains('adviceslip')) {
              tip = data['slip']?['advice'] ?? '';
              category = 'Advice';
            } else if (source.contains('goprogram')) {
              tip = data['quote'] ?? '';
              category = 'Inspiration';
            }

            if (tip.isNotEmpty) {
              return {
                'tip': tip,
                'category': category,
                'source': 'External API',
                'icon': _getCategoryIcon(category),
              };
            }
          }
        } catch (e) {
          print('Failed to fetch from $source: $e');
          continue;
        }
      }
    } catch (e) {
      print('All external APIs failed: $e');
    }

    return null;
  }

  // Get local tip
  static Map<String, dynamic> _getLocalTip() {
    final random = Random();
    final tip = _localTips[random.nextInt(_localTips.length)];
    return {
      ...tip,
      'icon': _getCategoryIcon(tip['category']),
    };
  }

  // Get icon for category
  static String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hydration':
        return '💧';
      case 'sleep':
        return '😴';
      case 'nutrition':
        return '🥗';
      case 'fitness':
        return '🏃‍♂️';
      case 'mental health':
        return '🧘‍♀️';
      case 'hygiene':
        return '🧼';
      case 'eye health':
        return '👁️';
      case 'posture':
        return '🧍‍♂️';
      case 'breathing':
        return '🫁';
      case 'social health':
        return '👥';
      case 'lifestyle':
        return '🍷';
      case 'preventive care':
        return '🏥';
      case 'vitamins':
        return '☀️';
      case 'weight management':
        return '⚖️';
      case 'eating habits':
        return '🍽️';
      case 'stress management':
        return '🧘‍♂️';
      case 'exercise':
        return '🏋️‍♂️';
      case 'gut health':
        return '🦠';
      case 'workplace health':
        return '💼';
      case 'foot health':
        return '👟';
      case 'sedentary behavior':
        return '🪑';
      case 'skin health':
        return '🧴';
      case 'bone health':
        return '🥛';
      case 'hearing health':
        return '👂';
      case 'respiratory health':
        return '🫁';
      case 'heart health':
        return '❤️';
      case 'reproductive health':
        return '👶';
      case 'aging':
        return '👴';
      case 'environmental health':
        return '🌍';
      case 'occupational health':
        return '🏭';
      case 'travel health':
        return '✈️';
      case 'seasonal health':
        return '🍂';
      case 'digital health':
        return '💻';
      case 'financial health':
        return '💰';
      case 'spiritual health':
        return '🙏';
      case 'intellectual health':
        return '📚';
      case 'creative health':
        return '🎨';
      case 'community health':
        return '🏘️';
      case 'global health':
        return '🌎';
      default:
        return '💡';
    }
  }

  // Search tips by keyword
  static List<Map<String, dynamic>> searchTips(String keyword) {
    final lowercaseKeyword = keyword.toLowerCase();
    return _localTips.where((tip) => 
      tip['tip'].toString().toLowerCase().contains(lowercaseKeyword) ||
      tip['category'].toString().toLowerCase().contains(lowercaseKeyword)
    ).toList();
  }

  // Get daily tip (consistent for the day)
  static Map<String, dynamic> getDailyTip() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tipIndex = dayOfYear % _localTips.length;
    
    return {
      ..._localTips[tipIndex],
      'icon': _getCategoryIcon(_localTips[tipIndex]['category']),
    };
  }

  // Debug method to show category statistics
  static void printCategoryStats() {
    final categoryCounts = <String, int>{};
    for (final tip in _localTips) {
      final category = tip['category'] as String;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    print('=== CATEGORY STATISTICS ===');
    categoryCounts.forEach((category, count) {
      print('$category: $count tips');
    });
    print('==========================');
  }
} 