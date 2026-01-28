//tools/tools_page.dart

import 'package:flutter/material.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recovery Tools',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Support tools for difficult moments',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 24),

            // Crisis notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Color(0xFFDC2626),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF991B1B),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'In Crisis? ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Call 988 (Suicide & Crisis Lifeline) or 911',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Panic Button
            _buildToolCard(
              context: context,
              title: 'Panic Button',
              subtitle: 'Grounding exercises for overwhelming moments',
              icon: Icons.emergency,
              color: const Color(0xFFDC2626),
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/tools/panic-button');
              },
            ),

            const SizedBox(height: 16),

            // Urge Surfing Timer
            _buildToolCard(
              context: context,
              title: 'Urge Surfing Timer',
              subtitle: 'Ride out cravings with guided timing',
              icon: Icons.timer,
              color: const Color(0xFFEA580C),
              gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFF97316)],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/tools/urge-timer');
              },
            ),

            const SizedBox(height: 16),

            // CBT Thought Challenge
            _buildToolCard(
              context: context,
              title: 'Thought Challenge',
              subtitle: 'Identify and challenge negative thinking',
              icon: Icons.psychology,
              color: const Color(0xFF4F46E5),
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/tools/thought-challenge');
              },
            ),

            const SizedBox(height: 16),

            // Relapse Prevention Plan
            _buildToolCard(
              context: context,
              title: 'Relapse Prevention Plan',
              subtitle: 'Build your personalized safety plan',
              icon: Icons.shield,
              color: const Color(0xFF10B981),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/tools/prevention-plan');
              },
            ),

            const SizedBox(height: 32),

            // Additional resources
            const Text(
              'Additional Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 16),

            _buildResourceCard(
              title: 'Crisis Hotlines',
              description: 'Emergency contact numbers',
              icon: Icons.phone,
              onTap: () {
                Navigator.pushNamed(context, '/crisis-resources');
              },
            ),

            const SizedBox(height: 12),

            _buildResourceCard(
              title: 'Support Groups',
              description: 'Find local and online meetings',
              icon: Icons.groups,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support group finder coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD1D5DB),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}