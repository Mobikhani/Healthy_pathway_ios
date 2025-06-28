import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'add_medicine.dart';
import 'notification_service.dart';
import '../../widgets/round_home_button.dart';

class MedicationHome extends StatefulWidget {
  const MedicationHome({super.key});

  @override
  State<MedicationHome> createState() => _MedicationHomeState();
}

class _MedicationHomeState extends State<MedicationHome> {
  List<Map<String, dynamic>> _medicines = [];
  DatabaseReference? _medRef;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _medRef = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(_currentUser!.uid)
          .child('medicines');
      _fetchMedicines();
    }
  }

  void _fetchMedicines() {
    _medRef?.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<Map<String, dynamic>> loaded = [];
        data.forEach((key, value) {
          final medMap = Map<String, dynamic>.from(value);
          medMap['key'] = key; // Store Firebase key
          loaded.add(medMap);
        });

        setState(() {
          _medicines = loaded;
        });
        
        // Reschedule notifications for all medicines
        _rescheduleNotifications(loaded);
      } else {
        setState(() {
          _medicines = [];
        });
      }
    });
  }
  
  void _rescheduleNotifications(List<Map<String, dynamic>> medicines) async {
    try {
      print('🔄 Rescheduling notifications for ${medicines.length} medicines...');
      await NotificationService.rescheduleAllNotifications(medicines);
    } catch (e) {
      print('❌ Error rescheduling notifications: $e');
    }
  }

  void _deleteMedicine(String key) async {
    if (_medRef != null) {
      await _medRef!.child(key).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted')),
      );
    }
  }

  void _checkPermissions() async {
    try {
      final permissions = await NotificationService.checkPermissions();
      final pendingNotifications = await NotificationService.getPendingNotifications();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification Permission: ${permissions['notification'] == true ? '✅ Granted' : '❌ Denied'}'),
              const SizedBox(height: 8),
              Text('Alarm Permission: ${permissions['alarm'] == true ? '✅ Granted' : '❌ Denied'}'),
              const SizedBox(height: 8),
              Text('Pending Notifications: ${pendingNotifications.length}'),
              if (pendingNotifications.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Scheduled notifications:'),
                ...pendingNotifications.take(3).map((n) => Text('• ${n.title} (ID: ${n.id})')),
                if (pendingNotifications.length > 3) 
                  Text('... and ${pendingNotifications.length - 3} more'),
              ],
              if (!permissions['notification']! || !permissions['alarm']!) ...[
                const SizedBox(height: 16),
                const Text(
                  'To fix notification issues:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Go to device Settings'),
                const Text('2. Find "Healthy Pathway" app'),
                const Text('3. Enable "Show notifications"'),
                const Text('4. Set battery optimization to "Don\'t optimize"'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await NotificationService.showSimpleTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent! Check if you received it.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Test Now'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await NotificationService.scheduleTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification scheduled for 30 seconds! Keep app in background.'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Test 30s'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await NotificationService.rescheduleAllNotifications(_medicines);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications rescheduled!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error rescheduling: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reschedule All'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking permissions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _checkPermissions,
            tooltip: 'Check Permissions',
          ),
        ],
      ),
      body: _medicines.isEmpty
          ? const Center(
              child: Text(
                'No medicines added yet.\nTap the + button to add your first medicine.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.medication, color: Colors.blue),
                    title: Text(medicine['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${medicine['quantity'] ?? 'N/A'}'),
                        Text('Time: ${medicine['time'] ?? 'N/A'}'),
                        Text('Days: ${(medicine['days'] as List<dynamic>?)?.join(', ') ?? 'N/A'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMedicine(medicine['key']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddMedicineForm(),
          );
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
