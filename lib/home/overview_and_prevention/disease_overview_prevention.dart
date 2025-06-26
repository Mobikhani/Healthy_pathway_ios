import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/round_home_button.dart';

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
        ? "Provide 8-10 prevention tips for $disease. Format as simple bullet points without asterisks or special characters. Each tip should be clear and actionable."
        : "Provide 8-10 treatment options for $disease. Format as simple bullet points without asterisks or special characters. Each treatment should be clear and informative.";

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
        String text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response received.';
        
        // Clean and format the text
        text = _formatResponseText(text);
        
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

  String _formatResponseText(String text) {
    // Remove asterisks and other markdown symbols
    text = text.replaceAll('*', '');
    text = text.replaceAll('#', '');
    text = text.replaceAll('-', '');
    text = text.replaceAll('•', '');
    
    // Split into lines and clean each line
    List<String> lines = text.split('\n');
    List<String> cleanedLines = [];
    
    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty) {
        // Remove any remaining bullet point indicators
        line = line.replaceAll(RegExp(r'^\d+\.\s*'), '');
        line = line.replaceAll(RegExp(r'^[-•*]\s*'), '');
        line = line.replaceAll(RegExp(r'^\s*[-•*]\s*'), '');
        
        // Add bullet point
        if (line.isNotEmpty) {
          cleanedLines.add('• $line');
        }
      }
    }
    
    return cleanedLines.join('\n\n');
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
      body: Stack(
        children: [
          Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedTab == 'Prevention' ? 'Prevention Tips:' : 'Treatment Options:',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007C91),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _result,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.8,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildDiseaseContent(),
          const RoundHomeButton(),
        ],
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

  Widget _buildDiseaseContent() {
    // Implementation of _buildDiseaseContent method
    // This method should return a Widget representing the disease content
    return Container(); // Placeholder return, actual implementation needed
  }
}
