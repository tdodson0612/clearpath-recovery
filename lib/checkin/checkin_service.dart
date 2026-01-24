import 'package:supabase_flutter/supabase_flutter.dart';
import 'checkin_model.dart';

/// Service for managing daily check-ins with Supabase backend
class CheckInService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Save a check-in
  Future<bool> saveCheckIn(DailyCheckIn checkIn) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not authenticated');

      final data = {
        'user_id': userId,
        'date': checkIn.date.toIso8601String().split('T')[0],
        'mood_rating': checkIn.moodRating,
        'craving_intensity': checkIn.cravingIntensity,
        'substance_used': checkIn.substanceUsed,
        'recovery_action': checkIn.recoveryAction,
      };

      await _supabase
          .from('check_ins')
          .upsert(data, onConflict: 'user_id,date');

      return true;
    } catch (e) {
      print('Error saving check-in: $e');
      return false;
    }
  }

  /// Get all check-ins for current user
  Future<List<DailyCheckIn>> getAllCheckIns() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final response = await _supabase
          .from('check_ins')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => DailyCheckIn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading check-ins: $e');
      return [];
    }
  }

  /// Get check-in for a specific date
  Future<DailyCheckIn?> getCheckInForDate(DateTime date) async {
    try {
      final userId = _userId;
      if (userId == null) return null;

      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('check_ins')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      
      return DailyCheckIn.fromJson(response);
    } catch (e) {
      print('Error getting check-in: $e');
      return null;
    }
  }

  /// Check if user has checked in today
  Future<bool> hasCheckedInToday() async {
    final today = DateTime.now();
    final checkIn = await getCheckInForDate(today);
    return checkIn != null;
  }

  /// Get check-ins for current week
  Future<List<DailyCheckIn>> getThisWeekCheckIns() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      final response = await _supabase
          .from('check_ins')
          .select()
          .eq('user_id', userId)
          .gte('date', startOfWeek.toIso8601String().split('T')[0])
          .lte('date', endOfWeek.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return (response as List)
          .map((json) => DailyCheckIn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting week check-ins: $e');
      return [];
    }
  }

  /// Get check-ins for current month
  Future<List<DailyCheckIn>> getThisMonthCheckIns() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final response = await _supabase
          .from('check_ins')
          .select()
          .eq('user_id', userId)
          .gte('date', startOfMonth.toIso8601String().split('T')[0])
          .lte('date', endOfMonth.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return (response as List)
          .map((json) => DailyCheckIn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting month check-ins: $e');
      return [];
    }
  }

  /// Calculate current streak (consecutive days substance-free)
  Future<int> getCurrentStreak() async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0;
    
    int streak = 0;
    DateTime expectedDate = DateTime.now();
    
    for (var checkIn in checkIns) {
      if (!_isSameDay(checkIn.date, expectedDate)) {
        break;
      }
      
      if (checkIn.substanceUsed) {
        break;
      }
      
      streak++;
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  /// Calculate days since last substance use
  Future<int> getDaysSinceLastUse() async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0;
    
    for (var checkIn in checkIns) {
      if (checkIn.substanceUsed) {
        return DateTime.now().difference(checkIn.date).inDays;
      }
    }
    
    return DateTime.now().difference(checkIns.last.date).inDays;
  }

  /// Get average mood rating for a period
  Future<double> getAverageMood({int days = 7}) async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0.0;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentCheckIns = checkIns
        .where((c) => c.date.isAfter(cutoffDate))
        .toList();
    
    if (recentCheckIns.isEmpty) return 0.0;
    
    final sum = recentCheckIns.fold<int>(0, (sum, c) => sum + c.moodRating);
    return sum / recentCheckIns.length;
  }

  /// Get average craving intensity for a period
  Future<double> getAverageCravings({int days = 7}) async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0.0;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentCheckIns = checkIns
        .where((c) => c.date.isAfter(cutoffDate))
        .toList();
    
    if (recentCheckIns.isEmpty) return 0.0;
    
    final sum = recentCheckIns.fold<int>(0, (sum, c) => sum + c.cravingIntensity);
    return sum / recentCheckIns.length;
  }

  /// Delete a check-in
  Future<bool> deleteCheckIn(String checkInId) async {
    try {
      final userId = _userId;
      if (userId == null) return false;

      await _supabase
          .from('check_ins')
          .delete()
          .eq('id', checkInId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error deleting check-in: $e');
      return false;
    }
  }

  /// Clear all check-ins (for testing or account deletion)
  Future<bool> clearAllCheckIns() async {
    try {
      final userId = _userId;
      if (userId == null) return false;

      await _supabase
          .from('check_ins')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error clearing check-ins: $e');
      return false;
    }
  }

  /// Helper: Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}