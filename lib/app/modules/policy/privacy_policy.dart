import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.darkPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading('Introduction'),
            _buildParagraph(
              'We are committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and safeguard your personal data when using our services.',
            ),
            const SizedBox(height: 24),
            _buildHeading('Information Collection'),
            _buildParagraph(
              'We may collect information such as your name, email address, and usage behavior to improve our services.',
            ),
            const SizedBox(height: 24),
            _buildHeading('Use of Information'),
            _buildParagraph(
              'The collected information is used solely for improving user experience, providing support, and ensuring better service delivery.',
            ),
            const SizedBox(height: 24),
            _buildHeading('Contact Us'),
            _buildParagraph(
              'If you have any questions regarding this privacy policy, feel free to contact us at support@example.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: AppColors.textLight,
          height: 1.6,
        ),
      ),
    );
  }
}
