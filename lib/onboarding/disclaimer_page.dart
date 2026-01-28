//lib/onboarding/disclaimer_page.dart

import 'package:flutter/material.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'CP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Center(
                child: Text(
                  'ClearPath Recovery',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Center(
                child: Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Disclaimer content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This App Provides Educational Support Only',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ClearPath Recovery provides structured psycho-educational recovery programming consistent with evidence-based substance use disorder principles.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'This app is NOT:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Medical treatment or medical advice\n'
                          '• Therapy or counseling\n'
                          '• A substitute for professional care\n'
                          '• A diagnostic tool\n'
                          '• Emergency services',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'If you are in crisis or immediate danger, please contact emergency services (911) or the National Suicide Prevention Lifeline (988).',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'This app is designed to complement—not replace—professional treatment, counseling, medical care, or support groups.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Agreement checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _hasAgreed = !_hasAgreed;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _hasAgreed 
                            ? const Color(0xFF4F46E5) 
                            : Colors.white,
                        border: Border.all(
                          color: _hasAgreed 
                              ? const Color(0xFF4F46E5) 
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _hasAgreed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I understand this app provides educational support only and is not medical treatment or therapy.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasAgreed 
                      ? () async {
                          // Log acceptance with timestamp
                          // TODO: Add actual logging when auth service is ready
                          
                          // Navigate to home
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _hasAgreed ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}