import 'package:flutter/material.dart';

class MythDetailScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> myths;

  const MythDetailScreen({
    super.key,
    required this.title,
    required this.myths,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor:  Color(0xFFB2EBF2),
        elevation: 0,
        title: Text(title,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
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
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          itemCount: myths.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final myth = myths[index];
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Myth ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      myth['myth'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Truth:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      myth['truth'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Chip(
                        avatar: Icon(
                          myth['status'] == 'Busted'
                              ? Icons.close
                              : Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          myth['status']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: myth['status'] == 'Busted'
                            ? Colors.redAccent
                            : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
