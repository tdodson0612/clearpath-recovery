/// Model for a single lesson
class Lesson {
  final String id;
  final int week;
  final int day;
  final String title;
  final String subtitle;
  final String content;
  final List<String> keyPoints;
  final List<ReflectionQuestion> reflectionQuestions;
  final int estimatedMinutes;

  Lesson({
    required this.id,
    required this.week,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.keyPoints,
    required this.reflectionQuestions,
    required this.estimatedMinutes,
  });

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week': week,
      'day': day,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'key_points': keyPoints,
      'reflection_questions': reflectionQuestions.map((q) => q.toJson()).toList(),
      'estimated_minutes': estimatedMinutes,
    };
  }

  /// Create from JSON
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      week: json['week'] as int,
      day: json['day'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      content: json['content'] as String,
      keyPoints: (json['key_points'] as List).cast<String>(),
      reflectionQuestions: (json['reflection_questions'] as List)
          .map((q) => ReflectionQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      estimatedMinutes: json['estimated_minutes'] as int,
    );
  }

  /// Get display string for week/day (e.g., "Week 1, Day 1")
  String get displayWeekDay => 'Week $week, Day $day';

  @override
  String toString() => 'Lesson($displayWeekDay: $title)';
}

/// Model for a reflection question within a lesson
class ReflectionQuestion {
  final String question;
  final String? hint;

  ReflectionQuestion({
    required this.question,
    this.hint,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'hint': hint,
    };
  }

  factory ReflectionQuestion.fromJson(Map<String, dynamic> json) {
    return ReflectionQuestion(
      question: json['question'] as String,
      hint: json['hint'] as String?,
    );
  }
}

/// Model for tracking lesson progress
class LessonProgress {
  final String id;
  final String userId;
  final String lessonId;
  final int week;
  final int day;
  final bool completed;
  final int timeSpentMinutes;
  final DateTime? completedAt;
  final Map<String, String>? reflectionAnswers;

  LessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.week,
    required this.day,
    required this.completed,
    required this.timeSpentMinutes,
    this.completedAt,
    this.reflectionAnswers,
  });

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'week': week,
      'day': day,
      'completed': completed,
      'time_spent_minutes': timeSpentMinutes,
      'completed_at': completedAt?.toIso8601String(),
      'reflection_answers': reflectionAnswers,
    };
  }

  /// Create from JSON
  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      week: json['week'] as int,
      day: json['day'] as int,
      completed: json['completed'] as bool,
      timeSpentMinutes: json['time_spent_minutes'] as int,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      reflectionAnswers: json['reflection_answers'] != null
          ? Map<String, String>.from(json['reflection_answers'] as Map)
          : null,
    );
  }

  /// Copy with modifications
  LessonProgress copyWith({
    String? id,
    String? userId,
    String? lessonId,
    int? week,
    int? day,
    bool? completed,
    int? timeSpentMinutes,
    DateTime? completedAt,
    Map<String, String>? reflectionAnswers,
  }) {
    return LessonProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      week: week ?? this.week,
      day: day ?? this.day,
      completed: completed ?? this.completed,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      completedAt: completedAt ?? this.completedAt,
      reflectionAnswers: reflectionAnswers ?? this.reflectionAnswers,
    );
  }

  @override
  String toString() {
    return 'LessonProgress(Week $week, Day $day, completed: $completed)';
  }
}