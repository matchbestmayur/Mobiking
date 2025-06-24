import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If your AppTheme exclusively defines all text styles, you can remove this.
// Otherwise, if it uses GoogleFonts internally or for base styles, keep it.
// import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppTheme

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme; // Get TextTheme

    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Consistent Blinkit-like background
      appBar: AppBar(
        leading: IconButton( // Use IconButton for standard back arrow styling
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark)), // Dark back arrow
        automaticallyImplyLeading: false,
        title: Text(
          'Privacy Policy',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700, // Bolder title
            color: AppColors.textDark, // Dark text for AppBar title
          ),
        ),
        backgroundColor: AppColors.white, // White AppBar background
        elevation: 0.5, // Subtle shadow for AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              textTheme,
              'Introduction',
              'We are committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and safeguard your personal data when using our services.',
            ),
            const SizedBox(height: 24), // Consistent spacing between sections
            _buildSection(
              context,
              textTheme,
              'Information Collection',
              'We may collect information such as your name, email address, and usage behavior to improve our services and personalize your experience.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              textTheme,
              'Use of Information',
              'The collected information is primarily used for improving user experience, providing customer support, processing transactions, and delivering a more tailored service. We do not sell or rent your personal data to third parties.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              textTheme,
              'Data Security',
              'We implement a variety of security measures to maintain the safety of your personal information when you place an order or enter, submit, or access your personal information. However, no method of transmission over the Internet or method of electronic storage is 100% secure.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              textTheme,
              'Changes to this Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              textTheme,
              'Contact Us',
              'If you have any questions regarding this Privacy Policy, please feel free to contact our support team at support@mobiking.com.', // Changed to a more specific email
            ),
            const SizedBox(height: 16), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // Combined helper method for a section (heading + paragraph)
  Widget _buildSection(BuildContext context, TextTheme textTheme, String heading, String paragraph) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: textTheme.headlineSmall?.copyWith( // Use headlineSmall for prominent headings
            fontWeight: FontWeight.w700, // Bolder for section titles
            color: AppColors.textDark, // Dark text for headings
          ),
        ),
        const SizedBox(height: 10), // Space between heading and paragraph
        Text(
          paragraph,
          style: textTheme.bodyLarge?.copyWith( // Use bodyLarge for main paragraph text
            color: AppColors.textMedium, // Slightly darker grey for readability
            height: 1.6, // Good line spacing
          ),
          textAlign: TextAlign.justify, // Justify text for a more formal look
        ),
      ],
    );
  }
}