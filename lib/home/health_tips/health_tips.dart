// lib/home/health_tips/health_tips_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
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

  String currentTip = "";

  @override
  void initState() {
    super.initState();
    getRandomTip();
  }

  void getRandomTip() {
    final random = Random();
    final index = random.nextInt(healthTips.length);
    setState(() {
      currentTip = healthTips[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title:  Text("Daily Health Tip",style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        backgroundColor: Color(0xFF00ACC1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Today's Tip:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    currentTip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: getRandomTip,
                icon: const Icon(Icons.refresh,color: Colors.white,),
                label: const Text("New Tip",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
