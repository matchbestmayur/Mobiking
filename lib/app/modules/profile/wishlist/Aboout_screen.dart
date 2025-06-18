import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobiking/app/themes/app_theme.dart'; // Your app's theme colors

void showAboutUsDialog(BuildContext context) {
  final String appVersion = '1.0.0'; // Replace with your actual app version

  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'About Mobiking Wholesale',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      content: Column( // Removed SingleChildScrollView as content is minimal
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your App Logo
          Image.asset(
            'assets/images/img.png', // Or 'assets/images/app_logo.png'
            height: 80,
            width: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Your trusted partner for wholesale mobile phone distribution.', // Concise description
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Version: $appVersion',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: Text(
            'Close',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center, // Center the close button
    ),
  );
}