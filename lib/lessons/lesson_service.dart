//lib/lessons/lesson_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'lesson_model.dart';
import 'weeks/week_1_lessons.dart';
import 'weeks/week_2_lessons.dart';
import 'weeks/week_3_lessons.dart';
import 'weeks/week_4_lessons.dart';
import 'weeks/week_5_lessons.dart';
import 'weeks/week_6_lessons.dart';
import 'weeks/week_7_lessons.dart';
import 'weeks/week_8_lessons.dart';
import 'weeks/week_9_lessons.dart';
import 'weeks/week_10_lessons.dart';
import 'weeks/week_11_lessons.dart';
import 'weeks/week_12_lessons.dart';

/// Service for managing lessons and progress with Supabase backend
class LessonService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all available lessons (hardcoded for now, will move to CMS later)
  List<Lesson> getAllLessons() {
    // For MVP, lessons are hardcoded in weekly modules
    // In Phase 2, these will come from Supabase/CMS
    return [
      ...Week1Lessons.getLessons(),
      ...Week2Lessons.getLessons(),
      ...Week3Lessons.getLessons(),
      ...Week4Lessons.getLessons(),
      ...Week5Lessons.getLessons(),
      ...Week6Lessons.getLessons(),
      ...Week7Lessons.getLessons(),
      ...Week8Lessons.getLessons(),
      ...Week9Lessons.getLessons(),
      ...Week10Lessons.getLessons(),
      ...Week11Lessons.getLessons(),
      ...Week12Lessons.getLessons(),
    ];
  }

  /// Get lessons for a specific week
  List<Lesson> getLessonsForWeek(int week) {
    final allLessons = getAllLessons();
    return allLessons.where((l) => l.week == week).toList();
  }

  /// Get a specific lesson by ID
  Lesson? getLessonById(String lessonId) {
    final allLessons = getAllLessons();
    try {
      return allLessons.firstWhere((l) => l.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific lesson by week and day
  Lesson? getLesson(int week, int day) {
    final allLessons = getAllLessons();
    try {
      return allLessons.firstWhere((l) => l.week == week && l.day == day);
    } catch (e) {
      return null;
    }
  }

  /// Mark a lesson as complete
  Future<bool> markLessonCompleted({
    required int week,
    required int day,
    required int timeSpentMinutes,
    required Map<String, String> reflectionAnswers,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not authenticated');

      // Generate lesson ID
      final lessonId = 'w${week}d$day';

      final data = {
        'user_id': userId,
        'lesson_id': lessonId,
        'week': week,
        'day': day,
        'completed': true,
        'time_spent_minutes': timeSpentMinutes,
        'completed_at': DateTime.now().toIso8601String(),
        'reflection_answers': reflectionAnswers,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('lesson_progress')
          .upsert(data, onConflict: 'user_id,lesson_id');

      return true;
    } catch (e) {
      print('Error marking lesson complete: $e');
      return false;
    }
  }

  /// Save lesson progress (for backward compatibility)
  Future<bool> saveProgress(LessonProgress progress) async {
    return await markLessonCompleted(
      week: progress.week,
      day: progress.day,
      timeSpentMinutes: progress.timeSpentMinutes,
      reflectionAnswers: progress.reflectionAnswers ?? {},
    );
  }

  /// Get progress for a specific lesson
  Future<LessonProgress?> getLessonProgress(String lessonId) async {
    try {
      final userId = _userId;
      if (userId == null) return null;

      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      if (response == null) return null;

      return LessonProgress.fromJson(response);
    } catch (e) {
      print('Error getting lesson progress: $e');
      return null;
    }
  }

  /// Get progress for a specific lesson by week and day
  Future<LessonProgress?> getProgressForLesson(int week, int day) async {
    try {
      final userId = _userId;
      if (userId == null) return null;

      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId)
          .eq('week', week)
          .eq('day', day)
          .maybeSingle();

      if (response == null) return null;

      return LessonProgress.fromJson(response);
    } catch (e) {
      print('Error getting lesson progress: $e');
      return null;
    }
  }

  /// Get all lesson progress for current user
  Future<List<LessonProgress>> getAllProgress() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId)
          .order('week')
          .order('day');

      return (response as List)
          .map((json) => LessonProgress.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all progress: $e');
      return [];
    }
  }

  /// Check if a lesson is completed by week and day
  Future<bool> isLessonCompleted(int week, int day) async {
    final progress = await getProgressForLesson(week, day);
    return progress?.completed ?? false;
  }

  /// Get completed lessons count for a specific week
  Future<int> getWeeklyCompletedCount(int week) async {
    final allProgress = await getAllProgress();
    return allProgress.where((p) => p.week == week && p.completed).length;
  }

  /// Get total completed lessons count
  Future<int> getTotalCompletedCount() async {
    final allProgress = await getAllProgress();
    return allProgress.where((p) => p.completed).length;
  }

  /// Get current week/day (first incomplete lesson)
  Future<Map<String, int>> getCurrentLesson() async {
    final allProgress = await getAllProgress();
    
    // Find first incomplete lesson
    for (int week = 1; week <= 12; week++) {
      for (int day = 1; day <= 5; day++) {
        final progress = allProgress
            .where((p) => p.week == week && p.day == day)
            .firstOrNull;
        
        if (progress == null || !progress.completed) {
          return {'week': week, 'day': day};
        }
      }
    }
    
    // All lessons completed, return last lesson
    return {'week': 12, 'day': 5};
  }

  /// Get completion percentage for a week
  Future<double> getWeekCompletionPercentage(int week) async {
    final weekLessons = getLessonsForWeek(week);
    if (weekLessons.isEmpty) return 0.0;

    int completedCount = 0;
    for (var lesson in weekLessons) {
      if (await isLessonCompleted(lesson.week, lesson.day)) {
        completedCount++;
      }
    }

    return (completedCount / weekLessons.length) * 100;
  }

  /// Get overall completion percentage
  Future<double> getOverallCompletionPercentage() async {
    final allLessons = getAllLessons();
    if (allLessons.isEmpty) return 0.0;

    int completedCount = 0;
    for (var lesson in allLessons) {
      if (await isLessonCompleted(lesson.week, lesson.day)) {
        completedCount++;
      }
    }

    return (completedCount / allLessons.length) * 100;
  }

  /// Get next incomplete lesson
  Future<Lesson?> getNextLesson() async {
    final allLessons = getAllLessons();
    
    for (var lesson in allLessons) {
      if (!await isLessonCompleted(lesson.week, lesson.day)) {
        return lesson;
      }
    }
    
    return null;
  }

  /// Get total lessons completed count
  Future<int> getTotalLessonsCompleted() async {
    final allProgress = await getAllProgress();
    return allProgress.where((p) => p.completed).length;
  }

  /// Clear all progress (for testing or reset)
  Future<bool> clearAllProgress() async {
    try {
      final userId = _userId;
      if (userId == null) return false;

      await _supabase
          .from('lesson_progress')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error clearing progress: $e');
      return false;
    }
  }
}

// Extension to get first element or null
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}