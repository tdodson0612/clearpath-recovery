// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

/// ClearPath Recovery Brand Colors
/// Extracted from the official logo and brand guidelines
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS (from logo)
  // ============================================================================
  
  /// Deep Blue - Primary brand color (left side of "Clear")
  static const Color primaryBlue = Color(0xFF1976D2);
  
  /// Vibrant Green - Primary brand color (right side of "Path")
  static const Color primaryGreen = Color(0xFF43A047);
  
  /// Accent Blue - Lighter blue for highlights
  static const Color accentBlue = Color(0xFF2196F3);
  
  /// Accent Green - Lighter green for highlights
  static const Color accentGreen = Color(0xFF66BB6A);
  
  /// Sky Blue - From the river in logo
  static const Color skyBlue = Color(0xFF42A5F5);
  
  /// Forest Green - From mountains in logo
  static const Color forestGreen = Color(0xFF388E3C);
  
  /// Warm Orange - From sun in logo
  static const Color warmOrange = Color(0xFFFF9800);

  // ============================================================================
  // BACKGROUNDS
  // ============================================================================
  
  /// Light background with subtle blue-green tint
  static const Color backgroundLight = Color(0xFFF5F9FA);
  
  /// Pure white for cards
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  /// Light border with green tint
  static const Color borderLight = Color(0xFFE0F2F1);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Dark text for headings
  static const Color textDark = Color(0xFF1F2937);
  
  /// Medium gray for body text
  static const Color textMedium = Color(0xFF6B7280);
  
  /// Light gray for subtle text
  static const Color textLight = Color(0xFF9CA3AF);

  // ============================================================================
  // STATUS COLORS
  // ============================================================================
  
  /// Success green (harmonizes with brand green)
  static const Color success = Color(0xFF10B981);
  
  /// Warning orange
  static const Color warning = Color(0xFFF59E0B);
  
  /// Error red (for panic button - DO NOT CHANGE)
  static const Color error = Color(0xFFDC2626);
  
  /// Info blue (harmonizes with brand blue)
  static const Color info = Color(0xFF3B82F6);

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  
  /// Primary gradient (Blue to Green)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Light gradient (Accent Blue to Accent Green)
  static const LinearGradient lightGradient = LinearGradient(
    colors: [accentBlue, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Sky gradient (for special cards)
  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // SEMANTIC COLORS (for specific UI elements)
  // ============================================================================
  
  /// AppBar background
  static const Color appBarBackground = cardWhite;
  
  /// AppBar icon color
  static const Color appBarIcon = textMedium;
  
  /// Button primary (uses brand gradient)
  static const Color buttonPrimary = primaryBlue;
  
  /// Button secondary
  static const Color buttonSecondary = primaryGreen;
  
  /// Input border
  static const Color inputBorder = Color(0xFFE5E7EB);
  
  /// Input border focused
  static const Color inputBorderFocused = primaryBlue;
  
  /// Divider
  static const Color divider = Color(0xFFE5E7EB);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get shadow color for elevated elements
  static Color getShadowColor({double opacity = 0.1}) {
    return primaryBlue.withOpacity(opacity);
  }
  
  /// Get gradient box decoration
  static BoxDecoration getGradientDecoration({
    LinearGradient? gradient,
    double borderRadius = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}