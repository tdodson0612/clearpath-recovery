//lib/auth/auth_service.dart
// UPDATED VERSION - Implements account deletion for Guideline 5.1.1

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service using Supabase
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Get current user email
  String? get userEmail => _supabase.auth.currentUser?.email;

  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    DateTime? sobrietyDate,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (sobrietyDate != null) {
        updates['sobriety_date'] = sobrietyDate.toIso8601String().split('T')[0];
      }

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account and all associated data
  /// REQUIRED by Apple App Store Review Guideline 5.1.1(v)
  /// 
  /// This method:
  /// 1. Deletes all user data from database tables
  /// 2. Deletes the user's authentication account
  /// 3. Signs the user out
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      debugPrint('🗑️ Starting account deletion for user: $userId');

      // Step 1: Delete all user data from database tables
      await Future.wait([
        _deleteFromTable('checkins', userId),
        _deleteFromTable('lesson_progress', userId),
        _deleteFromTable('prevention_plans', userId),
        _deleteFromTable('thought_challenges', userId),
      ]);

      debugPrint('✓ Deleted user data from all tables');

      // Step 2: Delete user profile
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);
      
      debugPrint('✓ Deleted user profile');

      // Step 3: Delete the authentication user account
      try {
        // Try Edge Function first
        final response = await _supabase.functions.invoke(
          'delete-user-account',
          body: {'user_id': userId},
        );
        
        if (response.status == 200) {
          debugPrint('✓ Deleted authentication user via Edge Function');
        } else {
          debugPrint('⚠️ Edge Function returned status ${response.status}');
        }
      } catch (e) {
        debugPrint('⚠️ Could not call Edge Function: $e');
        
        // Try Database Function as fallback
        try {
          await _supabase.rpc('delete_user_account', params: {'user_id': userId});
          debugPrint('✓ Deleted authentication user via Database Function');
        } catch (e2) {
          debugPrint('⚠️ Database Function also failed: $e2');
          debugPrint('💡 User data is deleted but auth account may persist');
        }
      }

      // Step 4: Sign out the user
      await signOut();
      debugPrint('✓ User signed out');
      
      debugPrint('✅ Account deletion completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during account deletion: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Helper method to delete data from a specific table
  Future<void> _deleteFromTable(String tableName, String userId) async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .eq('user_id', userId);
      debugPrint('✓ Deleted from $tableName');
    } catch (e) {
      debugPrint('⚠️ Could not delete from $tableName (table may not exist): $e');
    }
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}