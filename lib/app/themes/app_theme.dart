import 'package:flutter/material.dart';
// No need for google_fonts anymore

class AppColors {
  static const Color primaryPurple = Color(0xFF5F13C5);
  static const Color darkPurple = Color(0xFF3E0D91);
  static const Color lightPurple = Color(0xFFD8C4F5);
  static const Color accentNeon = Color(0xFF00CCFF);
  static const Color neutralBackground = Color(0xFFF8F9FC);
  static const Color textDark = Color(0xFF1A1A1A); // Used for primary text, almost black
  static const Color textLight = Color(0xFF666666); // Lighter grey for secondary/hint text
  static const Color textMedium = Color(0xFF333333); // A slightly darker grey for important secondary text

  // Blinkit Green Colors
  static const Color primaryGreen = Color(0xFF00CCBC); // A common Blinkit green
  static const Color lightGreen = Color(0xFFE6FFF9); // A lighter shade of green for backgrounds/chips
  static const Color discountGreen = Color(0xFFE0F7FA); // A very light, almost white green for discount badges

  static const Color success = Color(0xFF00C48C);
  static const Color danger = Color(0xFFFF4C61);
  static const Color gradientStart = Color(0xFF5F13C5);
  static const Color gradientEnd = Color(0xFFFF4C61);

  static const Color white = Colors.white;

  // Add a gold-like color for ratings, as seen in Blinkit
  static const Color ratingGold = Color(0xFFFFC107); // A standard amber/gold often used for stars

  // NEW COLOR ADDED HERE
  static const Color lightGreyBackground = Color(0xFFF0F0F0); // A subtle light grey for background elements or dividers
  static const Color accentOrange = Color(0xFFFF8C00); // A vibrant orange for highlights/discounts (based on the previous screenshot)
  static const Color info = Color(0xFF2196F3); // A standard blue for informational messages
}
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.neutralBackground,
      primaryColor: AppColors.primaryPurple,
      fontFamily: 'Gilroy', // Must match the family name in pubspec.yaml

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle( // AppBar title
          fontFamily: 'Gilroy',
          fontSize: 20,
          fontWeight: FontWeight.w800, // Use ExtraBold for app bar title
          color: AppColors.white,
        ),
      ),
      textTheme: const TextTheme(
        // DISPLAY TEXT: Use ExtraBold for highest impact titles
        displayLarge: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 32,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 28,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 24,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),

        // HEADLINE TEXT: Still quite prominent, use ExtraBold
        headlineLarge: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 22,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 18,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 16,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),

        // TITLE TEXT: For item names, product titles. Can be ExtraBold for emphasis or Light for softer look
        // I'm choosing ExtraBold here to maintain some hierarchy.
        titleLarge: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 18,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 16,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 14,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.textDark,
        ),

        // BODY TEXT: This is where we consistently use Gilroy Light for readability.
        bodyLarge: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 15,
          fontWeight: FontWeight.w300, // Light
          color: AppColors.textMedium,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 13,
          fontWeight: FontWeight.w300, // Light
          color: AppColors.textLight,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 11,
          fontWeight: FontWeight.w300, // Light
          color: AppColors.textLight,
        ),

        // LABEL TEXT: Buttons, tags, input labels. Buttons are usually prominent, so ExtraBold.
        labelLarge: TextStyle( // Buttons
          fontFamily: 'Gilroy',
          fontSize: 16,
          fontWeight: FontWeight.w800, // ExtraBold
          color: AppColors.white,
        ),
        labelMedium: TextStyle( // Input field labels, chips, filters
          fontFamily: 'Gilroy',
          fontSize: 14,
          fontWeight: FontWeight.w300, // Light
          color: AppColors.textMedium,
        ),
        labelSmall: TextStyle( // Very small labels, badges, timestamps
          fontFamily: 'Gilroy',
          fontSize: 10,
          fontWeight: FontWeight.w300, // Light
          color: AppColors.textLight,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w800, // ExtraBold for buttons
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Gilroy',
          color: AppColors.textLight,
          fontWeight: FontWeight.w300, // Light for hints
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Gilroy',
          color: AppColors.textMedium,
          fontWeight: FontWeight.w300, // Light for input labels
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentNeon,
        error: AppColors.danger,
        background: AppColors.neutralBackground,
      ),

      // --- ADDITIONS START HERE ---

      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryPurple; // Checked state
          }
          return AppColors.textLight; // Unchecked state (border color)
        }),
        checkColor: MaterialStateProperty.all(AppColors.white), // Color of the check mark
        splashRadius: 16, // Smaller splash radius for a cleaner look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Slightly rounded square
        ),
        side: BorderSide(
          color: AppColors.textLight, // Border color for unchecked
          width: 2,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryPurple; // Selected state
          }
          return AppColors.textLight; // Unselected state
        }),
        splashRadius: 16,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.white; // Thumb color when ON
          }
          return AppColors.white; // Thumb color when OFF
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryPurple.withOpacity(0.8); // Track color when ON
          }
          return AppColors.textLight.withOpacity(0.5); // Track color when OFF
        }),
        splashRadius: 16,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryPurple,
        inactiveTrackColor: AppColors.lightPurple.withOpacity(0.5),
        thumbColor: AppColors.primaryPurple,
        overlayColor: AppColors.primaryPurple.withOpacity(0.2), // Light overlay on tap
        valueIndicatorColor: AppColors.primaryPurple, // Color of the pop-up value indicator
        valueIndicatorTextStyle: const TextStyle(
          fontFamily: 'Gilroy', // Use Gilroy for the value indicator
          color: AppColors.white,
          fontWeight: FontWeight.w800, // ExtraBold for clear value
          fontSize: 14,
        ),
        // Customizing track and thumb shapes for a cleaner look
        trackHeight: 4.0, // Thinner track
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0), // Standard round thumb
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0), // Larger overlay for touch
      ),

      // --- ADDITIONS END HERE ---
    );
  }
}