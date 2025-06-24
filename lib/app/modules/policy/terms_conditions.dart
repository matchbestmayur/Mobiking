import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If your AppTheme exclusively defines all text styles, you can remove this.
// Otherwise, if it uses GoogleFonts internally or for base styles, keep it.
// import 'package:google_fonts/google_fonts.dart';

import '../../themes/app_theme.dart'; // Import your AppTheme

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
          'Terms & Conditions',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700, // Bolder title
            color: AppColors.textDark, // Dark text for AppBar title
          ),
        ),
        backgroundColor: AppColors.white, // White AppBar background
        elevation: 0.5, // Subtle shadow for AppBar
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                textTheme,
                'Welcome',
                'These Terms & Conditions govern your use of our app. By using our app, you agree to these terms in full.',
              ),
              const SizedBox(height: 24), // Consistent spacing between sections

              _buildSection(
                textTheme,
                'User Accounts',
                'When you create an account with us, you must provide us with information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Intellectual Property',
                'The Service and its original content, features, and functionality are and will remain the exclusive property of Mobiking and its licensors. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of Mobiking.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'User Responsibilities',
                'You agree to use the app only for lawful purposes and not to infringe the rights of others or restrict their usage. This includes refraining from engaging in any unlawful, fraudulent, or harmful activities.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Limitation of Liability',
                'In no event shall Mobiking, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Changes to Terms',
                'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Governing Law',
                'These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Contact Us',
                'If you have any questions about these Terms & Conditions, please contact us at support@mobiking.com.', // Changed to your specific email
              ),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for a section (heading + paragraph)
  Widget _buildSection(TextTheme textTheme, String heading, String paragraph) {
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