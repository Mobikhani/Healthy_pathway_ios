import 'package:flutter/material.dart';
import '../../services/unlimited_health_tips_service.dart';

class EnhancedHealthTipsScreen extends StatefulWidget {
  const EnhancedHealthTipsScreen({super.key});

  @override
  State<EnhancedHealthTipsScreen> createState() => _EnhancedHealthTipsScreenState();
}

class _EnhancedHealthTipsScreenState extends State<EnhancedHealthTipsScreen> {
  String currentTip = 'Tap the button to generate a health tip!';
  bool isLoading = false;
  String selectedCategory = 'General';

  @override
  void initState() {
    super.initState();
    _generateNewTip();
  }

  Future<void> _generateNewTip() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final newTip = await UnlimitedHealthTipsService.generateHealthTip(selectedCategory);
      if (mounted) {
        setState(() {
          currentTip = newTip;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentTip = 'Stay healthy and happy!';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Daily Health Tip',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        currentTip,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _generateNewTip,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Tip'),
            ),
          ],
        ),
      ),
    );
  }
} 