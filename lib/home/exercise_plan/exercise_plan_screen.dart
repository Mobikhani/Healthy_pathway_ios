import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'exercise_time_screen.dart';

class ExercisePlanScreen extends StatefulWidget {
  @override
  _ExercisePlanScreenState createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  final List<Map<String, dynamic>> exercises = [
    {'name': 'Running', 'icon': Icons.directions_run},
    {'name': 'Stretching', 'icon': Icons.self_improvement},
    {'name': 'Push-ups', 'icon': Icons.fitness_center},
    {'name': 'Planking', 'icon': Icons.accessibility_new},
    {'name': 'Jumping Jacks', 'icon': Icons.sports_kabaddi},
    {'name': 'Squats', 'icon': Icons.accessibility},
  ];

  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;
  Map<String, List<Map>> historyByExercise = {};
  int totalCalories = 0;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userRef = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user!.uid)
          .child('exerciseLogs');
      fetchHistory();
    }
  }

  Future<void> fetchHistory() async {
    final snapshot = await userRef.get();
    final data = <String, List<Map>>{};
    int caloriesSum = 0;

    // Get today's date key in format 'yyyy-MM-dd'
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    if (snapshot.exists) {
      for (var dateSnap in snapshot.children) {
        if (dateSnap.key != todayKey) continue; // ✅ Only today's logs

        for (var entry in dateSnap.children) {
          final val = Map<String, dynamic>.from(entry.value as Map);
          final exercise = val['exercise'] ?? '';
          final calories = (val['calories_burned'] ?? 0) as num;

          caloriesSum += calories.toInt();

          data.putIfAbsent(exercise, () => []).add({
            'date': dateSnap.key,
            'duration': (val['duration_minutes'] ?? 0).toInt(),
            'duration_seconds': (val['duration_seconds'] ?? 0).toInt(),
            'calories': calories.toInt(),
            'timestamp': val['timestamp'],
          });
        }
      }
    }

    setState(() {
      historyByExercise = data;
      totalCalories = caloriesSum;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('🏋️ Exercise Plan', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF00ACC1),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTotalCalories(),
            _buildExerciseGrid(),
            _buildExerciseHistoryCards(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCalories() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB2EBF2), // Soft cyan
            Color(0xFF00ACC1), // Calming teal
            Color(0xFF007C91), // Deep teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Calories Burnt',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                '$totalCalories kcal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: exercises.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final ex = exercises[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseTimerScreen(
                    exerciseName: ex['name'],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB2EBF2), // Soft cyan
                    Color(0xFF00ACC1), // Calming teal
                    Color(0xFF007C91), // Deep teal
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ex['icon'], color: Colors.white, size: 34),
                  SizedBox(height: 8),
                  Text(
                    ex['name'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseHistoryCards() {
    return Column(
      children: exercises.map((exercise) {
        final name = exercise['name'];
        final historyList = historyByExercise[name] ?? [];

        int caloriesSum = historyList.fold(0, (sum, item) {
          final calories = item['calories'] ?? 0;
          return sum + (calories as num).toInt();
        });


        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(exercise['icon'], color: Colors.blueGrey, size: 28),
                  SizedBox(width: 10),
                  Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('$caloriesSum kcal', style: TextStyle(color: Colors.deepPurple)),
                ],
              ),
              if (historyList.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('No history yet.', style: TextStyle(color: Colors.grey[600])),
                )
              else
                Column(
                  children: historyList.map((entry) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today, color: Colors.grey[600]),
                      title: Text('${entry['duration']} min + ${entry['duration_seconds']} sec'),
                      subtitle: Text('Date: ${entry['date']}'),
                      trailing: Text('${entry['calories']} kcal'),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
