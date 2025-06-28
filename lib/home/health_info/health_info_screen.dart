import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widgets/round_home_button.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  final Color primaryColor = const Color(0xFF6A1B9A); // A deeper purple
  bool _isLoading = true;
  bool _isEditing = false;

  final Map<String, TextEditingController> controllers = {};
  Map<String, dynamic> healthData = {};

  @override
  void initState() {
    super.initState();
    fetchUserHealthInfo();
  }

  Future<void> fetchUserHealthInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .child('healthInfo');

      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          controllers[key] = TextEditingController(text: value.toString());
        });

        setState(() {
          healthData = data;
          _isLoading = false;
        });
      } else {
        throw Exception("No health info found");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> saveUpdatedData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final Map<String, String> updatedData = {};
      controllers.forEach((key, controller) {
        updatedData[key] = controller.text.trim();
      });

      final DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .child('healthInfo');

      await ref.set(updatedData);

      setState(() {
        _isEditing = false;
        healthData = updatedData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Information updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  Widget buildField(String label, String key) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.blueGrey),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: _isEditing
            ? TextFormField(
          controller: controllers[key],
          decoration: const InputDecoration(border: InputBorder.none),
          style: const TextStyle(color: Colors.black),
        )
            : Text(
          healthData[key] ?? '',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
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
        backgroundColor: Colors.transparent,
        title: const Text('Health Information', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                if (_isEditing) {
                  saveUpdatedData();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  healthData.forEach((key, value) {
                    controllers[key]?.text = value.toString();
                  });
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
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
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              child: ListView(
                children: [
                  const Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  buildField("Full Name", "fullName"),
                  buildField("Gender", "gender"),
                  buildField("Relationship Status", "relationshipStatus"),
                  const SizedBox(height: 20),
                  const Text(
                    "Physical Attributes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  buildField("Height", "height"),
                  buildField("Weight", "weight"),
                  buildField("Blood Group", "bloodGroup"),
                  const SizedBox(height: 20),
                  const Text(
                    "Medical Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  buildField("Known Diseases", "knownDiseases"),
                  buildField("Allergies", "allergies"),
                  const SizedBox(height: 20),
                  const Text(
                    "Emergency Contact",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  buildField("Emergency Contact Name", "emergencyContactName"),
                  buildField("Emergency Contact Number", "emergencyContactNumber"),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const RoundHomeButton(),
        ],
      ),
    );
  }
}
