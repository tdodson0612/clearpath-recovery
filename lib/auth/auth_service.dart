import 'package:shared_preferences/shared_preferences.dart';

/// Simple authentication service for MVP
/// Uses local storage. Will migrate to Supabase later.
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyDisclaimerAccepted = 'disclaimer_accepted';
  static const String _keyDisclaimerTimestamp = 'disclaimer_timestamp';

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Check if user has accepted disclaimer
  Future<bool> hasAcceptedDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDisclaimerAccepted) ?? false;
  }

  /// Get current user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Log disclaimer acceptance (important for court compliance)
  Future<void> logDisclaimerAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();
    
    await prefs.setBool(_keyDisclaimerAccepted, true);
    await prefs.setString(_keyDisclaimerTimestamp, timestamp);
  }

  /// Get disclaimer acceptance timestamp
  Future<String?> getDisclaimerTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisclaimerTimestamp);
  }

  /// Sign up (MVP version - no backend yet)
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API call to Supabase
      // For MVP, just simulate delay and store locally
      await Future.delayed(const Duration(seconds: 1));

      // Basic validation
      if (email.isEmpty || !email.contains('@')) {
        return AuthResult(
          success: false,
          error: 'Invalid email address',
        );
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          error: 'Password must be at least 6 characters',
        );
      }

      // Store user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  /// Sign in (MVP version - no backend yet)
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API call to Supabase
      // For MVP, just simulate delay and validate locally
      await Future.delayed(const Duration(seconds: 1));

      // Basic validation
      if (email.isEmpty || !email.contains('@')) {
        return AuthResult(
          success: false,
          error: 'Invalid email address',
        );
      }

      if (password.isEmpty) {
        return AuthResult(
          success: false,
          error: 'Password is required',
        );
      }

      // Store user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserEmail);
    // Keep disclaimer acceptance - user already agreed
  }

  /// Clear all data (for testing or account deletion)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

/// Result object for authentication operations
class AuthResult {
  final bool success;
  final String? error;

  AuthResult({
    required this.success,
    this.error,
  });
}