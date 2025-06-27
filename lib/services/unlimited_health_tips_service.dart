import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class UnlimitedHealthTipsService {
  static final Random _random = Random();
  
  // Multiple free APIs for health tips
  static const List<String> _apis = [
    'https://api.quotable.io/quotes?tags=health,fitness&limit=100',
    'https://api.quotable.io/quotes?tags=wellness&limit=100',
    'https://api.quotable.io/quotes?tags=life&limit=100',
  ];

  // Comprehensive fallback tips for each category
  static final Map<String, List<String>> _categoryTips = {
    'All': [
      '💡 Take a 5-minute walk every hour to boost your energy and improve circulation.',
      '🌟 Practice gratitude by writing down 3 things you\'re thankful for each day.',
      '🌱 Drink a glass of water first thing in the morning to rehydrate your body.',
      '🧘‍♀️ Take 3 deep breaths when feeling stressed to calm your nervous system.',
      '🏃‍♀️ Do 10 jumping jacks every morning to jumpstart your metabolism.',
      '😴 Create a relaxing bedtime routine to improve sleep quality.',
      '🧼 Wash your hands for 20 seconds to prevent illness spread.',
      '🏥 Schedule regular check-ups to catch health issues early.',
      '🌿 Add a handful of leafy greens to your meals for essential vitamins.',
      '💪 Stand up and stretch every 30 minutes when working at a desk.',
      '🎯 Set small, achievable health goals to build lasting habits.',
      '🌞 Get 15 minutes of sunlight daily for vitamin D and mood boost.',
      '📱 Take regular breaks from technology to reduce eye strain.',
      '🎵 Listen to calming music to reduce stress and anxiety.',
      '📚 Read a book for 20 minutes to relax and escape stress.',
      '🌿 Spend time in nature to reduce stress and improve mood.',
      '😊 Smile more - it releases endorphins and improves mood.',
      '👥 Maintain strong social connections for emotional well-being.',
      '🙏 Practice mindfulness meditation for inner peace.',
      '🎨 Engage in creative activities to boost mental health.',
      '💃 Dance for 15 minutes to make exercise fun and enjoyable.',
      '🏊‍♀️ Swim for a full-body, low-impact workout.',
      '🚴‍♀️ Cycle for 20 minutes to improve heart health.',
      '🏋️‍♀️ Lift weights 2-3 times per week for muscle strength.',
      '🧘‍♀️ Practice yoga for flexibility and stress relief.',
      '🚶‍♀️ Take a 30-minute walk daily for cardiovascular health.',
      '🦵 Squat 15 times to strengthen your legs and core.',
      '💪 Do 10 push-ups daily to build upper body strength.',
      '🎯 Do balance exercises to prevent falls and improve stability.',
    ],
    'Nutrition': [
      '🥗 Add a handful of leafy greens to your meals for essential vitamins and minerals.',
      '🍎 Eat an apple a day - it\'s packed with fiber and antioxidants.',
      '🥜 Include nuts in your diet for healthy fats and protein.',
      '🐟 Eat fatty fish twice a week for heart-healthy omega-3s.',
      '🥛 Include calcium-rich foods like yogurt in your daily diet.',
      '🍊 Add citrus fruits to your diet for vitamin C and immune support.',
      '🥑 Use avocado instead of butter for healthier fats.',
      '🌾 Choose whole grains over refined grains for better nutrition.',
      '🥕 Eat colorful vegetables for a variety of nutrients.',
      '💧 Stay hydrated by drinking water throughout the day.',
      '🍯 Use honey instead of refined sugar when possible.',
      '🥚 Include eggs in your diet for high-quality protein.',
      '🍠 Sweet potatoes are rich in beta-carotene and fiber.',
      '🥬 Kale is a superfood packed with vitamins and minerals.',
      '🫐 Blueberries are rich in antioxidants and brain-boosting compounds.',
      '🥜 Almonds are great for heart health and energy.',
      '🍵 Green tea contains antioxidants and may boost metabolism.',
      '🥛 Greek yogurt is high in protein and probiotics.',
      '🌰 Walnuts are rich in omega-3 fatty acids.',
      '🍇 Grapes contain resveratrol, a heart-healthy compound.',
      '🥭 Mangoes are rich in vitamin C and digestive enzymes.',
      '🍍 Pineapple contains bromelain, an anti-inflammatory enzyme.',
      '🥝 Kiwi is packed with vitamin C and fiber.',
      '🍓 Strawberries are rich in antioxidants and vitamin C.',
      '🫑 Bell peppers are high in vitamin C and antioxidants.',
      '🥦 Broccoli is a cruciferous vegetable with cancer-fighting properties.',
      '🧄 Garlic has natural antibacterial and antiviral properties.',
      '🧅 Onions contain compounds that support heart health.',
      '🍅 Tomatoes are rich in lycopene, a powerful antioxidant.',
    ],
    'Exercise': [
      '🏃‍♀️ Do 10 jumping jacks every morning to jumpstart your metabolism.',
      '💪 Do 10 push-ups daily to build upper body strength.',
      '🦵 Squat 15 times to strengthen your legs and core.',
      '🚶‍♀️ Take a 30-minute walk daily for cardiovascular health.',
      '🧘‍♀️ Practice yoga for flexibility and stress relief.',
      '🏋️‍♀️ Lift weights 2-3 times per week for muscle strength.',
      '🚴‍♀️ Cycle for 20 minutes to improve heart health.',
      '🏊‍♀️ Swim for a full-body, low-impact workout.',
      '🎯 Do balance exercises to prevent falls and improve stability.',
      '💃 Dance for 15 minutes to make exercise fun and enjoyable.',
      '🏃‍♂️ Run for 15 minutes to boost cardiovascular fitness.',
      '🤸‍♀️ Do 10 burpees for a full-body workout.',
      '🦵 Do lunges to strengthen your legs and improve balance.',
      '💪 Do planks for 30 seconds to strengthen your core.',
      '🏋️‍♂️ Use resistance bands for strength training anywhere.',
      '🧘‍♂️ Practice tai chi for gentle exercise and stress relief.',
      '🏃‍♀️ Do high-intensity interval training (HIIT) for maximum efficiency.',
      '🚴‍♂️ Mountain biking provides both cardio and strength benefits.',
      '🏊‍♂️ Water aerobics is great for joint health and fitness.',
      '🎯 Practice martial arts for fitness and self-defense.',
      '💃 Zumba combines dance and fitness for a fun workout.',
      '🏃‍♀️ Trail running provides varied terrain and fresh air.',
      '🚴‍♀️ Indoor cycling is great for cardiovascular health.',
      '🏋️‍♀️ CrossFit combines strength and cardio training.',
      '🧘‍♀️ Pilates focuses on core strength and flexibility.',
      '🏃‍♂️ Sprint intervals boost metabolism and fitness.',
      '💪 Bodyweight exercises require no equipment.',
      '🎯 Circuit training combines multiple exercises efficiently.',
    ],
    'Mental Health': [
      '🧘‍♀️ Practice deep breathing for 2 minutes to reduce stress and anxiety.',
      '🌸 Practice gratitude by writing down 3 things you\'re thankful for.',
      '📱 Limit screen time before bed to improve sleep quality.',
      '🎨 Engage in creative activities to boost mental health.',
      '👥 Maintain strong social connections for emotional well-being.',
      '🙏 Practice mindfulness meditation for inner peace.',
      '🌿 Spend time in nature to reduce stress and improve mood.',
      '📚 Read a book for 20 minutes to relax and escape stress.',
      '🎵 Listen to calming music to reduce anxiety.',
      '😊 Smile more - it releases endorphins and improves mood.',
      '🧘‍♂️ Practice progressive muscle relaxation for stress relief.',
      '📝 Journal your thoughts and feelings daily.',
      '🌅 Watch the sunrise to start your day with positivity.',
      '🌙 Practice good sleep hygiene for better mental health.',
      '🎯 Set realistic goals to avoid feeling overwhelmed.',
      '💆‍♀️ Take regular mental health breaks throughout the day.',
      '🌱 Learn something new to keep your mind active.',
      '🎭 Express yourself through art, music, or writing.',
      '🏃‍♀️ Exercise regularly to boost mood and reduce anxiety.',
      '🍃 Practice forest bathing - spend time in nature.',
      '🎪 Try something new and exciting to boost happiness.',
      '💝 Practice random acts of kindness for others.',
      '🧠 Challenge your brain with puzzles and games.',
      '🌊 Listen to nature sounds for relaxation.',
      '🎨 Color or draw to reduce stress and anxiety.',
      '📖 Read positive affirmations daily.',
      '🎵 Create a playlist of uplifting songs.',
      '🌿 Use aromatherapy with calming essential oils.',
    ],
    'Sleep': [
      '😴 Create a relaxing bedtime routine to improve sleep quality.',
      '🌙 Keep your bedroom cool and dark for better sleep.',
      '📱 Avoid screens 1 hour before bedtime for better sleep.',
      '☕ Avoid caffeine after 2 PM to improve sleep quality.',
      '🛏️ Use your bed only for sleep and intimacy.',
      '🌅 Wake up at the same time every day, even on weekends.',
      '🧘‍♀️ Practice relaxation techniques before bed.',
      '📖 Read a book instead of scrolling on your phone.',
      '🛁 Take a warm bath before bed to relax.',
      '🌿 Use lavender essential oil for better sleep.',
      '🎵 Listen to white noise or calming sounds.',
      '🌡️ Keep your bedroom temperature between 65-68°F.',
      '🕐 Go to bed at the same time every night.',
      '🍵 Drink chamomile tea before bed for relaxation.',
      '🧘‍♂️ Practice meditation before sleep.',
      '📱 Put your phone in another room while sleeping.',
      '🛏️ Invest in a comfortable mattress and pillows.',
      '🌙 Use blackout curtains to block light.',
      '🎧 Use earplugs if noise disturbs your sleep.',
      '🕯️ Use a diffuser with calming essential oils.',
      '📚 Read a physical book instead of digital content.',
      '🧘‍♀️ Do gentle stretching before bed.',
      '🌿 Try valerian root tea for natural sleep aid.',
      '🎵 Create a sleep playlist with calming music.',
      '🕐 Set a bedtime alarm to remind you to sleep.',
      '🌅 Get morning sunlight to regulate your sleep cycle.',
      '🛏️ Make your bedroom a sleep sanctuary.',
    ],
    'Hydration': [
      '💧 Drink a glass of water first thing in the morning to rehydrate.',
      '🚰 Carry a water bottle with you throughout the day.',
      '🍋 Add lemon to your water for flavor and vitamin C.',
      '🥤 Replace sugary drinks with water or herbal tea.',
      '🌡️ Drink more water when it\'s hot or when exercising.',
      '🍵 Drink herbal tea for hydration and health benefits.',
      '🥛 Include milk or plant-based milk for calcium.',
      '🍉 Eat water-rich fruits like watermelon and cucumber.',
      '🥤 Set reminders to drink water regularly.',
      '💧 Drink water before meals to help with portion control.',
      '🍊 Add orange slices to water for natural flavor.',
      '🥒 Cucumber water is refreshing and hydrating.',
      '🍓 Add strawberries to water for a sweet treat.',
      '🌿 Mint leaves in water provide fresh flavor.',
      '🍋 Lemon water supports digestion and immunity.',
      '🥤 Drink coconut water for natural electrolytes.',
      '🍵 Green tea provides antioxidants and hydration.',
      '🥛 Almond milk is a good dairy alternative.',
      '🍉 Watermelon is 92% water and very hydrating.',
      '🥒 Celery is high in water content and fiber.',
      '🍊 Oranges are juicy and vitamin C rich.',
      '🍎 Apples are hydrating and fiber-rich.',
      '🥬 Lettuce is 96% water and very low calorie.',
      '🍅 Tomatoes are 94% water and nutrient-rich.',
      '🥤 Set phone reminders to drink water every hour.',
      '💧 Drink water when you feel hungry - you might be thirsty.',
      '🌡️ Monitor your urine color - pale yellow is ideal.',
    ],
    'Stress Management': [
      '🌸 Practice gratitude by writing down 3 things you\'re thankful for.',
      '🧘‍♀️ Practice deep breathing for 2 minutes to reduce stress.',
      '🌿 Spend time in nature to reduce stress and improve mood.',
      '🎵 Listen to calming music to reduce anxiety.',
      '📱 Take regular breaks from technology.',
      '🏃‍♀️ Exercise regularly to reduce stress hormones.',
      '😊 Practice smiling and positive thinking.',
      '📚 Read a book to escape and relax.',
      '🎨 Engage in creative activities to reduce stress.',
      '👥 Talk to friends and family for emotional support.',
      '🧘‍♂️ Practice progressive muscle relaxation.',
      '🌅 Take a 10-minute walk in nature.',
      '🎵 Create a stress-relief playlist.',
      '📝 Write down your worries and let them go.',
      '🌿 Use essential oils like lavender for relaxation.',
      '🎯 Focus on one task at a time to reduce overwhelm.',
      '💆‍♀️ Practice self-massage for tension relief.',
      '🌊 Listen to ocean waves or nature sounds.',
      '🎨 Try adult coloring books for stress relief.',
      '🧘‍♀️ Practice yoga for mind-body relaxation.',
      '📱 Set boundaries with technology use.',
      '🎪 Find humor in daily situations.',
      '🌱 Practice mindfulness in daily activities.',
      '💝 Do something kind for someone else.',
      '🎵 Play an instrument or sing for joy.',
      '🌿 Garden or care for plants.',
      '📖 Read positive quotes daily.',
    ],
    'Prevention': [
      '🏥 Schedule regular check-ups to catch health issues early.',
      '🧼 Wash your hands for 20 seconds to prevent illness spread.',
      '💉 Get recommended vaccinations to prevent diseases.',
      '🦷 Brush your teeth for 2 minutes twice daily for optimal oral health.',
      '🧴 Apply sunscreen daily, even on cloudy days, to protect your skin.',
      '👁️ Follow the 20-20-20 rule: every 20 minutes, look 20 feet away for 20 seconds.',
      '🦴 Include calcium-rich foods like yogurt in your daily diet.',
      '🛡️ Get 7-8 hours of sleep to strengthen your immune system.',
      '❤️ Eat fatty fish twice a week for heart-healthy omega-3s.',
      '🌱 Take the stairs instead of the elevator for extra daily exercise.',
      '🍎 Eat an apple a day to keep the doctor away.',
      '🧘‍♀️ Practice stress management to prevent chronic diseases.',
      '🚭 Avoid smoking and secondhand smoke.',
      '🍷 Limit alcohol consumption for better health.',
      '🌞 Get moderate sun exposure for vitamin D.',
      '🏃‍♀️ Exercise regularly to prevent chronic diseases.',
      '🥗 Eat a balanced diet rich in fruits and vegetables.',
      '💧 Stay hydrated to support all body functions.',
      '🧘‍♂️ Practice good posture to prevent back problems.',
      '👁️ Get regular eye exams to maintain vision health.',
      '🦷 Floss daily to prevent gum disease.',
      '🧴 Use moisturizer to maintain skin health.',
      '🏃‍♀️ Stay active to prevent age-related muscle loss.',
      '🧠 Challenge your brain to prevent cognitive decline.',
      '👥 Maintain social connections for mental health.',
      '🌿 Use natural cleaning products to reduce chemical exposure.',
      '🏠 Keep your home clean and allergen-free.',
    ],
  };

  static Future<String> generateHealthTip(String category) async {
    try {
      // Try to get tips from free APIs first
      final apiTip = await _getTipFromAPI(category);
      if (apiTip != null) {
        return apiTip;
      }
    } catch (e) {
      print('❌ API call failed: $e');
    }

    // Fallback to our comprehensive local tips
    return _getRandomLocalTip(category);
  }

  static Future<String?> _getTipFromAPI(String category) async {
    try {
      // Use a random API from our list
      final apiUrl = _apis[_random.nextInt(_apis.length)];
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('results')) {
          final quotes = data['results'] as List;
          if (quotes.isNotEmpty) {
            final randomQuote = quotes[_random.nextInt(quotes.length)];
            final content = randomQuote['content'] as String;
            final author = randomQuote['author'] as String;
            
            // Convert quote to health tip format
            return _convertQuoteToHealthTip(content, author, category);
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching from API: $e');
    }
    
    return null;
  }

  static String _convertQuoteToHealthTip(String quote, String author, String category) {
    // Add category-specific emoji and format
    final emoji = _getCategoryEmoji(category);
    return '$emoji $quote - $author';
  }

  static String _getCategoryEmoji(String category) {
    final emojis = {
      'All': '💡',
      'Nutrition': '🥗',
      'Exercise': '🏃‍♀️',
      'Mental Health': '🧠',
      'Sleep': '😴',
      'Hydration': '💧',
      'Stress Management': '🌸',
      'Prevention': '🛡️',
    };
    return emojis[category] ?? '💡';
  }

  static String _getRandomLocalTip(String category) {
    final tips = _categoryTips[category] ?? _categoryTips['All']!;
    return tips[_random.nextInt(tips.length)];
  }

  static List<String> getAvailableCategories() {
    return _categoryTips.keys.toList();
  }

  static String getCategoryDescription(String category) {
    final descriptions = {
      'All': 'general health and wellness',
      'Nutrition': 'healthy eating and diet',
      'Exercise': 'physical activity and fitness',
      'Mental Health': 'mental wellness and emotional health',
      'Sleep': 'sleep hygiene and rest',
      'Hydration': 'water intake and fluid balance',
      'Stress Management': 'stress reduction and relaxation',
      'Prevention': 'disease prevention and health maintenance',
    };
    return descriptions[category] ?? 'general health and wellness';
  }

  static String getCategoryIcon(String category) {
    final icons = {
      'All': '🌟',
      'Nutrition': '🥗',
      'Exercise': '🏃‍♀️',
      'Mental Health': '🧠',
      'Sleep': '😴',
      'Hydration': '💧',
      'Stress Management': '🌸',
      'Prevention': '🛡️',
    };
    return icons[category] ?? '🌟';
  }
} 