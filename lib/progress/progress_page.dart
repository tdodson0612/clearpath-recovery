import 'package:flutter/material.dart';
import '../checkin/checkin_service.dart';
import '../lessons/lesson_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final CheckInService _checkInService = CheckInService();
  final LessonService _lessonService = LessonService();

  bool _isLoading = true;
  int _currentStreak = 0;
  int _daysSinceLastUse = 0;
  int _totalCheckIns = 0;
  int _lessonsCompleted = 0;
  int _totalLessons = 60; // 12 weeks × 5 days
  double _averageMood = 0.0;
  double _averageCravings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    // Load all stats
    final streak = await _checkInService.getCurrentStreak();
    final daysSince = await _checkInService.getDaysSinceLastUse();
    final checkIns = await _checkInService.getAllCheckIns();
    final completed = await _lessonService.getTotalCompletedCount();
    final avgMood = await _checkInService.getAverageMood(days: 7);
    final avgCravings = await _checkInService.getAverageCravings(days: 7);

    setState(() {
      _currentStreak = streak;
      _daysSinceLastUse = daysSince;
      _totalCheckIns = checkIns.length;
      _lessonsCompleted = completed;
      _averageMood = avgMood;
      _averageCravings = avgCravings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Progress',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero stats
                    _buildHeroStats(),

                    const SizedBox(height: 24),

                    // Lesson progress
                    _buildLessonProgress(),

                    const SizedBox(height: 16),

                    // Weekly mood & cravings
                    _buildWeeklyAverages(),

                    const SizedBox(height: 16),

                    // Check-in history
                    _buildCheckInHistory(),

                    const SizedBox(height: 24),

                    // Motivational message
                    _buildMotivationalMessage(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Current Streak',
            value: '$_currentStreak',
            subtitle: 'days',
            icon: Icons.local_fire_department,
            color: const Color(0xFFEA580C),
            gradient: const LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF97316)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Days Clean',
            value: '$_daysSinceLastUse',
            subtitle: 'days',
            icon: Icons.emoji_events,
            color: const Color(0xFF10B981),
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonProgress() {
    final progressPercent = _totalLessons > 0
        ? (_lessonsCompleted / _totalLessons * 100).toInt()
        : 0;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lesson Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_lessonsCompleted / $_totalLessons lessons',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _lessonsCompleted / _totalLessons,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAverages() {
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
          const Text(
            '7-Day Averages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAverageItem(
                  label: 'Mood',
                  value: _averageMood.toStringAsFixed(1),
                  maxValue: 10,
                  icon: Icons.sentiment_satisfied,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAverageItem(
                  label: 'Cravings',
                  value: _averageCravings.toStringAsFixed(1),
                  maxValue: 10,
                  icon: Icons.waves,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAverageItem({
    required String label,
    required String value,
    required double maxValue,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 2),
              child: Text(
                '/10',
                style: TextStyle(
                  fontSize: 16,
                  color: color.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInHistory() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Check-In History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                '$_totalCheckIns total check-ins',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    String message = _getMotivationalMessage();
    IconData icon = _getMotivationalIcon();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1E40AF),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_currentStreak == 0) {
      return 'Every journey starts with a single step. Keep showing up.';
    } else if (_currentStreak < 7) {
      return 'You\'re building momentum. $_currentStreak days and counting!';
    } else if (_currentStreak < 30) {
      return 'Amazing progress! $_currentStreak days of commitment.';
    } else if (_currentStreak < 90) {
      return 'You\'re doing incredible work. $_currentStreak days strong!';
    } else {
      return 'Remarkable dedication. $_currentStreak days of recovery!';
    }
  }

  IconData _getMotivationalIcon() {
    if (_currentStreak == 0) {
      return Icons.directions_walk;
    } else if (_currentStreak < 7) {
      return Icons.trending_up;
    } else if (_currentStreak < 30) {
      return Icons.star;
    } else {
      return Icons.emoji_events;
    }
  }
}