import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFDC3545);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status colors for reports
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusProcessed = Color(0xFF4CAF50);
  static const Color statusFailed = Color(0xFFF44336);

  // Damage level colors
  static const Color damageLevel1 = Color(0xFF4CAF50); // Low
  static const Color damageLevel2 = Color(0xFFFF9800); // Medium
  static const Color damageLevel3 = Color(0xFFFF5722); // High
  static const Color damageLevel4 = Color(0xFFF44336); // Severe
  static const Color damageLevel5 = Color(0xFF9C27B0); // Critical

  // New damage level colors (string-based)
  static const Color damageLow = Color(0xFF4CAF50); // Low (1-3)
  static const Color damageMedium = Color(0xFFFF9800); // Medium (4-6)
  static const Color damageHigh = Color(0xFFFF5722); // High (7-8)
  static const Color damageCritical = Color(0xFFF44336); // Critical (9-10)

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: textHint),
      ),

      // Card theme - commented out due to compatibility issues
      // cardTheme: CardTheme(
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      // ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }

  /// Get damage level color (int-based, legacy)
  static Color getDamageLevelColor(int level) {
    switch (level) {
      case 1:
        return damageLevel1;
      case 2:
        return damageLevel2;
      case 3:
        return damageLevel3;
      case 4:
        return damageLevel4;
      case 5:
        return damageLevel5;
      default:
        return damageLevel1;
    }
  }

  /// Get damage level color (string-based, new API)
  static Color getDamageLevelColorFromString(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return damageLow;
      case 'medium':
        return damageMedium;
      case 'high':
        return damageHigh;
      case 'critical':
        return damageCritical;
      default:
        return damageLow;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'processed':
        return statusProcessed;
      case 'failed':
        return statusFailed;
      default:
        return statusPending;
    }
  }
}