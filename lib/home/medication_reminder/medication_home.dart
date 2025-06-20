import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'add_medicine.dart';

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


  void _showAddMedicineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddMedicineForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: const Text('My Medicines',style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Soft cyan
              Color(0xFF00ACC1), // Calming teal
              Color(0xFF007C91), // Deep teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _medicines.isEmpty
              ? const Center(
            child: Text(
              'No medicines added yet.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              : ListView.builder(
            itemCount: _medicines.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final med = _medicines[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.medication, size: 40, color: Color(0xFF00ACC1)),
                  title: Text(
                    med['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007C91),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Quantity: ${med['quantity']}"),
                      Text("Days: ${med['days'].join(', ')}"),
                      Text("Time: ${med['time'] ?? 'Not set'}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteMedicine(med['key']);
                    },
                  ),
                ),

              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineSheet,
        backgroundColor: const Color(0xFF00ACC1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
