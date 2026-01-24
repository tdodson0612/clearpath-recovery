// lib/tools/thought_challenge_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ThoughtChallengePage extends StatefulWidget {
  const ThoughtChallengePage({super.key});

  @override
  State<ThoughtChallengePage> createState() => _ThoughtChallengePageState();
}

class _ThoughtChallengePageState extends State<ThoughtChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final _thoughtController = TextEditingController();
  final _evidenceForController = TextEditingController();
  final _evidenceAgainstController = TextEditingController();
  final _balancedController = TextEditingController();
  
  List<ThoughtWorksheet> _worksheets = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _balancedController.dispose();
    super.dispose();
  }

  Future<void> _loadWorksheets() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('thought_worksheets') ?? [];
    setState(() {
      _worksheets = history
          .map((json) => ThoughtWorksheet.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _saveWorksheet() async {
    if (!_formKey.currentState!.validate()) return;

    final worksheet = ThoughtWorksheet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      automaticThought: _thoughtController.text.trim(),
      evidenceFor: _evidenceForController.text.trim(),
      evidenceAgainst: _evidenceAgainstController.text.trim(),
      balancedThought: _balancedController.text.trim(),
      timestamp: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    _worksheets.insert(0, worksheet);
    
    if (_worksheets.length > 100) {
      _worksheets.removeLast();
    }

    final jsonList = _worksheets.map((w) => jsonEncode(w.toJson())).toList();
    await prefs.setStringList('thought_worksheets', jsonList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worksheet saved!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _clearForm();
      setState(() {});
    }
  }

  void _clearForm() {
    _thoughtController.clear();
    _evidenceForController.clear();
    _evidenceAgainstController.clear();
    _balancedController.clear();
  }

  Future<void> _deleteWorksheet(String id) async {
    setState(() {
      _worksheets.removeWhere((w) => w.id == id);
    });

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _worksheets.map((w) => jsonEncode(w.toJson())).toList();
    await prefs.setStringList('thought_worksheets', jsonList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worksheet deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thought Challenge',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showHistory ? Icons.edit : Icons.history,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body: _showHistory ? _buildHistory() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF4F46E5),
            child: Column(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Challenge Your Thoughts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Examine your thinking patterns with evidence',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildStep(
                    number: 1,
                    title: 'Identify the Automatic Thought',
                    hint: 'What thought popped into your head?',
                    example: 'Example: "I\'ll never stay sober"',
                    controller: _thoughtController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _buildStep(
                    number: 2,
                    title: 'Evidence FOR This Thought',
                    hint: 'What makes this thought seem true?',
                    example: 'Example: "I\'ve relapsed before"',
                    controller: _evidenceForController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  _buildStep(
                    number: 3,
                    title: 'Evidence AGAINST This Thought',
                    hint: 'What evidence contradicts this thought?',
                    example: 'Example: "I\'ve gone 30 days without using"',
                    controller: _evidenceAgainstController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  _buildStep(
                    number: 4,
                    title: 'Balanced Alternative Thought',
                    hint: 'What\'s a more realistic way to think about this?',
                    example: 'Example: "Recovery is hard, but I\'m making progress"',
                    controller: _balancedController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveWorksheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Worksheet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4F46E5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Clear Form',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDEDEFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This tool helps you examine automatic thoughts that can lead to relapse. Take your time with each step.',
              style: TextStyle(fontSize: 14, color: Color(0xFF3730A3), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String hint,
    required String example,
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please complete this step';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          example,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    if (_worksheets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No worksheets yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your first thought challenge to see it here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _worksheets.length,
      itemBuilder: (context, index) {
        final worksheet = _worksheets[index];
        return _buildWorksheetCard(worksheet);
      },
    );
  }

  Widget _buildWorksheetCard(ThoughtWorksheet worksheet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(worksheet.timestamp),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                  onPressed: () => _showDeleteDialog(worksheet.id),
                ),
              ],
            ),
            const Divider(),
            _buildHistoryField('Automatic Thought', worksheet.automaticThought, Colors.red),
            const SizedBox(height: 12),
            _buildHistoryField('Evidence For', worksheet.evidenceFor, Colors.orange),
            const SizedBox(height: 12),
            _buildHistoryField('Evidence Against', worksheet.evidenceAgainst, Colors.blue),
            const SizedBox(height: 12),
            _buildHistoryField('Balanced Thought', worksheet.balancedThought, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryField(String label, String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937), height: 1.5),
        ),
      ],
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Worksheet?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorksheet(id);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today at ${_formatTime(date)}';
    if (diff.inDays == 1) return 'Yesterday at ${_formatTime(date)}';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class ThoughtWorksheet {
  final String id;
  final String automaticThought;
  final String evidenceFor;
  final String evidenceAgainst;
  final String balancedThought;
  final DateTime timestamp;

  ThoughtWorksheet({
    required this.id,
    required this.automaticThought,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.balancedThought,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'automatic_thought': automaticThought,
    'evidence_for': evidenceFor,
    'evidence_against': evidenceAgainst,
    'balanced_thought': balancedThought,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ThoughtWorksheet.fromJson(Map<String, dynamic> json) => ThoughtWorksheet(
    id: json['id'],
    automaticThought: json['automatic_thought'],
    evidenceFor: json['evidence_for'],
    evidenceAgainst: json['evidence_against'],
    balancedThought: json['balanced_thought'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}