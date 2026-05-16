import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navyCore = Color(0xFF2D3A50);
  static const Color darkNavy = Color(0xFF1E2A3A);
  static const Color warmBackground = Color(0xFFE8E6E1);
  static const Color mutedGold = Color(0xFFC9A97C);
  static const Color softCyan = Color(0xFF78A9C1);
  static const Color ivoryWhite = Color(0xFFFAFAFA);

  static const Color damageTotal = Color(0xFF9C5D4D);
  static const Color damagePartial = Color(0xFFD6B570);
  static const Color damageIntact = Color(0xFF91A68A);

  static const Color textPrimary = Color(0xFF2D3A50);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color errorColor = Color(0xFF9C5D4D);
  static const Color successColor = Color(0xFF91A68A);

  static const Color statusPending = Color(0xFFC9A97C);
  static const Color statusProcessed = Color(0xFF91A68A);
  static const Color statusFailed = Color(0xFF9C5D4D);

  static const Color damageLow = Color(0xFF91A68A);
  static const Color damageMedium = Color(0xFFD6B570);
  static const Color damageHigh = Color(0xFFC9896C);
  static const Color damageCritical = Color(0xFF9C5D4D);

  static const Color cardShadow = Color(0x1A2D3A50);
  static const Color divider = Color(0xFFD1CFC9);

  static const Color surfaceVariant = Color(0xFFF0EEEA);
  static const Color primaryContainer = Color(0xFFE8EDF2);
  static const Color secondaryContainer = Color(0xFFF5EFE3);

  static const Color primaryColor = navyCore;
  static const Color accentColor = softCyan;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.cairo().fontFamily,
      primaryColor: navyCore,
      scaffoldBackgroundColor: warmBackground,
      colorScheme: const ColorScheme.light(
        primary: navyCore,
        secondary: mutedGold,
        surface: ivoryWhite,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
        outline: divider,
        surfaceContainerHighest: surfaceVariant,
        primaryContainer: primaryContainer,
        secondaryContainer: secondaryContainer,
        onSurfaceVariant: textSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyCore,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ivoryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: divider, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyCore,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyCore,
          side: const BorderSide(color: navyCore, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mutedGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mutedGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ivoryWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navyCore, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ivoryWhite,
        selectedItemColor: navyCore,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ivoryWhite,
        selectedColor: Color(0x1A2D3A50),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: divider),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return mutedGold;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return mutedGold.withOpacity(0.3);
          }
          return divider;
        }),
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
          bodySmall: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: navyCore,
            letterSpacing: 0.3,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color getDamageLevelColor(int level) {
    switch (level) {
      case 1:
        return damageLow;
      case 2:
        return damageMedium;
      case 3:
        return damageHigh;
      case 4:
        return damageCritical;
      case 5:
        return damageCritical;
      default:
        return damageLow;
    }
  }

  static Color getDamageLevelColorFromString(String level) {
    switch (level.toLowerCase()) {
      case 'low':
      case 'intact':
      case 'safe':
        return damageIntact;
      case 'medium':
      case 'partial':
        return damagePartial;
      case 'high':
        return damageHigh;
      case 'critical':
      case 'severe':
      case 'total':
        return damageTotal;
      default:
        return damageLow;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'processing':
        return softCyan;
      case 'processed':
      case 'completed':
        return statusProcessed;
      case 'failed':
      case 'rejected':
        return statusFailed;
      default:
        return statusPending;
    }
  }
}
