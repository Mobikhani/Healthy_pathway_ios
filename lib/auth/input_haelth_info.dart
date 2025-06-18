import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:healthy_pathway/home/home_screen.dart';

class InputHealthInfo extends StatefulWidget {
  const InputHealthInfo({super.key});

  @override
  State<InputHealthInfo> createState() => _InputHealthInfoState();
}

class _InputHealthInfoState extends State<InputHealthInfo> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final diseaseController = TextEditingController();
  final allergyController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyContactController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedBloodGroup;
  String? selectedRelationship;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> relationships = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    diseaseController.dispose();
    allergyController.dispose();
    emergencyNameController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: inputDecoration(label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: inputDecoration(hint),
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                )),
            const SizedBox(height: 16),
            ...children
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Health Info", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  sectionCard(title: "Personal Details", children: [
                    buildTextField(label: 'Full Name', controller: nameController),
                    const SizedBox(height: 16),
                    buildDropdown(
                      hint: 'Gender',
                      items: genders,
                      value: selectedGender,
                      onChanged: (value) => setState(() => selectedGender = value),
                    ),
                    const SizedBox(height: 16),
                    buildDropdown(
                      hint: 'Blood Group',
                      items: bloodGroups,
                      value: selectedBloodGroup,
                      onChanged: (value) => setState(() => selectedBloodGroup = value),
                    ),
                    const SizedBox(height: 16),
                    buildDropdown(
                      hint: 'Relationship Status',
                      items: relationships,
                      value: selectedRelationship,
                      onChanged: (value) => setState(() => selectedRelationship = value),
                    ),
                  ]),
                  sectionCard(title: "Physical Stats", children: [
                    buildTextField(
                      label: 'Height (cm)',
                      controller: heightController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      label: 'Weight (kg)',
                      controller: weightController,
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                  sectionCard(title: "Medical Info", children: [
                    buildTextField(label: 'Known Diseases', controller: diseaseController),
                    const SizedBox(height: 16),
                    buildTextField(label: 'Allergies', controller: allergyController),
                  ]),
                  sectionCard(title: "Emergency Contact", children: [
                    buildTextField(label: 'Contact Name', controller: emergencyNameController),
                    const SizedBox(height: 16),
                    buildTextField(
                      label: 'Contact Number',
                      controller: emergencyContactController,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedGender != null &&
                          selectedBloodGroup != null &&
                          selectedRelationship != null) {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User not logged in')),
                            );
                            return;
                          }

                          final Map<String, dynamic> healthInfo = {
                            'fullName': nameController.text.trim(),
                            'gender': selectedGender,
                            'bloodGroup': selectedBloodGroup,
                            'relationshipStatus': selectedRelationship,
                            'height': heightController.text.trim(),
                            'weight': weightController.text.trim(),
                            'knownDiseases': diseaseController.text.trim(),
                            'allergies': allergyController.text.trim(),
                            'emergencyContactName': emergencyNameController.text.trim(),
                            'emergencyContactNumber': emergencyContactController.text.trim(),
                          };

                          final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users/${user.uid}/healthInfo");
                          await dbRef.set(healthInfo);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Information Saved')),
                          );
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all required fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00ACC1),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save Information',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
