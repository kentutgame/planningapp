import 'package:flutter/material.dart';

class StitchColors {
  // Dark Carbon Palette (Default Stitch)
  static const Color darkBackground = Color(0xFF111216);
  static const Color darkSurface = Color(0xFF191A20);
  static const Color darkCard = Color(0xFF22242C);
  static const Color darkCardHover = Color(0xFF2B2D37);
  static const Color darkBorder = Color(0xFF31343F);
  static const Color darkBorderActive = Color(0xFF4A4E5E);

  // Accents
  static const Color tealGlow = Color(0xFF00D2B4);
  static const Color tealGlowSubtle = Color(0x3300D2B4);
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color redFailed = Color(0xFFEF4444);
  static const Color redFailedBg = Color(0x26EF4444);
  static const Color yellowWarning = Color(0xFFF59E0B);
  static const Color greenSuccess = Color(0xFF10B981);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Notion Light Palette
  static const Color lightBackground = Color(0xFFFBFBFA);
  static const Color lightSurface = Color(0xFFF5F5F3);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5E3);
  static const Color lightTextPrimary = Color(0xFF2F3437);
  static const Color lightTextSecondary = Color(0xFF787774);
}

class StitchTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StitchColors.darkBackground,
      primaryColor: StitchColors.tealGlow,
      colorScheme: const ColorScheme.dark(
        primary: StitchColors.tealGlow,
        secondary: StitchColors.indigoAccent,
        surface: StitchColors.darkSurface,
        error: StitchColors.redFailed,
      ),
      cardTheme: CardTheme(
        color: StitchColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StitchColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StitchColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: StitchColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: StitchColors.textPrimary),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: StitchColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: StitchColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StitchColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: StitchColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: StitchColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.tealGlow, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: StitchColors.lightBackground,
      primaryColor: StitchColors.tealGlow,
      colorScheme: const ColorScheme.light(
        primary: StitchColors.tealGlow,
        secondary: StitchColors.indigoAccent,
        surface: StitchColors.lightSurface,
        error: StitchColors.redFailed,
      ),
      cardTheme: CardTheme(
        color: StitchColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StitchColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StitchColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: StitchColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: StitchColors.lightTextPrimary),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: StitchColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: StitchColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StitchColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: StitchColors.lightTextSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: StitchColors.lightTextPrimary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.tealGlow, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }
}
