// lib/app/controllers/system_ui_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Ensure AppColors is accessible

class SystemUiController extends GetxController {
  // Use a Rx for the current system UI style that other parts of the app can request
  // Initialize with a default style (e.g., the MainContainerScreen's default)
  final Rx<SystemUiOverlayStyle> currentUiStyle = Rx<SystemUiOverlayStyle>(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Default for most screens
      systemNavigationBarColor: AppColors.white, // Default from your Blinkit bottom bar
      systemNavigationBarIconBrightness: Brightness.dark, // Icons visible on white
    ),
  );

  // Method to update the full system UI style
  void setSystemUiStyle(SystemUiOverlayStyle style) {
    currentUiStyle.value = style; // Update the observable
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  // New method to update only the status bar brightness
  void setStatusBarBrightness(Brightness brightness) {
    final newStyle = currentUiStyle.value.copyWith(statusBarIconBrightness: brightness);
    setSystemUiStyle(newStyle); // Apply the new style
  }

  // Define common UI styles for reuse
  // These are now base styles, and statusBarIconBrightness can be overridden
  static const SystemUiOverlayStyle defaultStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Default, will be overridden by BottomNavController
    systemNavigationBarColor: AppColors.white, // Matches your Blinkit bottom bar
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkNavBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Example: for a screen with a very dark header
    systemNavigationBarColor: AppColors.darkPurple, // Example dark color
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle authScreenStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // PhoneAuthScreen uses this
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}