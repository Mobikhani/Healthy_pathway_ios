import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/round_home_button.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final TextEditingController _inputController = TextEditingController();
  int _totalCalories = 0;
  int _dailyTarget = 2000;
  String _status = '';
  bool _isLoading = false;

  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;

  List<Map<String, dynamic>> _entries = [];
  Map<String, String> _entryKeys = {};

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('Users').child(user!.uid);
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      if (data['calorieTarget'] != null) {
        _dailyTarget = data['calorieTarget'];
      }

      final dailyData = data['dailyCalories']?[today];
      if (dailyData != null) {
        final dailyCalories = dailyData['total'];
        final entries = dailyData['entries'] as Map<dynamic, dynamic>?;

        if (entries != null) {
          _entries = [];
          _entryKeys = {};
          entries.forEach((key, value) {
            _entries.add({
              'item': value['item'],
              'calories': value['calories'],
            });
            _entryKeys[value['item'] + value['calories'].toString()] = key;
          });
        }

        setState(() {
          _totalCalories = dailyCalories;
        });
      }
    }
  }

  Future<void> _addCaloriesFromGemini(String input) async {
    setState(() {
      _status = '';
      _isLoading = true;
    });

    final apiKey = 'AIzaSyAMSSFLg3KdYkyiYFIgQRHsoqduNE9JGmg';
    final prompt = "Estimate the number of calories in: $input. Respond only with a number.";

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final estimatedCalories = int.tryParse(RegExp(r'\d+').stringMatch(text) ?? '0') ?? 0;

        _totalCalories += estimatedCalories;

        final calorieRef = userRef.child('dailyCalories').child(today);
        await calorieRef.child('entries').push().set({
          'item': input,
          'calories': estimatedCalories,
        });
        await calorieRef.update({'total': _totalCalories});

        setState(() {
          _status = '✅ Added $estimatedCalories kcal for "$input"';
        });

        await _fetchUserData();
      } else {
        setState(() {
          _status = '❌ Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntry(int index) async {
    final entry = _entries[index];
    final key = _entryKeys[entry['item'] + entry['calories'].toString()];

    if (key != null) {
      await userRef
          .child('dailyCalories')
          .child(today)
          .child('entries')
          .child(key)
          .remove();

      _totalCalories -= (entry['calories'] as num).toInt();

      await userRef
          .child('dailyCalories')
          .child(today)
          .update({'total': _totalCalories});

      await _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    int remaining = _dailyTarget - _totalCalories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calories Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00ACC1),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input + Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _inputController,
                            decoration: const InputDecoration(
                              labelText: 'Enter food or dish',
                              prefixIcon: Icon(Icons.fastfood),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                final input = _inputController.text.trim();
                                if (input.isNotEmpty) {
                                  _addCaloriesFromGemini(input);
                                  _inputController.clear();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Estimate & Add"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00ACC1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Center(
                        child: Text(
                          _status,
                          style: TextStyle(
                            fontSize: 16,
                            color: _status.startsWith('✅')
                                ? Colors.green[900]
                                : _status.startsWith('❌')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Summary Card
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📊 Today's Summary",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                              title: const Text("Total Calories"),
                              trailing: Text(
                                '$_totalCalories kcal',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.flag, color: Colors.blue),
                              title: const Text("Daily Target"),
                              trailing: Text(
                                '$_dailyTarget kcal',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.av_timer, color: Colors.teal),
                              title: const Text("Remaining"),
                              trailing: Text(
                                '${remaining > 0 ? remaining : 0} kcal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: remaining < 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Added Items
                    if (_entries.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        "🍽️ Added Items",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            child: ListTile(
                              title: Text(entry['item']),
                              subtitle: Text('${entry['calories']} kcal'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteEntry(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const RoundHomeButton(),
        ],
      ),
    );
  }
}
