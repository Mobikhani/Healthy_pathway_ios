import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiseaseOverviewPrevention extends StatefulWidget {
  const DiseaseOverviewPrevention({super.key});

  @override
  State<DiseaseOverviewPrevention> createState() => _DiseaseOverviewPreventionState();
}

class _DiseaseOverviewPreventionState extends State<DiseaseOverviewPrevention> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Prevention';
  String _result = '';
  bool _isLoading = false;

  final String _apiKey = 'AIzaSyAMSSFLg3KdYkyiYFIgQRHsoqduNE9JGmg'; // Replace with your valid key

  Future<void> _fetchData(String disease, String type) async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final prompt = type == 'Prevention'
        ? "In 8-10 short lines, briefly list the prevention tips for the disease: $disease."
        : "In 8-10 short lines, briefly list the treatment options for the disease: $disease.";

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
        _result = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabChange(String tab) {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _selectedTab = tab;
      });
      _fetchData(_searchController.text.trim(), tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: const Text('Disease Info', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
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
              Color(0xFF007C91), // Deep blue-teal
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
                // Search Field
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search disease...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _fetchData(_searchController.text.trim(), _selectedTab);
                          }
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

                // Tab buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton('Prevention'),
                    const SizedBox(width: 12),
                    _buildTabButton('Treatment'),
                  ],
                ),
                const SizedBox(height: 20),

                // Result or Loader
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _result.isEmpty
                      ? const Center(
                    child: Text(
                      'Search a disease to get information.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
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

  Widget _buildTabButton(String label) {
    final isSelected = _selectedTab == label;
    return ElevatedButton(
      onPressed: () => _onTabChange(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        foregroundColor: isSelected ? Colors.blueAccent : Colors.white,
        elevation: isSelected ? 6 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
