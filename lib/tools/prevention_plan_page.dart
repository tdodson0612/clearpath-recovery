import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PreventionPlanPage extends StatefulWidget {
  const PreventionPlanPage({super.key});

  @override
  State<PreventionPlanPage> createState() => _PreventionPlanPageState();
}

class _PreventionPlanPageState extends State<PreventionPlanPage> {
  final _triggers = <String>[];
  final _warningSigns = <String>[];
  final _copingStrategies = <String>[];
  final _emergencyContacts = <EmergencyContact>[];
  final _supportNetwork = <String>[];

  final _triggerController = TextEditingController();
  final _warningController = TextEditingController();
  final _copingController = TextEditingController();
  final _supportController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _warningController.dispose();
    _copingController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planJson = prefs.getString('prevention_plan');
    
    if (planJson != null) {
      final plan = jsonDecode(planJson) as Map<String, dynamic>;
      setState(() {
        _triggers.addAll((plan['triggers'] as List).cast<String>());
        _warningSigns.addAll((plan['warning_signs'] as List).cast<String>());
        _copingStrategies.addAll((plan['coping_strategies'] as List).cast<String>());
        _supportNetwork.addAll((plan['support_network'] as List).cast<String>());
        _emergencyContacts.addAll(
          (plan['emergency_contacts'] as List)
              .map((e) => EmergencyContact.fromJson(e))
              .toList(),
        );
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _savePlan() async {
    final plan = {
      'triggers': _triggers,
      'warning_signs': _warningSigns,
      'coping_strategies': _copingStrategies,
      'emergency_contacts': _emergencyContacts.map((e) => e.toJson()).toList(),
      'support_network': _supportNetwork,
      'last_updated': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prevention_plan', jsonEncode(plan));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan saved successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                color: PdfColors.green700,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relapse Prevention Plan',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Created: ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              if (_triggers.isNotEmpty) ...[
                _pdfSection('Personal Triggers', _triggers),
                pw.SizedBox(height: 15),
              ],
              
              if (_warningSigns.isNotEmpty) ...[
                _pdfSection('Warning Signs', _warningSigns),
                pw.SizedBox(height: 15),
              ],
              
              if (_copingStrategies.isNotEmpty) ...[
                _pdfSection('Coping Strategies', _copingStrategies),
                pw.SizedBox(height: 15),
              ],
              
              if (_emergencyContacts.isNotEmpty) ...[
                pw.Text(
                  'Emergency Contacts',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 8),
                ..._emergencyContacts.map((contact) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                    '• ${contact.name} - ${contact.phone}${contact.relationship.isNotEmpty ? ' (${contact.relationship})' : ''}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                )),
                pw.SizedBox(height: 15),
              ],
              
              if (_supportNetwork.isNotEmpty) ...[
                _pdfSection('Support Network', _supportNetwork),
                pw.SizedBox(height: 15),
              ],
              
              pw.Spacer(),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CRISIS RESOURCES',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '988 - Suicide & Crisis Lifeline',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      'Text "HELLO" to 741741 - Crisis Text Line',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      '911 - Emergency Services',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated by ClearPath Recovery',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _pdfSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 8),
        ...items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            '• $item',
            style: const pw.TextStyle(fontSize: 12),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prevention Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _hasContent() ? _exportPDF : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF10B981),
              child: Column(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Build Your Safety Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identify risks and create a plan to stay safe',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Personal Triggers',
                    subtitle: 'What situations, people, or places increase your risk?',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFEF4444),
                    items: _triggers,
                    controller: _triggerController,
                    hintText: 'e.g., Stress at work, seeing old friends',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Warning Signs',
                    subtitle: 'How do you know when you\'re at risk?',
                    icon: Icons.flag,
                    color: const Color(0xFFF59E0B),
                    items: _warningSigns,
                    controller: _warningController,
                    hintText: 'e.g., Isolating, skipping meetings',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Coping Strategies',
                    subtitle: 'What helps you stay on track?',
                    icon: Icons.favorite,
                    color: const Color(0xFF10B981),
                    items: _copingStrategies,
                    controller: _copingController,
                    hintText: 'e.g., Call sponsor, exercise, meditate',
                  ),
                  const SizedBox(height: 20),
                  _buildContactsSection(),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Support Network',
                    subtitle: 'Who can you reach out to?',
                    icon: Icons.people,
                    color: const Color(0xFF3B82F6),
                    items: _supportNetwork,
                    controller: _supportController,
                    hintText: 'e.g., Sponsor, therapist, support group',
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> items,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      items.add(controller.text.trim());
                      controller.clear();
                    });
                  }
                },
                icon: Icon(Icons.add_circle, color: color, size: 32),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: const Color(0xFF6B7280),
                        onPressed: () {
                          setState(() {
                            items.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone, color: Color(0xFFDC2626), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'People to call in a crisis',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAddContactDialog(),
                icon: const Icon(Icons.add_circle, color: Color(0xFFDC2626), size: 32),
              ),
            ],
          ),
          if (_emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._emergencyContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildContactCard(contact, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.phone,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  if (contact.relationship.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.relationship,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: const Color(0xFF6B7280),
              onPressed: () {
                setState(() {
                  _emergencyContacts.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'John Doe',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '555-1234',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship (Optional)',
                hintText: 'Sponsor, Friend, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  phoneController.text.trim().isNotEmpty) {
                setState(() {
                  _emergencyContacts.add(
                    EmergencyContact(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      relationship: relationshipController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  bool _hasContent() {
    return _triggers.isNotEmpty ||
        _warningSigns.isNotEmpty ||
        _copingStrategies.isNotEmpty ||
        _emergencyContacts.isNotEmpty ||
        _supportNetwork.isNotEmpty;
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json['name'],
        phone: json['phone'],
        relationship: json['relationship'] ?? '',
      );
}