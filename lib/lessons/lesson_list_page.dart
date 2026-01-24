import 'package:flutter/material.dart';
import 'lesson_model.dart';
import 'lesson_service.dart';

class LessonListPage extends StatefulWidget {
  const LessonListPage({super.key});

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> with AutomaticKeepAliveClientMixin {
  final LessonService _lessonService = LessonService();
  List<Lesson> _lessons = [];
  Map<String, bool> _completionStatus = {};
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
    });

    // Load lessons
    final lessons = _lessonService.getAllLessons();
    
    // Load completion status for each lesson
    final Map<String, bool> completionStatus = {};
    for (var lesson in lessons) {
      final isCompleted = await _lessonService.isLessonCompleted(
        lesson.week,
        lesson.day,
      );
      completionStatus['${lesson.week}_${lesson.day}'] = isCompleted;
    }

    setState(() {
      _lessons = lessons;
      _completionStatus = completionStatus;
      _isLoading = false;
    });
  }

  Future<void> _navigateToLesson(Lesson lesson) async {
    final result = await Navigator.pushNamed(
      context,
      '/lesson/${lesson.week}/${lesson.day}',
    );

    // Reload if lesson was completed
    if (result == true) {
      await _loadLessons();
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
          'Lessons',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLessons,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _lessons.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeader();
                  }

                  final lesson = _lessons[index - 1];
                  final isCompleted = _completionStatus['${lesson.week}_${lesson.day}'] ?? false;
                  final isFirstOfWeek = lesson.day == 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfWeek) _buildWeekHeader(lesson.week),
                      _buildLessonCard(lesson, isCompleted),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final completedCount = _completionStatus.values.where((v) => v).length;
    final totalLessons = _lessons.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount of $totalLessons lessons completed',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(int week) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        'Week $week - ${_getWeekTitle(week)}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToLesson(lesson),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        )
                      : Text(
                          '${lesson.day}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${lesson.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekTitle(int week) {
    switch (week) {
      case 1:
        return 'Understanding Addiction';
      case 2:
        return 'Triggers & Cravings';
      case 3:
        return 'Thinking Patterns';
      case 4:
        return 'Emotional Regulation';
      case 5:
        return 'Trauma & Substance Use';
      case 6:
        return 'Relapse Prevention';
      case 7:
        return 'Relationships & Accountability';
      case 8:
        return 'Identity & Purpose';
      case 9:
        return 'Anxiety, Depression & Stress';
      case 10:
        return 'Spirituality (Optional)';
      case 11:
        return 'Lifestyle & Structure';
      case 12:
        return 'Long-Term Recovery';
      default:
        return 'Recovery';
    }
  }
}