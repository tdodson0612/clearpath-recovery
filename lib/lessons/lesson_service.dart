import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'lesson_model.dart';

/// Service for managing lessons and progress
/// MVP: Uses hardcoded lessons and local storage. Will migrate to Supabase later.
class LessonService {
  static const String _keyLessonProgress = 'lesson_progress';

  /// Get all 12 weeks of lessons (5 lessons per week)
  List<Lesson> getAllLessons() {
    // TODO: Load from JSON files or database
    // For now, return Week 1 as example
    return _getWeek1Lessons();
  }

  /// Get lessons for a specific week
  List<Lesson> getLessonsForWeek(int week) {
    final allLessons = getAllLessons();
    return allLessons.where((l) => l.week == week).toList();
  }

  /// Get a specific lesson
  Lesson? getLesson(int week, int day) {
    final lessons = getAllLessons();
    try {
      return lessons.firstWhere((l) => l.week == week && l.day == day);
    } catch (e) {
      return null;
    }
  }

  /// Save lesson progress
  Future<bool> saveProgress(LessonProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing progress
      final allProgress = await getAllProgress();
      
      // Remove old progress for this lesson if exists
      allProgress.removeWhere((p) => 
          p.week == progress.week && p.day == progress.day);
      
      // Add new progress
      allProgress.add(progress);
      
      // Sort by week and day
      allProgress.sort((a, b) {
        if (a.week != b.week) return a.week.compareTo(b.week);
        return a.day.compareTo(b.day);
      });
      
      // Save to storage
      final jsonList = allProgress.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_keyLessonProgress, jsonString);
    } catch (e) {
      print('Error saving lesson progress: $e');
      return false;
    }
  }

  /// Get all lesson progress for current user
  Future<List<LessonProgress>> getAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLessonProgress);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => LessonProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading lesson progress: $e');
      return [];
    }
  }

  /// Get progress for a specific lesson
  Future<LessonProgress?> getProgressForLesson(int week, int day) async {
    final allProgress = await getAllProgress();
    try {
      return allProgress.firstWhere((p) => p.week == week && p.day == day);
    } catch (e) {
      return null;
    }
  }

  /// Check if a lesson is completed
  Future<bool> isLessonCompleted(int week, int day) async {
    final progress = await getProgressForLesson(week, day);
    return progress?.completed ?? false;
  }

  /// Get completed lessons count for current week
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
        final progress = allProgress.where((p) => 
            p.week == week && p.day == day).firstOrNull;
        
        if (progress == null || !progress.completed) {
          return {'week': week, 'day': day};
        }
      }
    }
    
    // All lessons completed, return last lesson
    return {'week': 12, 'day': 5};
  }

  /// Mark lesson as completed
  Future<bool> markLessonCompleted({
    required int week,
    required int day,
    required int timeSpentMinutes,
    Map<String, String>? reflectionAnswers,
  }) async {
    final lesson = getLesson(week, day);
    if (lesson == null) return false;

    final progress = LessonProgress(
      id: '${week}_$day',
      userId: 'current_user', // TODO: Get from auth
      lessonId: lesson.id,
      week: week,
      day: day,
      completed: true,
      timeSpentMinutes: timeSpentMinutes,
      completedAt: DateTime.now(),
      reflectionAnswers: reflectionAnswers,
    );

    return await saveProgress(progress);
  }

  /// Clear all progress (for testing or reset)
  Future<bool> clearAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyLessonProgress);
    } catch (e) {
      print('Error clearing progress: $e');
      return false;
    }
  }

  /// Week 1 Lessons (Example data structure)
  List<Lesson> _getWeek1Lessons() {
    return [
      Lesson(
        id: 'w1d1',
        week: 1,
        day: 1,
        title: 'Understanding Addiction',
        subtitle: 'Replace shame with understanding',
        content: '''
Addiction is not a moral failing. It is a complex condition that affects the brain's reward, motivation, and memory systems.

When someone develops an addiction, the brain undergoes changes that make it difficult to resist intense urges to use substances, even when the person wants to stop.

Understanding addiction as a medical condition rather than a character flaw is the first step toward recovery without shame.

The Brain and Addiction:
Your brain's reward system evolved to encourage behaviors essential for survival, like eating and social bonding. Substances hijack this system, creating a powerful chemical response that far exceeds natural rewards.

Over time, the brain adapts to the presence of the substance, requiring more to achieve the same effect (tolerance) and experiencing distress when it's absent (withdrawal).

Recovery is about healing these brain changes, not fixing a broken character.
''',
        keyPoints: [
          'Addiction affects brain chemistry, particularly dopamine pathways',
          'It is a medical condition, not a moral failure',
          'Understanding the science reduces shame and increases hope',
          'Recovery involves healing brain changes over time',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What surprised you most about the brain science of addiction?',
            hint: 'Consider what you thought before versus what you know now',
          ),
          ReflectionQuestion(
            question: 'How does understanding addiction as a medical condition change how you think about yourself?',
            hint: 'Think about shame, guilt, and self-compassion',
          ),
          ReflectionQuestion(
            question: 'What is one thing you can do today that supports your recovery?',
            hint: 'Small, concrete actions matter',
          ),
        ],
        estimatedMinutes: 12,
      ),
      Lesson(
        id: 'w1d2',
        week: 1,
        day: 2,
        title: 'Costs and Benefits',
        subtitle: 'Understanding what brought you here',
        content: '''
Every behavior, including substance use, serves a purpose at some point. Understanding what substances gave you—and what they took away—is crucial for recovery.

This isn't about judgment. It's about honest reflection.

What Substances Gave You:
Many people used substances to cope with pain, stress, trauma, or difficult emotions. Substances might have helped you feel confident, relaxed, or numb. They might have been social currency or a way to fit in.

These were real benefits, and acknowledging them is important.

What Substances Took Away:
Over time, the costs outweigh the benefits. Relationships suffer, health declines, finances crumble, and legal problems arise. The very thing that once helped becomes the source of new pain.

Moving Forward:
Recovery means finding healthier ways to meet the needs that substances once filled. It means building a life where you don't need to escape.
''',
        keyPoints: [
          'Substance use often starts as a solution to a problem',
          'Acknowledging benefits reduces shame and increases insight',
          'The costs eventually outweigh any benefits',
          'Recovery involves finding healthier ways to meet your needs',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What did substances give you when you first started using?',
            hint: 'Be honest—there were reasons',
          ),
          ReflectionQuestion(
            question: 'What have substances cost you?',
            hint: 'Relationships, health, opportunities, self-respect',
          ),
          ReflectionQuestion(
            question: 'What need can you meet today without substances?',
            hint: 'Connection, rest, stress relief, fun',
          ),
        ],
        estimatedMinutes: 15,
      ),
      Lesson(
        id: 'w1d3',
        week: 1,
        day: 3,
        title: 'Accountability Without Shame',
        subtitle: 'Taking responsibility with compassion',
        content: '''
Accountability means taking responsibility for your actions. Shame means believing you are fundamentally bad.

Accountability is necessary for growth. Shame is toxic and keeps you stuck.

The Difference:
Accountability says: "I made a mistake, and I can learn from it."
Shame says: "I am a mistake, and nothing will change."

Accountability looks forward. Shame looks backward with self-hatred.

Why This Matters:
Research shows that shame actually increases the likelihood of relapse. When you feel worthless, you're more likely to engage in self-destructive behavior.

Accountability, on the other hand, empowers change. When you take responsibility without drowning in shame, you can make amends, learn, and move forward.

How to Practice Accountability:
1. Name what happened without excuses
2. Acknowledge the impact on yourself and others
3. Identify what you can do differently
4. Make amends where possible
5. Forgive yourself and commit to change
''',
        keyPoints: [
          'Accountability is taking responsibility for actions',
          'Shame is toxic and increases relapse risk',
          'You can acknowledge harm without self-hatred',
          'Self-compassion supports lasting change',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What is one thing you need to take accountability for?',
            hint: 'Be specific and honest',
          ),
          ReflectionQuestion(
            question: 'How can you hold yourself accountable without shame?',
            hint: 'What would you say to a friend in your situation?',
          ),
          ReflectionQuestion(
            question: 'What is one amend you can make today?',
            hint: 'Start small—a text, a conversation, a changed behavior',
          ),
        ],
        estimatedMinutes: 13,
      ),
      Lesson(
        id: 'w1d4',
        week: 1,
        day: 4,
        title: 'Disease vs. Behavior',
        subtitle: 'Understanding the balance',
        content: '''
One of the most confusing aspects of addiction is that it's both a disease AND involves behavioral choices.

Both things are true. Understanding this paradox is essential.

Addiction as a Disease:
Addiction changes brain structure and function. These changes affect decision-making, impulse control, and the ability to resist cravings. This is why willpower alone often isn't enough.

Just like diabetes or heart disease, addiction requires ongoing management and sometimes medical intervention.

Addiction as Behavior:
At the same time, recovery requires making choices: choosing to attend support groups, choosing to avoid triggers, choosing to ask for help.

You are not responsible for having the disease, but you are responsible for your recovery.

The Balance:
Understanding addiction as a disease reduces shame and encourages treatment. Recognizing your role in recovery empowers action and builds self-efficacy.

You didn't choose addiction, but you can choose recovery.
''',
        keyPoints: [
          'Addiction is a medical condition that affects the brain',
          'Recovery requires active participation and choice',
          'You are not responsible for the disease, but you are responsible for recovery',
          'This balance reduces shame while encouraging action',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'How does viewing addiction as a disease change your perspective?',
            hint: 'Does it reduce guilt? Increase hope?',
          ),
          ReflectionQuestion(
            question: 'What choices can you make today that support your recovery?',
            hint: 'Small actions count',
          ),
          ReflectionQuestion(
            question: 'How can you balance self-compassion with personal responsibility?',
            hint: 'What does that look like in practice?',
          ),
        ],
        estimatedMinutes: 14,
      ),
      Lesson(
        id: 'w1d5',
        week: 1,
        day: 5,
        title: 'Week 1 Reflection',
        subtitle: 'Integrating what you learned',
        content: '''
Congratulations on completing Week 1 of ClearPath Recovery.

This week, you learned about the science of addiction, the costs and benefits of substance use, accountability without shame, and the balance between disease and behavior.

These concepts form the foundation of recovery without self-hatred.

Key Takeaways:
• Addiction is a medical condition that affects the brain
• Understanding the science reduces shame
• Substances once served a purpose, but the costs now outweigh benefits
• Accountability means taking responsibility with compassion
• You didn't choose addiction, but you can choose recovery

Moving Forward:
Recovery is not linear. There will be good days and hard days. The goal is progress, not perfection.

Next week, you'll learn about triggers and cravings—how to identify them and manage them effectively.

Before you move on, take a moment to acknowledge yourself for showing up this week. That takes courage.
''',
        keyPoints: [
          'You completed Week 1—that matters',
          'Understanding addiction reduces shame and increases hope',
          'Accountability and self-compassion go together',
          'Recovery is about progress, not perfection',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What was the most important thing you learned this week?',
            hint: 'What insight will you carry forward?',
          ),
          ReflectionQuestion(
            question: 'How has your view of yourself or your addiction changed?',
            hint: 'Even small shifts matter',
          ),
          ReflectionQuestion(
            question: 'What is one commitment you can make for Week 2?',
            hint: 'Be specific and realistic',
          ),
        ],
        estimatedMinutes: 10,
      ),
    ];
  }
}

// Extension to get first element or null (used above)
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}