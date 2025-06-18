import 'package:flutter/material.dart';
import 'myth_details.dart';

class MythHomeScreen extends StatelessWidget {
  const MythHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF437BD8);
    final backgroundColor = const Color(0xFFF0F6FF); // Light blue-grey

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.fastfood,
        'title': 'Nutrition Myths',
        'description': 'Common nutrition misconceptions',
        'data': [
          {
            'myth': 'Carbs make you fat',
            'truth': 'Excess calories — not carbs specifically — lead to weight gain.',
            'status': 'Busted'
          },
          {
            'myth': 'Probiotics support gut health',
            'truth': 'Certain strains (e.g., in yogurt) can improve microbiome balance.',
            'status': 'True'
          },
          {
            'myth': 'Drinking water before meals helps weight loss',
            'truth': 'It may slightly reduce calorie intake, but the effect is minimal.',
            'status': 'Busted'
          },
          {
            'myth': 'All processed foods are unhealthy',
            'truth': 'Some processing is essential and can preserve nutrients.',
            'status': 'Busted'
          },
          {
            'myth': 'Eating slowly helps digestion',
            'truth': 'Chewing thoroughly aids nutrient absorption and prevents overeating.',
            'status': 'True'
          },


          {
            'myth': 'Vitamin C prevents the common cold',
            'truth': 'It may reduce severity slightly, but does not prevent colds.',
            'status': 'Busted'
          },
          {
            'myth': 'Eggs raise cholesterol levels dangerously',
            'truth': 'Moderate egg consumption is safe for most people.',
            'status': 'Busted'
          },
          {
            'myth': 'Frozen fruits and vegetables are less nutritious',
            'truth': 'They retain most nutrients and are a healthy option.',
            'status': 'Busted'
          },
          {
            'myth': 'You must eat breakfast to be healthy',
            'truth': 'While beneficial for some, it’s not mandatory for everyone.',
            'status': 'Busted'
          },
          {
            'myth': 'Omega-3s are good for heart health',
            'truth': 'Fatty fish and flaxseeds reduce inflammation and lower heart disease risk.',
            'status': 'True'
          },
          {
            'myth': 'High-protein diets damage your kidneys',
            'truth': 'Only a concern for people with existing kidney disease.',
            'status': 'Busted'
          },
          {
            'myth': 'Natural sugars like honey are better than white sugar',
            'truth': 'They’re still sugars and should be consumed in moderation.',
            'status': 'Busted'
          },
          {
            'myth': 'Drinking green tea boosts metabolism',
            'truth': 'The effect is too small to significantly impact weight loss.',
            'status': 'Busted'
          },
        ],
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Exercise Myths',
        'description': 'Debunk workout misconceptions',
        'data': [
          {
            'myth': 'No pain, no gain',
            'truth': 'Pain is a sign of injury; discomfort is okay, pain is not.',
            'status': 'Busted'
          },
          {
            'myth': 'Stretching improves flexibility',
            'truth': 'Yes, but dynamic stretching is more effective than static.',
            'status': 'True'
          },
          {
            'myth': 'Cardio is the best way to lose fat',
            'truth': 'Strength training and diet are equally important.',
            'status': 'Busted'
          },
          {
            'myth': 'Exercise alone can help you lose weight',
            'truth': 'Diet is far more critical for weight loss.',
            'status': 'Busted'
          },
          {
            'myth': 'Walking is effective for weight maintenance',
            'truth': '10,000 steps/day correlates with lower BMI and better cardiovascular health.',
            'status': 'True'
          },
          {
            'myth': 'You can turn fat into muscle',
            'truth': 'Fat and muscle are different tissues; they don’t convert.',
            'status': 'Busted'
          },
          {
            'myth': 'Strength training boosts metabolism',
            'truth': 'Muscle burns more calories at rest than fat, increasing metabolic rate.',
            'status': 'True'
          },
          {
            'myth': 'Weight training stunts growth in teens',
            'truth': 'Supervised training is safe and promotes strength.',
            'status': 'Busted'
          },
          {
            'myth': 'Working out makes you eat more',
            'truth': 'Exercise often regulates appetite, not always increasing it.',
            'status': 'Busted'
          },
          {
            'myth': 'You must exercise daily to stay fit',
            'truth': 'Rest days are vital for recovery and muscle growth.',
            'status': 'Busted'
          },
          {
            'myth': 'Stretching prevents injuries',
            'truth': 'Dynamic stretching before workouts reduces injury risk by improving mobility.',
            'status': 'True'
          },
          {
            'myth': 'Crunches are best for abs',
            'truth': 'Compound movements (e.g., planks) are more effective.',
            'status': 'Busted'
          },
          {
            'myth': 'You burn more fat exercising on an empty stomach',
            'truth': 'The difference is negligible; consistency matters more.',
            'status': 'Busted'
          },
        ],
      },
      {
        'icon': Icons.bedtime,
        'title': 'Sleep Myths',
        'description': 'Truths about rest and recovery',
        'data': [
          {
            'myth': 'You can catch up on sleep during weekends',
            'truth': 'Chronic sleep debt can’t be repaid in two nights.',
            'status': 'Busted'
          },
          {
            'myth': 'Everyone needs 8 hours of sleep',
            'truth': 'Sleep needs vary (typically 7-9 hours for adults).',
            'status': 'Busted'
          },
          {
            'myth': 'Snoring is harmless',
            'truth': 'It can indicate sleep apnea, a serious condition.',
            'status': 'Busted'
          },
          {
            'myth': 'Blue light before bed disrupts sleep',
            'truth': 'Screens emit light that delays melatonin production, worsening sleep onset.',
            'status': 'True'
          },

          {
            'myth': 'Alcohol helps you sleep better',
            'truth': 'It disrupts REM sleep and reduces sleep quality.',
            'status': 'Busted'
          },
          {
            'myth': 'Watching TV helps you fall asleep',
            'truth': 'Blue light suppresses melatonin, delaying sleep.',
            'status': 'Busted'
          },
          {
            'myth': 'Napping during the day ruins nighttime sleep',
            'truth': 'Short naps (<20 mins) don’t affect nighttime sleep.',
            'status': 'Busted'
          },
          {
            'myth': 'Older adults need less sleep',
            'truth': 'They need the same amount but often sleep less deeply.',
            'status': 'Busted'
          },
          {
            'myth': 'Consistent sleep schedules improve energy',
            'truth': 'Going to bed/waking at the same time stabilizes circadian rhythms.',
            'status': 'True'
          },
          {
            'myth': 'Sleeping in on weekends fixes weekday sleep loss',
            'truth': 'It disrupts circadian rhythm and isn’t a true fix.',
            'status': 'Busted'
          },
          {
            'myth': 'Lying in bed awake is better than getting up',
            'truth': 'If awake >20 mins, get up to avoid associating bed with wakefulness.',
            'status': 'Busted'
          },
          {
            'myth': 'You can train yourself to need less sleep',
            'truth': 'Chronic sleep deprivation harms health long-term.',
            'status': 'Busted'
          },
        ],
      },
      {
        'icon': Icons.psychology,
        'title': 'Mental Health Myths',
        'description': 'What’s true and what’s not',
        'data': [
          {
            'myth': 'Mental health problems are rare',
            'truth': '1 in 5 people experience mental health issues annually.',
            'status': 'Busted'
          },
          {
            'myth': 'People with mental illness are violent',
            'truth': 'They’re more likely to be victims than perpetrators.',
            'status': 'Busted'
          },
          {
            'myth': 'Social media harms teen mental health',
            'truth': 'Excessive use correlates with higher anxiety and depression rates.',
            'status': 'True'
          },
          {
            'myth': 'You can just "snap out" of depression',
            'truth': 'Depression is a medical condition requiring treatment.',
            'status': 'Busted'
          },
          {
            'myth': 'Therapy is only for people with serious issues',
            'truth': 'Therapy benefits everyone, even for general well-being.',
            'status': 'Busted'
          },
          {
            'myth': 'Kids can’t have mental health issues',
            'truth': 'Children can experience anxiety, depression, and more.',
            'status': 'Busted'
          },
          {
            'myth': 'Mindfulness reduces stress',
            'truth': 'Studies show meditation lowers cortisol and improves emotional regulation.',
            'status': 'True'
          },
          {
            'myth': 'Mental illness is caused by personal weakness',
            'truth': 'It’s influenced by biology, environment, and genetics.',
            'status': 'Busted'
          },
          {
            'myth': 'Medication is the only treatment for mental illness',
            'truth': 'Therapy, lifestyle changes, and support are also key.',
            'status': 'Busted'
          },
          {
            'myth': 'People with mental illness can’t hold jobs',
            'truth': 'Many thrive in workplaces with proper support.',
            'status': 'Busted'
          },
          {
            'myth': 'Talking about suicide increases the risk',
            'truth': 'Open dialogue reduces stigma and encourages help-seeking.',
            'status': 'Busted'
          },
          {
            'myth': 'Mental health conditions are lifelong',
            'truth': 'Many recover fully or manage symptoms effectively.',
            'status': 'Busted'
          },
        ],
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Check Myths",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Soft cyan
              Color(0xFF00ACC1), // Calming teal
              Color(0xFF007C91), // Deep blue-teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0, left: 16, right: 16, bottom: 16),
          child: ListView.separated(
            itemCount: features.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white.withOpacity(0.9),
                child: ListTile(
                  leading: Icon(feature['icon'], color: Colors.blueGrey),
                  title: Text(feature['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(feature['description']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MythDetailScreen(
                      title: feature['title'],
                      myths: List<Map<String, dynamic>>.from(feature['data'])
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
