// lib/screens/about_us_dialog.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // No longer needed directly
import '../../../themes/app_theme.dart'; // Ensure this path is correct

class AboutUsDialog extends StatelessWidget {
  const AboutUsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the TextTheme from the current theme
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the dialog
      ),
      elevation: 10.0,
      backgroundColor: AppColors.neutralBackground, // Light background for the dialog
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 450), // Set max size
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'About Mobiking Wholesale',
                    textAlign: TextAlign.center,
                    // Use headlineSmall and override font size/weight if needed
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 24.0, // Adjust if AppTheme's headlineSmall is different
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Mobiking is a leading wholesale distributor of high-quality electronics, specializing in mobile accessories, smart devices, computer peripherals, and more. We partner with businesses to provide competitive pricing, reliable supply chains, and exceptional customer service.',
                    // Use bodyLarge and override height
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16.0, // Adjust if AppTheme's bodyLarge is different
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Our Mission:',
                    textAlign: TextAlign.center,
                    // Use titleMedium and override font size/weight
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18.0, // Adjust if AppTheme's titleMedium is different
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'To empower businesses with top-tier electronic products and seamless wholesale solutions.',
                    // Use bodyMedium and override font size/style
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 15.0, // Adjust if AppTheme's bodyMedium is different
                      color: AppColors.textDark,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Contact Information:',
                    // Use titleMedium and override font size/weight
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18.0, // Adjust if AppTheme's titleMedium is different
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                    title: Text(
                      'sales@mobikingwholesale.com',
                      // Use bodyMedium for list item text
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 15.0, // Adjust if AppTheme's bodyMedium is different
                        color: AppColors.textDark,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_outlined, color: AppColors.primaryPurple),
                    title: Text(
                      '+91 123 456 7890',
                      // Use bodyMedium for list item text
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 15.0, // Adjust if AppTheme's bodyMedium is different
                        color: AppColors.textDark,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24.0),
                color: AppColors.textLight,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}