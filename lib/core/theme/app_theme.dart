import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global design system colors
  static const Color background = Color(0xFF050B0B);
  static const Color backgroundLight = Color(0xFF071412);
  static const Color backgroundCard = Color(0xFF0B1F1A);

  static const Color primaryNeon = Color(0xFF18F2C2);
  static const Color secondaryGreen = Color(0xFFB6FF3B);
  static const Color cyanAccent = Color(0xFF20E7FF);

  static const Color cardBg = Color(0x14FFFFFF); // 8% opacity
  static const Color borderCol = Color(0x22FFFFFF); // 13% opacity

  static const Color textPrimary = Color(0xFFF4FFF9);
  static const Color textSecondary = Color(0xFF9BAEAA);

  static const Color error = Color(0xFFFF5C7A);
  static const Color warning = Color(0xFFFFC857);
  static const Color success = Color(0xFF47FF9A);

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryGreen,
        tertiary: cyanAccent,
        surface: backgroundCard,
        error: error,
      ),
      textTheme: GoogleFonts.soraTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.sora(color: textPrimary),
        bodyMedium: GoogleFonts.sora(color: textSecondary),
        titleLarge:
            GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge:
            GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: primaryNeon),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: background,
          elevation: 8,
          shadowColor: primaryNeon.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: GoogleFonts.sora(color: textSecondary),
        hintStyle:
            GoogleFonts.sora(color: textSecondary.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: primaryNeon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: error),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: borderCol),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: borderCol),
        ),
      ),
    );
  }
}
