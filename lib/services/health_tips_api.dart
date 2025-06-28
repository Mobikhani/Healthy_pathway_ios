import 'dart:convert';
import 'dart:math';

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
    {
      'tip': 'Drink herbal teas for hydration and additional health benefits.',
      'category': 'Hydration',
      'source': 'Herbal Medicine',
      'icon': '🍵',
    },
    {
      'tip': 'Eat water-rich foods like watermelon and cucumbers.',
      'category': 'Hydration',
      'source': 'Nutrition Science',
      'icon': '🍉',
    },
    {
      'tip': 'Set hydration reminders on your phone.',
      'category': 'Hydration',
      'source': 'Digital Health',
      'icon': '📱',
    },
    {
      'tip': 'Drink water with every meal and snack.',
      'category': 'Hydration',
      'source': 'Nutrition Guidelines',
      'icon': '🍽️',
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
    // Additional Fitness tips
    {
      'tip': 'Practice yoga for improved flexibility, balance, and stress reduction.',
      'category': 'Fitness',
      'source': 'Yoga Institute',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Take a 30-minute walk daily to improve cardiovascular health and mood.',
      'category': 'Fitness',
      'source': 'Walking Health Association',
      'icon': '🚶‍♀️',
    },
    {
      'tip': 'Try swimming for a full-body workout that\'s easy on the joints.',
      'category': 'Fitness',
      'source': 'Aquatic Exercise Association',
      'icon': '🏊‍♀️',
    },
    {
      'tip': 'Practice Pilates to strengthen your core and improve posture.',
      'category': 'Fitness',
      'source': 'Pilates Method Alliance',
      'icon': '🤸‍♂️',
    },
    {
      'tip': 'Try cycling for cardiovascular fitness and leg strength.',
      'category': 'Fitness',
      'source': 'Cycling Health Institute',
      'icon': '🚴‍♀️',
    },
    // Additional Hydration tips
    {
      'tip': 'Drink a glass of water first thing in the morning to rehydrate after sleep.',
      'category': 'Hydration',
      'source': 'Hydration Research',
      'icon': '🌅',
    },
    {
      'tip': 'Carry a reusable water bottle to stay hydrated throughout the day.',
      'category': 'Hydration',
      'source': 'Environmental Health',
      'icon': '💧',
    },
    {
      'tip': 'Add lemon or cucumber to your water for flavor and additional nutrients.',
      'category': 'Hydration',
      'source': 'Nutrition Science',
      'icon': '🍋',
    },
    {
      'tip': 'Drink water before meals to help with portion control and digestion.',
      'category': 'Hydration',
      'source': 'Digestive Health',
      'icon': '🍽️',
    },
    {
      'tip': 'Monitor your urine color - pale yellow indicates good hydration.',
      'category': 'Hydration',
      'source': 'Urology Association',
      'icon': '🔍',
    },
    {
      'tip': 'Increase water intake during hot weather or exercise.',
      'category': 'Hydration',
      'source': 'Sports Medicine',
      'icon': '☀️',
    },
    {
      'tip': 'Drink herbal teas for hydration and additional health benefits.',
      'category': 'Hydration',
      'source': 'Herbal Medicine',
      'icon': '🍵',
    },
    {
      'tip': 'Eat water-rich foods like watermelon and cucumbers.',
      'category': 'Hydration',
      'source': 'Nutrition Science',
      'icon': '🍉',
    },
    {
      'tip': 'Set hydration reminders on your phone.',
      'category': 'Hydration',
      'source': 'Digital Health',
      'icon': '📱',
    },
    {
      'tip': 'Drink water with every meal and snack.',
      'category': 'Hydration',
      'source': 'Nutrition Guidelines',
      'icon': '🍽️',
    },
    // Additional Sleep tips
    {
      'tip': 'Create a relaxing bedtime routine to signal your body it\'s time to sleep.',
      'category': 'Sleep',
      'source': 'Sleep Medicine',
      'icon': '🛁',
    },
    {
      'tip': 'Keep your bedroom cool, dark, and quiet for optimal sleep conditions.',
      'category': 'Sleep',
      'source': 'Sleep Environment Research',
      'icon': '🌙',
    },
    {
      'tip': 'Avoid large meals and caffeine 2-3 hours before bedtime.',
      'category': 'Sleep',
      'source': 'Sleep Science',
      'icon': '🍽️',
    },
    {
      'tip': 'Use a white noise machine or app to block out distracting sounds.',
      'category': 'Sleep',
      'source': 'Sleep Technology',
      'icon': '🔊',
    },
    {
      'tip': 'Try progressive muscle relaxation to help you fall asleep faster.',
      'category': 'Sleep',
      'source': 'Relaxation Therapy',
      'icon': '😌',
    },
    {
      'tip': 'Limit screen time before bed to reduce blue light exposure.',
      'category': 'Sleep',
      'source': 'Circadian Rhythm Research',
      'icon': '📱',
    },
    {
      'tip': 'Try reading a book before bed instead of using electronic devices.',
      'category': 'Sleep',
      'source': 'Sleep Hygiene',
      'icon': '📖',
    },
    {
      'tip': 'Use a weighted blanket to improve sleep quality and reduce anxiety.',
      'category': 'Sleep',
      'source': 'Sleep Therapy',
      'icon': '🛏️',
    },
    {
      'tip': 'Practice deep breathing exercises to calm your mind before sleep.',
      'category': 'Sleep',
      'source': 'Breathing Techniques',
      'icon': '🫁',
    },
    {
      'tip': 'Keep your bedroom temperature between 65-68°F for optimal sleep.',
      'category': 'Sleep',
      'source': 'Sleep Science',
      'icon': '🌡️',
    },
    {
      'tip': 'Avoid heavy meals 2-3 hours before bedtime.',
      'category': 'Sleep',
      'source': 'Sleep Medicine',
      'icon': '🍽️',
    },
    {
      'tip': 'Try aromatherapy with lavender essential oil for better sleep.',
      'category': 'Sleep',
      'source': 'Aromatherapy',
      'icon': '🌸',
    },
    {
      'tip': 'Practice gentle stretching before bed to relax your muscles.',
      'category': 'Sleep',
      'source': 'Sleep Hygiene',
      'icon': '🤸‍♀️',
    },
    {
      'tip': 'Use blackout curtains to block out light for better sleep.',
      'category': 'Sleep',
      'source': 'Sleep Environment',
      'icon': '🌙',
    },
    {
      'tip': 'Try meditation or guided imagery before sleep.',
      'category': 'Sleep',
      'source': 'Mindfulness',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Keep a consistent sleep schedule, even on weekends.',
      'category': 'Sleep',
      'source': 'Sleep Science',
      'icon': '📅',
    },
    // Additional Mental Health tips
    {
      'tip': 'Practice journaling to process emotions and reduce stress.',
      'category': 'Mental Health',
      'source': 'Psychology Research',
      'icon': '📝',
    },
    {
      'tip': 'Learn to say no to commitments that cause unnecessary stress.',
      'category': 'Mental Health',
      'source': 'Stress Management',
      'icon': '🚫',
    },
    {
      'tip': 'Practice self-compassion and treat yourself with kindness.',
      'category': 'Mental Health',
      'source': 'Positive Psychology',
      'icon': '💝',
    },
    {
      'tip': 'Engage in hobbies and activities that bring you joy.',
      'category': 'Mental Health',
      'source': 'Wellness Psychology',
      'icon': '🎯',
    },
    {
      'tip': 'Practice cognitive behavioral techniques to challenge negative thoughts.',
      'category': 'Mental Health',
      'source': 'CBT Research',
      'icon': '🧠',
    },
    {
      'tip': 'Set realistic goals and celebrate small achievements.',
      'category': 'Mental Health',
      'source': 'Goal Psychology',
      'icon': '🎉',
    },
    {
      'tip': 'Practice emotional regulation techniques like the 4-7-8 breathing method.',
      'category': 'Mental Health',
      'source': 'Emotional Intelligence',
      'icon': '🫁',
    },
    {
      'tip': 'Seek professional help when needed - it\'s a sign of strength, not weakness.',
      'category': 'Mental Health',
      'source': 'Mental Health Association',
      'icon': '🤝',
    },
    {
      'tip': 'Practice positive affirmations daily to improve self-esteem.',
      'category': 'Mental Health',
      'source': 'Positive Psychology',
      'icon': '✨',
    },
    // Additional Nutrition tips
    {
      'tip': 'Eat protein with every meal to maintain muscle mass and feel full longer.',
      'category': 'Nutrition',
      'source': 'Protein Research',
      'icon': '🥩',
    },
    {
      'tip': 'Choose healthy snacks like nuts, fruits, or Greek yogurt.',
      'category': 'Nutrition',
      'source': 'Snacking Science',
      'icon': '🥜',
    },
    {
      'tip': 'Cook meals at home to control ingredients and portion sizes.',
      'category': 'Nutrition',
      'source': 'Home Cooking Benefits',
      'icon': '👨‍🍳',
    },
    {
      'tip': 'Use herbs and spices instead of salt to flavor your food.',
      'category': 'Nutrition',
      'source': 'Culinary Medicine',
      'icon': '🌿',
    },
    {
      'tip': 'Eat seasonal fruits and vegetables for better taste and nutrition.',
      'category': 'Nutrition',
      'source': 'Seasonal Nutrition',
      'icon': '🍓',
    },
    {
      'tip': 'Include fermented foods like kimchi and kombucha for gut health.',
      'category': 'Nutrition',
      'source': 'Fermentation Science',
      'icon': '🥬',
    },
    {
      'tip': 'Choose lean protein sources like chicken, fish, and legumes.',
      'category': 'Nutrition',
      'source': 'Protein Quality',
      'icon': '🐟',
    },
    {
      'tip': 'Eat the rainbow - different colored foods provide different nutrients.',
      'category': 'Nutrition',
      'source': 'Phytonutrient Research',
      'icon': '🌈',
    },
    {
      'tip': 'Practice intuitive eating by listening to your body\'s hunger cues.',
      'category': 'Nutrition',
      'source': 'Intuitive Eating',
      'icon': '👂',
    },
    {
      'tip': 'Limit processed foods and choose whole foods when possible.',
      'category': 'Nutrition',
      'source': 'Whole Food Nutrition',
      'icon': '🥑',
    },
    {
      'tip': 'Stay hydrated by drinking water throughout the day.',
      'category': 'Nutrition',
      'source': 'Hydration Science',
      'icon': '💧',
    },
    {
      'tip': 'Include healthy fats like olive oil and avocados in your diet.',
      'category': 'Nutrition',
      'source': 'Healthy Fats Research',
      'icon': '🫒',
    },
    // Additional Stress Management tips
    {
      'tip': 'Practice time management to reduce stress from feeling overwhelmed.',
      'category': 'Stress Management',
      'source': 'Time Management',
      'icon': '⏰',
    },
    {
      'tip': 'Take regular breaks throughout the day to prevent burnout.',
      'category': 'Stress Management',
      'source': 'Workplace Wellness',
      'icon': '☕',
    },
    {
      'tip': 'Practice visualization techniques to reduce anxiety.',
      'category': 'Stress Management',
      'source': 'Visualization Therapy',
      'icon': '🌅',
    },
    {
      'tip': 'Use aromatherapy with lavender or chamomile to promote relaxation.',
      'category': 'Stress Management',
      'source': 'Aromatherapy Research',
      'icon': '🌸',
    },
    {
      'tip': 'Practice progressive muscle relaxation to release tension.',
      'category': 'Stress Management',
      'source': 'Relaxation Techniques',
      'icon': '💆‍♀️',
    },
    {
      'tip': 'Listen to calming music to reduce stress and anxiety.',
      'category': 'Stress Management',
      'source': 'Music Therapy',
      'icon': '🎵',
    },
    {
      'tip': 'Practice mindfulness meditation for 10 minutes daily.',
      'category': 'Stress Management',
      'source': 'Mindfulness Research',
      'icon': '🧘‍♂️',
    },
    {
      'tip': 'Engage in physical activity to release endorphins and reduce stress.',
      'category': 'Stress Management',
      'source': 'Exercise Psychology',
      'icon': '🏃‍♀️',
    },
    {
      'tip': 'Practice deep breathing exercises when feeling stressed.',
      'category': 'Stress Management',
      'source': 'Breathing Techniques',
      'icon': '🫁',
    },
    {
      'tip': 'Set boundaries with work and personal life to prevent stress.',
      'category': 'Stress Management',
      'source': 'Work-Life Balance',
      'icon': '⚖️',
    },
    // Additional Exercise tips
    {
      'tip': 'Warm up before exercise to prevent injuries and improve performance.',
      'category': 'Exercise',
      'source': 'Sports Medicine',
      'icon': '🔥',
    },
    {
      'tip': 'Cool down after exercise to help your body recover.',
      'category': 'Exercise',
      'source': 'Exercise Physiology',
      'icon': '❄️',
    },
    {
      'tip': 'Vary your exercise routine to prevent boredom and plateaus.',
      'category': 'Exercise',
      'source': 'Exercise Science',
      'icon': '🔄',
    },
    {
      'tip': 'Listen to your body and rest when needed to prevent overtraining.',
      'category': 'Exercise',
      'source': 'Sports Medicine',
      'icon': '👂',
    },
    {
      'tip': 'Set realistic fitness goals and track your progress.',
      'category': 'Exercise',
      'source': 'Fitness Psychology',
      'icon': '🎯',
    },
    {
      'tip': 'Find an exercise buddy to stay motivated and accountable.',
      'category': 'Exercise',
      'source': 'Social Fitness',
      'icon': '👥',
    },
    {
      'tip': 'Try different types of exercise to find what you enjoy.',
      'category': 'Exercise',
      'source': 'Exercise Variety',
      'icon': '🎨',
    },
    {
      'tip': 'Exercise outdoors when possible for additional mental health benefits.',
      'category': 'Exercise',
      'source': 'Outdoor Exercise',
      'icon': '🌳',
    },
    {
      'tip': 'Include both cardio and strength training in your routine.',
      'category': 'Exercise',
      'source': 'Balanced Fitness',
      'icon': '⚖️',
    },
    {
      'tip': 'Stay consistent with your exercise routine for best results.',
      'category': 'Exercise',
      'source': 'Exercise Consistency',
      'icon': '📅',
    },
    // Additional Hygiene tips
    {
      'tip': 'Shower daily to maintain personal hygiene and prevent skin issues.',
      'category': 'Hygiene',
      'source': 'Personal Hygiene',
      'icon': '🚿',
    },
    {
      'tip': 'Brush your teeth twice daily and floss regularly.',
      'category': 'Hygiene',
      'source': 'Dental Hygiene',
      'icon': '🦷',
    },
    {
      'tip': 'Wash your face twice daily to prevent acne and maintain skin health.',
      'category': 'Hygiene',
      'source': 'Skincare',
      'icon': '🧼',
    },
    {
      'tip': 'Keep your nails clean and trimmed to prevent infections.',
      'category': 'Hygiene',
      'source': 'Nail Care',
      'icon': '💅',
    },
    {
      'tip': 'Wash your hair regularly to maintain scalp health.',
      'category': 'Hygiene',
      'source': 'Hair Care',
      'icon': '🧴',
    },
    {
      'tip': 'Change your clothes daily to maintain personal hygiene.',
      'category': 'Hygiene',
      'source': 'Clothing Hygiene',
      'icon': '👕',
    },
    {
      'tip': 'Keep your living space clean to prevent illness and allergies.',
      'category': 'Hygiene',
      'source': 'Environmental Hygiene',
      'icon': '🏠',
    },
    {
      'tip': 'Use hand sanitizer when soap and water are not available.',
      'category': 'Hygiene',
      'source': 'Hand Hygiene',
      'icon': '🧴',
    },
    // Additional Eye Health tips
    {
      'tip': 'Follow the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.',
      'category': 'Eye Health',
      'source': 'Eye Care Guidelines',
      'icon': '👁️',
    },
    {
      'tip': 'Wear sunglasses to protect your eyes from UV radiation.',
      'category': 'Eye Health',
      'source': 'Eye Protection',
      'icon': '🕶️',
    },
    {
      'tip': 'Maintain proper lighting when reading or using screens.',
      'category': 'Eye Health',
      'source': 'Eye Ergonomics',
      'icon': '💡',
    },
    {
      'tip': 'Have regular eye exams to detect vision problems early.',
      'category': 'Eye Health',
      'source': 'Eye Care',
      'icon': '👓',
    },
    {
      'tip': 'Eat foods rich in vitamin A and omega-3s for eye health.',
      'category': 'Eye Health',
      'source': 'Eye Nutrition',
      'icon': '🥕',
    },
    {
      'tip': 'Avoid rubbing your eyes to prevent irritation and infection.',
      'category': 'Eye Health',
      'source': 'Eye Care',
      'icon': '🤚',
    },
    {
      'tip': 'Use artificial tears if your eyes feel dry from screen time.',
      'category': 'Eye Health',
      'source': 'Eye Care',
      'icon': '💧',
    },
    {
      'tip': 'Position your computer screen at arm\'s length and slightly below eye level.',
      'category': 'Eye Health',
      'source': 'Computer Ergonomics',
      'icon': '💻',
    },
    // Additional Posture tips
    {
      'tip': 'Sit with your back straight and shoulders relaxed.',
      'category': 'Posture',
      'source': 'Posture Guidelines',
      'icon': '🧍‍♀️',
    },
    {
      'tip': 'Keep your feet flat on the floor when sitting.',
      'category': 'Posture',
      'source': 'Sitting Posture',
      'icon': '🦶',
    },
    {
      'tip': 'Stand with your weight evenly distributed on both feet.',
      'category': 'Posture',
      'source': 'Standing Posture',
      'icon': '🧍‍♂️',
    },
    {
      'tip': 'Avoid slouching or hunching your shoulders.',
      'category': 'Posture',
      'source': 'Posture Correction',
      'icon': '🚫',
    },
    {
      'tip': 'Use ergonomic furniture to support good posture.',
      'category': 'Posture',
      'source': 'Ergonomics',
      'icon': '🪑',
    },
    {
      'tip': 'Take breaks to stretch and move around when sitting for long periods.',
      'category': 'Posture',
      'source': 'Movement Breaks',
      'icon': '🤸‍♀️',
    },
    {
      'tip': 'Practice exercises to strengthen your core and improve posture.',
      'category': 'Posture',
      'source': 'Core Strength',
      'icon': '💪',
    },
    {
      'tip': 'Be mindful of your posture throughout the day.',
      'category': 'Posture',
      'source': 'Posture Awareness',
      'icon': '🧠',
    },
    // Additional categories with multiple tips
    {
      'tip': 'Practice deep breathing exercises to improve lung capacity and reduce stress.',
      'category': 'Breathing',
      'source': 'Respiratory Health',
      'icon': '🫁',
    },
    {
      'tip': 'Try the 4-7-8 breathing technique for relaxation.',
      'category': 'Breathing',
      'source': 'Breathing Techniques',
      'icon': '🫁',
    },
    {
      'tip': 'Practice diaphragmatic breathing to strengthen your respiratory muscles.',
      'category': 'Breathing',
      'source': 'Breathing Exercises',
      'icon': '🫁',
    },
    {
      'tip': 'Use breathing exercises to manage anxiety and panic attacks.',
      'category': 'Breathing',
      'source': 'Anxiety Management',
      'icon': '🫁',
    },
    {
      'tip': 'Practice mindful breathing to stay present and focused.',
      'category': 'Breathing',
      'source': 'Mindfulness',
      'icon': '🫁',
    },
    {
      'tip': 'Build and maintain strong social connections for emotional support.',
      'category': 'Social Health',
      'source': 'Social Psychology',
      'icon': '👥',
    },
    {
      'tip': 'Practice active listening in your conversations.',
      'category': 'Social Health',
      'source': 'Communication Skills',
      'icon': '👂',
    },
    {
      'tip': 'Join clubs or groups that share your interests.',
      'category': 'Social Health',
      'source': 'Social Connection',
      'icon': '🤝',
    },
    {
      'tip': 'Volunteer in your community to build social connections.',
      'category': 'Social Health',
      'source': 'Community Service',
      'icon': '❤️',
    },
    {
      'tip': 'Practice empathy and understanding in your relationships.',
      'category': 'Social Health',
      'source': 'Emotional Intelligence',
      'icon': '💝',
    },
    {
      'tip': 'Limit alcohol consumption to moderate levels.',
      'category': 'Lifestyle',
      'source': 'Alcohol Guidelines',
      'icon': '🍷',
    },
    {
      'tip': 'Quit smoking to improve your overall health.',
      'category': 'Lifestyle',
      'source': 'Smoking Cessation',
      'icon': '🚭',
    },
    {
      'tip': 'Practice safe sex to protect your sexual health.',
      'category': 'Lifestyle',
      'source': 'Sexual Health',
      'icon': '💕',
    },
    {
      'tip': 'Wear sunscreen daily to protect your skin from UV damage.',
      'category': 'Lifestyle',
      'source': 'Skin Protection',
      'icon': '🧴',
    },
    {
      'tip': 'Practice safe driving habits to prevent accidents.',
      'category': 'Lifestyle',
      'source': 'Road Safety',
      'icon': '🚗',
    },
    {
      'tip': 'Get regular health check-ups and screenings.',
      'category': 'Preventive Care',
      'source': 'Preventive Medicine',
      'icon': '🏥',
    },
    {
      'tip': 'Keep up with recommended vaccinations.',
      'category': 'Preventive Care',
      'source': 'Immunization',
      'icon': '💉',
    },
    {
      'tip': 'Practice safe food handling to prevent foodborne illness.',
      'category': 'Preventive Care',
      'source': 'Food Safety',
      'icon': '🍽️',
    },
    {
      'tip': 'Learn basic first aid and CPR.',
      'category': 'Preventive Care',
      'source': 'First Aid',
      'icon': '🆘',
    },
    {
      'tip': 'Practice good dental hygiene to prevent cavities and gum disease.',
      'category': 'Dental Health',
      'source': 'Dental Care',
      'icon': '🦷',
    },
    {
      'tip': 'Visit your dentist regularly for cleanings and check-ups.',
      'category': 'Dental Health',
      'source': 'Dental Care',
      'icon': '👨‍⚕️',
    },
    {
      'tip': 'Use fluoride toothpaste to strengthen your teeth.',
      'category': 'Dental Health',
      'source': 'Dental Care',
      'icon': '🧴',
    },
    {
      'tip': 'Avoid sugary foods and drinks to prevent tooth decay.',
      'category': 'Dental Health',
      'source': 'Dental Care',
      'icon': '🍭',
    },
    {
      'tip': 'Take vitamin D supplements or get sunlight exposure.',
      'category': 'Vitamins',
      'source': 'Vitamin D Research',
      'icon': '☀️',
    },
    {
      'tip': 'Consider taking a multivitamin if you have dietary restrictions.',
      'category': 'Vitamins',
      'source': 'Nutrition Science',
      'icon': '💊',
    },
    {
      'tip': 'Get vitamin C from citrus fruits and vegetables.',
      'category': 'Vitamins',
      'source': 'Vitamin C Research',
      'icon': '🍊',
    },
    {
      'tip': 'Include B vitamins in your diet for energy and brain function.',
      'category': 'Vitamins',
      'source': 'B Vitamin Research',
      'icon': '🥜',
    },
    {
      'tip': 'Practice portion control to maintain a healthy weight.',
      'category': 'Weight Management',
      'source': 'Weight Management',
      'icon': '⚖️',
    },
    {
      'tip': 'Eat slowly and mindfully to prevent overeating.',
      'category': 'Weight Management',
      'source': 'Mindful Eating',
      'icon': '🍽️',
    },
    {
      'tip': 'Set realistic weight loss goals.',
      'category': 'Weight Management',
      'source': 'Weight Loss',
      'icon': '🎯',
    },
    {
      'tip': 'Combine diet and exercise for sustainable weight management.',
      'category': 'Weight Management',
      'source': 'Weight Management',
      'icon': '🏃‍♀️',
    },
    {
      'tip': 'Eat slowly and chew your food thoroughly.',
      'category': 'Eating Habits',
      'source': 'Digestive Health',
      'icon': '🍽️',
    },
    {
      'tip': 'Avoid eating while distracted by screens.',
      'category': 'Eating Habits',
      'source': 'Mindful Eating',
      'icon': '📱',
    },
    {
      'tip': 'Listen to your body\'s hunger and fullness cues.',
      'category': 'Eating Habits',
      'source': 'Intuitive Eating',
      'icon': '👂',
    },
    {
      'tip': 'Eat regular meals to maintain stable blood sugar.',
      'category': 'Eating Habits',
      'source': 'Blood Sugar Management',
      'icon': '⏰',
    },
    {
      'tip': 'Include probiotic foods in your diet.',
      'category': 'Gut Health',
      'source': 'Gut Health',
      'icon': '🦠',
    },
    {
      'tip': 'Eat fiber-rich foods to support digestive health.',
      'category': 'Gut Health',
      'source': 'Digestive Health',
      'icon': '🌾',
    },
    {
      'tip': 'Stay hydrated to support digestive function.',
      'category': 'Gut Health',
      'source': 'Digestive Health',
      'icon': '💧',
    },
    {
      'tip': 'Practice good ergonomics at your workstation.',
      'category': 'Workplace Health',
      'source': 'Workplace Health',
      'icon': '💼',
    },
    {
      'tip': 'Take regular breaks from sitting.',
      'category': 'Workplace Health',
      'source': 'Workplace Health',
      'icon': '🪑',
    },
    {
      'tip': 'Practice stress management techniques at work.',
      'category': 'Workplace Health',
      'source': 'Workplace Health',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Wear comfortable, supportive shoes.',
      'category': 'Foot Health',
      'source': 'Foot Health',
      'icon': '👟',
    },
    {
      'tip': 'Practice good foot hygiene.',
      'category': 'Foot Health',
      'source': 'Foot Health',
      'icon': '🦶',
    },
    {
      'tip': 'Stretch your feet and ankles regularly.',
      'category': 'Foot Health',
      'source': 'Foot Health',
      'icon': '🤸‍♀️',
    },
    {
      'tip': 'Take breaks from sitting every 30 minutes.',
      'category': 'Sedentary Behavior',
      'source': 'Sedentary Behavior',
      'icon': '🪑',
    },
    {
      'tip': 'Use a standing desk when possible.',
      'category': 'Sedentary Behavior',
      'source': 'Sedentary Behavior',
      'icon': '🖥️',
    },
    {
      'tip': 'Walk or bike instead of driving short distances.',
      'category': 'Sedentary Behavior',
      'source': 'Sedentary Behavior',
      'icon': '🚶‍♀️',
    },
    {
      'tip': 'Use sunscreen daily to protect your skin.',
      'category': 'Skin Health',
      'source': 'Skin Health',
      'icon': '🧴',
    },
    {
      'tip': 'Moisturize your skin regularly.',
      'category': 'Skin Health',
      'source': 'Skin Health',
      'icon': '🧴',
    },
    {
      'tip': 'Avoid excessive sun exposure.',
      'category': 'Skin Health',
      'source': 'Skin Health',
      'icon': '☀️',
    },
    {
      'tip': 'Eat calcium-rich foods for bone health.',
      'category': 'Bone Health',
      'source': 'Bone Health',
      'icon': '🥛',
    },
    {
      'tip': 'Include weight-bearing exercises in your routine.',
      'category': 'Bone Health',
      'source': 'Bone Health',
      'icon': '💪',
    },
    {
      'tip': 'Get adequate vitamin D for bone health.',
      'category': 'Bone Health',
      'source': 'Bone Health',
      'icon': '☀️',
    },
    {
      'tip': 'Avoid smoking to protect bone health.',
      'category': 'Bone Health',
      'source': 'Bone Health',
      'icon': '🚭',
    },
    {
      'tip': 'Limit alcohol consumption for bone health.',
      'category': 'Bone Health',
      'source': 'Bone Health',
      'icon': '🍷',
    },
    {
      'tip': 'Protect your hearing from loud noises.',
      'category': 'Hearing Health',
      'source': 'Hearing Health',
      'icon': '👂',
    },
    {
      'tip': 'Avoid inserting objects into your ears.',
      'category': 'Hearing Health',
      'source': 'Hearing Health',
      'icon': '🚫',
    },
    {
      'tip': 'Have regular hearing check-ups.',
      'category': 'Hearing Health',
      'source': 'Hearing Health',
      'icon': '👨‍⚕️',
    },
    {
      'tip': 'Avoid smoking to protect respiratory health.',
      'category': 'Respiratory Health',
      'source': 'Respiratory Health',
      'icon': '🚭',
    },
    {
      'tip': 'Practice deep breathing exercises.',
      'category': 'Respiratory Health',
      'source': 'Respiratory Health',
      'icon': '🫁',
    },
    {
      'tip': 'Maintain good indoor air quality.',
      'category': 'Respiratory Health',
      'source': 'Respiratory Health',
      'icon': '🏠',
    },
    {
      'tip': 'Eat a heart-healthy diet.',
      'category': 'Heart Health',
      'source': 'Heart Health',
      'icon': '❤️',
    },
    {
      'tip': 'Exercise regularly for heart health.',
      'category': 'Heart Health',
      'source': 'Heart Health',
      'icon': '🏃‍♀️',
    },
    {
      'tip': 'Manage stress for heart health.',
      'category': 'Heart Health',
      'source': 'Heart Health',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Have regular check-ups for reproductive health.',
      'category': 'Reproductive Health',
      'source': 'Reproductive Health',
      'icon': '👶',
    },
    {
      'tip': 'Practice safe sex.',
      'category': 'Reproductive Health',
      'source': 'Reproductive Health',
      'icon': '💕',
    },
    {
      'tip': 'Stay active as you age.',
      'category': 'Aging',
      'source': 'Aging',
      'icon': '👴',
    },
    {
      'tip': 'Maintain social connections as you age.',
      'category': 'Aging',
      'source': 'Aging',
      'icon': '👥',
    },
    {
      'tip': 'Keep your mind active with learning and puzzles.',
      'category': 'Aging',
      'source': 'Aging',
      'icon': '🧩',
    },
    {
      'tip': 'Reduce exposure to environmental pollutants.',
      'category': 'Environmental Health',
      'source': 'Environmental Health',
      'icon': '🌍',
    },
    {
      'tip': 'Use eco-friendly cleaning products.',
      'category': 'Environmental Health',
      'source': 'Environmental Health',
      'icon': '🧴',
    },
    {
      'tip': 'Follow workplace safety guidelines.',
      'category': 'Occupational Health',
      'source': 'Occupational Health',
      'icon': '🏭',
    },
    {
      'tip': 'Take regular breaks at work.',
      'category': 'Occupational Health',
      'source': 'Occupational Health',
      'icon': '☕',
    },
    {
      'tip': 'Stay hydrated during travel.',
      'category': 'Travel Health',
      'source': 'Travel Health',
      'icon': '✈️',
    },
    {
      'tip': 'Move around during long flights.',
      'category': 'Travel Health',
      'source': 'Travel Health',
      'icon': '🛩️',
    },
    {
      'tip': 'Adapt your routine to seasonal changes.',
      'category': 'Seasonal Health',
      'source': 'Seasonal Health',
      'icon': '🍂',
    },
    {
      'tip': 'Manage screen time for digital health.',
      'category': 'Digital Health',
      'source': 'Digital Health',
      'icon': '💻',
    },
    {
      'tip': 'Practice good posture while using devices.',
      'category': 'Digital Health',
      'source': 'Digital Health',
      'icon': '📱',
    },
    {
      'tip': 'Manage financial stress for financial health.',
      'category': 'Financial Health',
      'source': 'Financial Health',
      'icon': '💰',
    },
    {
      'tip': 'Seek financial advice when needed.',
      'category': 'Financial Health',
      'source': 'Financial Health',
      'icon': '💼',
    },
    {
      'tip': 'Engage in spiritual practices that bring meaning.',
      'category': 'Spiritual Health',
      'source': 'Spiritual Health',
      'icon': '🙏',
    },
    {
      'tip': 'Practice meditation or prayer.',
      'category': 'Spiritual Health',
      'source': 'Spiritual Health',
      'icon': '🧘‍♀️',
    },
    {
      'tip': 'Engage in lifelong learning for intellectual health.',
      'category': 'Intellectual Health',
      'source': 'Intellectual Health',
      'icon': '📚',
    },
    {
      'tip': 'Challenge your mind with puzzles and games.',
      'category': 'Intellectual Health',
      'source': 'Intellectual Health',
      'icon': '🧩',
    },
    {
      'tip': 'Express yourself creatively for creative health.',
      'category': 'Creative Health',
      'source': 'Creative Health',
      'icon': '🎨',
    },
    {
      'tip': 'Engage in artistic activities.',
      'category': 'Creative Health',
      'source': 'Creative Health',
      'icon': '🎭',
    },
    {
      'tip': 'Participate in community activities.',
      'category': 'Community Health',
      'source': 'Community Health',
      'icon': '🏘️',
    },
    {
      'tip': 'Support local health initiatives.',
      'category': 'Community Health',
      'source': 'Community Health',
      'icon': '❤️',
    },
    {
      'tip': 'Stay informed about global health issues.',
      'category': 'Global Health',
      'source': 'Global Health',
      'icon': '🌎',
    },
    {
      'tip': 'Support global health initiatives.',
      'category': 'Global Health',
      'source': 'Global Health',
      'icon': '🤝',
    },
  ];

  // Get a random health tip
  static Future<Map<String, dynamic>> getRandomTip() async {
    // Use local tips 100% of the time to avoid API errors
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