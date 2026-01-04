import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo
  static const Color secondaryLight = Color(0xFFF59E0B); // Amber/Gold
  static const Color bgLight = Color(0xFFF3F4F6);
  static const Color surfaceLight = Colors.white;

  static const Color primaryDark = Color(0xFF6366F1); // Lighter Indigo for dark mode
  static const Color secondaryDark = Color(0xFFFFD700); // Gold
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight, 
        primary: primaryLight,
        secondary: secondaryLight,
        background: bgLight,
        surface: surfaceLight,
        brightness: Brightness.light
    ),
    scaffoldBackgroundColor: bgLight,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark, 
        primary: primaryDark,
        secondary: secondaryDark,
        background: bgDark,
        surface: surfaceDark,
        brightness: Brightness.dark
    ),
    scaffoldBackgroundColor: bgDark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
