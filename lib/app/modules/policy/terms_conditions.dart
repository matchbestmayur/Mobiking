import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../themes/app_theme.dart';


class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        automaticallyImplyLeading: false,
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.darkPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'These Terms & Conditions govern your use of our app. By using our app, you agree to these terms in full.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
        
              Text(
                'User Responsibilities',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You agree to use the app only for lawful purposes and not to infringe the rights of others or restrict their usage.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
        
              Text(
                'Limitation of Liability',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We are not liable for any loss or damage arising from the use or inability to use the app.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
        
              Text(
                'Changes to Terms',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We may update our Terms & Conditions from time to time. Continued use of the app means you accept the changes.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
        
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If you have any questions about these terms, contact us at support@example.com.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
