import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ===== 赛博暗色主题 (Cyber Dark Mode) =====
  static const Color primaryNeonGreen = Color(0xFF00FF88);
  static const Color secondaryNeonPurple = Color(0xFFB44CFF);
  static const Color accentNeonCyan = Color(0xFF00E5FF);
  static const Color accentNeonPink = Color(0xFFFF2D95);
  static const Color warningNeonOrange = Color(0xFFFF8C00);
  
  static const Color bgDeepDark = Color(0xFF0A0A0F);
  static const Color bgCardDark = Color(0xFF141420);
  static const Color bgSurfaceDark = Color(0xFF1A1A2E);
  static const Color bgElevatedDark = Color(0xFF222236);
  
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textHint = Color(0xFF555577);
  
  static const Color borderGlow = Color(0xFF2A2A44);

  // ===== 渐变色定义 =====
  static const LinearGradient gradientNeon = LinearGradient(
    colors: [primaryNeonGreen, accentNeonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPurple = LinearGradient(
    colors: [secondaryNeonPurple, accentNeonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCyber = LinearGradient(
    colors: [primaryNeonGreen, secondaryNeonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeepDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryNeonGreen,
      secondary: secondaryNeonPurple,
      surface: bgSurfaceDark,
      error: accentNeonPink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDeepDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'CyberNeon',
      ),
      iconTheme: IconThemeData(color: primaryNeonGreen),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCardDark,
      selectedItemColor: primaryNeonGreen,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: bgCardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderGlow.withOpacity(0.3), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNeonGreen,
        foregroundColor: bgDeepDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSurfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderGlow.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryNeonGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700,
        fontFamily: 'CyberNeon',
      ),
      headlineMedium: TextStyle(
        color: textPrimary, fontSize: 22, fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textPrimary, fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textSecondary, fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: textHint, fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: primaryNeonGreen, fontSize: 14, fontWeight: FontWeight.w600,
      ),
    ),
  );
}
