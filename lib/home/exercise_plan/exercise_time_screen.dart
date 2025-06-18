import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ExerciseTimerScreen extends StatefulWidget {
  final String exerciseName;

  ExerciseTimerScreen({required this.exerciseName});

  @override
  _ExerciseTimerScreenState createState() => _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('Users').child(user!.uid);
    }
  }

  void _startOrPauseTimer() {
    if (!_isRunning && !_isPaused) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    } else if (_isRunning && !_isPaused) {
      _timer?.cancel();
      setState(() {
        _isPaused = true;
        _isRunning = false;
      });
    } else if (_isPaused) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    int totalSeconds = _seconds;
    if (totalSeconds < 5) {
      _showMessage("Too short to log. Minimum 5 seconds required.");
      return;
    }

    double minutes = totalSeconds / 60.0;
    int minutesInt = totalSeconds ~/ 60;
    int secondsInt = totalSeconds % 60;

    int calories = await _estimateCalories(widget.exerciseName, minutes);

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final ref = userRef.child('exerciseLogs').child(formattedDate).push();

    await ref.set({
      'exercise': widget.exerciseName,
      'duration_minutes': minutesInt,
      'duration_seconds': secondsInt,
      'total_seconds': totalSeconds,
      'calories_burned': calories,
      'timestamp': now.toIso8601String(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Exercise Completed'),
        content: Text(
          'You exercised for ${_formatTime(totalSeconds)}.\nEstimated Calories Burned: $calories kcal',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  Future<int> _estimateCalories(String name, double minutes) async {
    const apiKey = 'AIzaSyAMSSFLg3KdYkyiYFIgQRHsoqduNE9JGmg';
    final prompt =
        "Estimate the calories burned by doing $name for ${minutes.toStringAsFixed(1)} minutes. Respond only with a number.";

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
        ),
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
        final match = RegExp(r'\d+').firstMatch(text);
        return int.tryParse(match?.group(0) ?? '0') ?? 0;
      }
    } catch (e) {
      print('Gemini API Error: $e');
    }
    return 0;
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _getExerciseIcon(String name) {
    final icons = {
      'Running': Icons.directions_run,
      'Stretching': Icons.self_improvement,
      'Push-ups': Icons.fitness_center,
      'Planking': Icons.accessibility_new,
      'Jumping Jacks':Icons.sports_kabaddi,
      'Squats': Icons.accessibility,
    };
    return Icon(icons[name] ?? Icons.sports, size: 80, color: Color(0xFF00ACC1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _formatTime(_seconds);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(widget.exerciseName,style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00ACC1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getExerciseIcon(widget.exerciseName),
            SizedBox(height: 20),
            Text(
              elapsed,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00ACC1),
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  _isPaused ? "Resume" : (_isRunning ? "Pause" : "Start"),
                  _startOrPauseTimer,
                  _isRunning || _isPaused ? Colors.orange : Colors.green,
                ),
                _buildControlButton("Stop", _stopTimer, Colors.red),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _resetTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.refresh, color: Colors.black87),
              label: Text(
                'Reset',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
