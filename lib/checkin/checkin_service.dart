import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'checkin_model.dart';

/// Service for managing daily check-ins
/// MVP: Uses local storage. Will migrate to Supabase later.
class CheckInService {
  static const String _keyCheckIns = 'check_ins';

  /// Save a check-in
  Future<bool> saveCheckIn(DailyCheckIn checkIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing check-ins
      final checkIns = await getAllCheckIns();
      
      // Add new check-in (or update if same date exists)
      checkIns.removeWhere((c) => _isSameDay(c.date, checkIn.date));
      checkIns.add(checkIn);
      
      // Sort by date (newest first)
      checkIns.sort((a, b) => b.date.compareTo(a.date));
      
      // Convert to JSON and save
      final jsonList = checkIns.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_keyCheckIns, jsonString);
    } catch (e) {
      print('Error saving check-in: $e');
      return false;
    }
  }

  /// Get all check-ins for current user
  Future<List<DailyCheckIn>> getAllCheckIns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyCheckIns);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => DailyCheckIn.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading check-ins: $e');
      return [];
    }
  }

  /// Get check-in for a specific date
  Future<DailyCheckIn?> getCheckInForDate(DateTime date) async {
    final checkIns = await getAllCheckIns();
    try {
      return checkIns.firstWhere((c) => _isSameDay(c.date, date));
    } catch (e) {
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
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final allCheckIns = await getAllCheckIns();
    return allCheckIns.where((c) {
      return c.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             c.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get check-ins for current month
  Future<List<DailyCheckIn>> getThisMonthCheckIns() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final allCheckIns = await getAllCheckIns();
    return allCheckIns.where((c) {
      return c.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             c.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate current streak (consecutive days substance-free)
  Future<int> getCurrentStreak() async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0;
    
    // Sort by date (newest first)
    checkIns.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime expectedDate = DateTime.now();
    
    for (var checkIn in checkIns) {
      // Check if this check-in is for the expected date
      if (!_isSameDay(checkIn.date, expectedDate)) {
        break;
      }
      
      // If substance was used, streak ends
      if (checkIn.substanceUsed) {
        break;
      }
      
      // Increment streak and move to previous day
      streak++;
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  /// Calculate days since last substance use
  Future<int> getDaysSinceLastUse() async {
    final checkIns = await getAllCheckIns();
    if (checkIns.isEmpty) return 0;
    
    // Sort by date (newest first)
    checkIns.sort((a, b) => b.date.compareTo(a.date));
    
    // Find most recent substance use
    for (var checkIn in checkIns) {
      if (checkIn.substanceUsed) {
        return DateTime.now().difference(checkIn.date).inDays;
      }
    }
    
    // No substance use found in check-ins
    // Return days since first check-in
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
    
    final sum = recentCheckIns.fold<int>(
      0,
      (sum, c) => sum + c.moodRating,
    );
    
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
    
    final sum = recentCheckIns.fold<int>(
      0,
      (sum, c) => sum + c.cravingIntensity,
    );
    
    return sum / recentCheckIns.length;
  }

  /// Delete a check-in
  Future<bool> deleteCheckIn(String checkInId) async {
    try {
      final checkIns = await getAllCheckIns();
      checkIns.removeWhere((c) => c.id == checkInId);
      
      final prefs = await SharedPreferences.getInstance();
      final jsonList = checkIns.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_keyCheckIns, jsonString);
    } catch (e) {
      print('Error deleting check-in: $e');
      return false;
    }
  }

  /// Clear all check-ins (for testing or account deletion)
  Future<bool> clearAllCheckIns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyCheckIns);
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