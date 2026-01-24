import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../checkin/checkin_service.dart';
import '../lessons/lesson_service.dart';
import '../reports/report_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final CheckInService _checkInService = CheckInService();
  final LessonService _lessonService = LessonService();
  final ReportService _reportService = ReportService();

  bool _isLoading = true;
  int _currentStreak = 0;
  int _daysSinceLastUse = 0;
  int _totalCheckIns = 0;
  int _lessonsCompleted = 0;
  int _totalLessons = 60;
  double _averageMood = 0.0;
  double _averageCravings = 0.0;
  List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    final streak = await _checkInService.getCurrentStreak();
    final daysSince = await _checkInService.getDaysSinceLastUse();
    final checkIns = await _checkInService.getAllCheckIns();
    final completed = await _lessonService.getTotalCompletedCount();
    final avgMood = await _checkInService.getAverageMood(days: 7);
    final avgCravings = await _checkInService.getAverageCravings(days: 7);

    // Get last 7 days of check-ins for chart
    final weeklyData = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final checkIn = await _checkInService.getCheckInForDate(date);
      weeklyData.add({
        'date': date,
        'mood': checkIn?.moodRating ?? 0,
        'cravings': checkIn?.cravingIntensity ?? 0,
        'hasData': checkIn != null,
      });
    }

    setState(() {
      _currentStreak = streak;
      _daysSinceLastUse = daysSince;
      _totalCheckIns = checkIns.length;
      _lessonsCompleted = completed;
      _averageMood = avgMood;
      _averageCravings = avgCravings;
      _weeklyData = weeklyData;
      _isLoading = false;
    });
  }

  Future<void> _generateWeeklyReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      final pdf = await _reportService.generateComplianceReport(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        await _reportService.previewPdf(pdf, 'Weekly Progress Report');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateCertificate() async {
    // Determine current week
    final currentLesson = await _lessonService.getCurrentLesson();
    final week = currentLesson['week']!;

    if (week == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete at least one full week to generate a certificate'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final pdf = await _reportService.generateWeeklyCertificate(week - 1);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        await _reportService.previewPdf(pdf, 'Week ${week - 1} Certificate');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onSelected: (value) {
              if (value == 'weekly_report') {
                _generateWeeklyReport();
              } else if (value == 'certificate') {
                _generateCertificate();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'weekly_report',
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 20),
                    SizedBox(width: 12),
                    Text('Generate Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'certificate',
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: 12),
                    Text('View Certificate'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                    _buildHeroStats(),
                    const SizedBox(height: 24),
                    _buildLessonProgress(),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildWeeklyAverages(),
                    const SizedBox(height: 16),
                    _buildCheckInHistory(),
                    const SizedBox(height: 16),
                    _buildReportButtons(),
                    const SizedBox(height: 24),
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
          Icon(icon, color: Colors.white, size: 28),
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
            style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
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
            '7-Day Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _weeklyData.length) {
                          final date = _weeklyData[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  // Mood line
                  LineChartBarData(
                    spots: _weeklyData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['mood'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withOpacity(0.1),
                    ),
                  ),
                  // Cravings line
                  LineChartBarData(
                    spots: _weeklyData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['cravings'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFEA580C),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFEA580C).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Mood', const Color(0xFF10B981)),
              const SizedBox(width: 24),
              _buildLegendItem('Cravings', const Color(0xFFEA580C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                style: TextStyle(fontSize: 16, color: color.withOpacity(0.6)),
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
              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                '$_totalCheckIns total check-ins',
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generateWeeklyReport,
            icon: const Icon(Icons.assignment, size: 18),
            label: const Text('Generate Report'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generateCertificate,
            icon: const Icon(Icons.workspace_premium, size: 18),
            label: const Text('Certificate'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
          Icon(icon, color: const Color(0xFF1E40AF), size: 32),
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
    if (_currentStreak == 0) return Icons.directions_walk;
    if (_currentStreak < 7) return Icons.trending_up;
    if (_currentStreak < 30) return Icons.star;
    return Icons.emoji_events;
  }
}