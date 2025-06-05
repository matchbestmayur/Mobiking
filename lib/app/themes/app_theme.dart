import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF5F13C5);
  static const Color darkPurple = Color(0xFF3E0D91);
  static const Color lightPurple = Color(0xFFD8C4F5);
  static const Color accentNeon = Color(0xFF00CCFF);
  static const Color neutralBackground = Color(0xFFF8F9FC);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF666666);
  static const Color success = Color(0xFF00C48C);
  static const Color danger = Color(0xFFFF4C61);
  static const Color gradientStart = Color(0xFF5F13C5);
  static const Color gradientEnd = Color(0xFFFF4C61);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.neutralBackground,
      primaryColor: AppColors.primaryPurple,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textLight,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentNeon,
        error: AppColors.danger,
        background: AppColors.neutralBackground,
      ),
    );
  }
}
