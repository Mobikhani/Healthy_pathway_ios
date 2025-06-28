import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';

class AddMedicineForm extends StatefulWidget {
  const AddMedicineForm({super.key});

  @override
  State<AddMedicineForm> createState() => _AddMedicineFormState();
}

class _AddMedicineFormState extends State<AddMedicineForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> _selectedDays = [];
  TimeOfDay? _selectedTime;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDays.isNotEmpty &&
        _selectedTime != null) {
      if (_currentUser == null) return;

      try {
        final medicine = {
          'name': _nameController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'days': _selectedDays,
          'time': _selectedTime!.format(context),
        };

        final ref = FirebaseDatabase.instance
            .ref()
            .child('Users')
            .child(_currentUser!.uid)
            .child('medicines');

        // Schedule notifications first
        print('Scheduling notifications for medicine: ${_nameController.text.trim()}');
        await NotificationService.scheduleMedicineNotification(
          id: '${_nameController.text.trim()}-${_selectedTime.toString()}'.hashCode & 0x7FFFFFFF,
          title: 'Time to take ${_nameController.text.trim()}',
          body: 'Don\'t forget to take your medicine!',
          time: _selectedTime!,
          days: _selectedDays,
        );

        // Save to database
        await ref.push().set(medicine);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicine "${_nameController.text.trim()}" added successfully with notifications!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        print('Error adding medicine: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medicine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields, select days, and time.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: mq.viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Add Medicine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Medicine Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _days.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'No time selected'
                            : 'Time: ${_selectedTime!.format(context)}',
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: const Text("Pick Time"),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check,color: Colors.white,),
                    label: const Text('Add Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
