import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AskAIAboutMythsScreen extends StatefulWidget {
  const AskAIAboutMythsScreen({super.key});

  @override
  State<AskAIAboutMythsScreen> createState() => _AskAIAboutMythsScreenState();
}

class _AskAIAboutMythsScreenState extends State<AskAIAboutMythsScreen> {
  final TextEditingController _mythController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  final String _apiKey = 'AIzaSyAMSSFLg3KdYkyiYFIgQRHsoqduNE9JGmg'; // 👈 Replace with your Gemini API key

  Future<void> _askMythToAI(String myth) async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final prompt = "Is the following a myth or truth? Explain in 6–10 simple lines only. Avoid complex wording. Myth: \"$myth\"";

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
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
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response received.';
        setState(() {
          _result = text;
        });
      } else {
        setState(() {
          _result = 'Failed: ${response.statusCode} ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error fetching response: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ask AI About Myths", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2),
              Color(0xFF00ACC1),
              Color(0xFF007C91),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _mythController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter your myth, e.g. “Does sugar cause hyperactivity?”',
                      prefixIcon: const Icon(Icons.help_outline),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final query = _mythController.text.trim();
                          if (query.isNotEmpty) _askMythToAI(query);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Result / Loading / Placeholder
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _result.isEmpty
                      ? const Center(
                    child: Text(
                      'Type a myth above to ask AI.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
