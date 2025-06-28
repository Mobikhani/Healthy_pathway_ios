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
      } else {
        setState(() {
          _medicines = [];
        });
      }
    });
  }
  
  void _deleteMedicine(String key) async {
    if (_medRef != null) {
      await _medRef!.child(key).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted')),
      );
    }
  }

  void _testNotification() async {
    try {
      await NotificationService.showTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending test notification: $e')),
      );
    }
  }

  void _scheduleTestNotification() async {
    try {
      await NotificationService.scheduleTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification scheduled for 10 seconds from now!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scheduleTestMedicineNotification() async {
    try {
      await NotificationService.scheduleTestMedicineNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test medicine notification scheduled for 2 minutes from now!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling test medicine notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMedicineNotificationNow() async {
    try {
      await NotificationService.showMedicineNotificationNow('Test Medicine');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine notification shown immediately!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error showing medicine notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPendingNotifications() async {
    try {
      final pendingNotifications = await NotificationService.getPendingNotifications();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pending Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pendingNotifications.length,
              itemBuilder: (context, index) {
                final notification = pendingNotifications[index];
                return ListTile(
                  title: Text('ID: ${notification.id}'),
                  subtitle: Text(notification.title ?? 'No title'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting pending notifications: $e')),
      );
    }
  }

  void _cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications cancelled!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkPermissions() async {
    try {
      final permissions = await NotificationService.checkPermissions();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Permissions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification Permission: ${permissions['notification'] == true ? 'Granted' : 'Denied'}'),
              const SizedBox(height: 8),
              Text('Alarm Permission: ${permissions['alarm'] == true ? 'Granted' : 'Denied'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await NotificationService.requestPermissions();
                Navigator.pop(context);
                _checkPermissions();
              },
              child: const Text('Request Permissions'),
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
      body: Column(
        children: [
          // Test buttons section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Tests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _testNotification,
                      child: const Text('Test Now'),
                    ),
                    ElevatedButton(
                      onPressed: _showMedicineNotificationNow,
                      child: const Text('Medicine Now'),
                    ),
                    ElevatedButton(
                      onPressed: _scheduleTestNotification,
                      child: const Text('Test 10s'),
                    ),
                    ElevatedButton(
                      onPressed: _scheduleTestMedicineNotification,
                      child: const Text('Test 2min'),
                    ),
                    ElevatedButton(
                      onPressed: _showPendingNotifications,
                      child: const Text('View Pending'),
                    ),
                    ElevatedButton(
                      onPressed: _cancelAllNotifications,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancel All', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Medicines list
          Expanded(
            child: _medicines.isEmpty
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
          ),
        ],
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
