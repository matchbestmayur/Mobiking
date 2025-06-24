import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If your AppTheme exclusively defines all text styles, you can remove this.
// Otherwise, if it uses GoogleFonts internally or for base styles, keep it.
// import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_theme.dart'; // Import your AppTheme

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

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
          'Refund Policy',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                textTheme,
                'Overview',
                'At Mobiking, we are committed to ensuring your satisfaction with our services and products. This Refund Policy outlines the conditions under which refunds may be issued.',
              ),
              const SizedBox(height: 24), // Consistent spacing between sections

              _buildSection(
                textTheme,
                'Eligibility for Refunds',
                'Refund requests must typically be made within 7 days of the purchase date. Eligibility criteria vary by product/service. Generally, refunds are applicable for unused services or products found to be defective upon delivery, provided the issue is reported promptly. Digital products, completed services, and promotional/discounted offers may have different refund rules as specified at the time of purchase.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Non-Refundable Items/Services',
                'Please note that certain items or services are explicitly non-refundable. These may include, but are not limited to, gift cards, subscriptions after initial use, specific perishable goods, or services where the full value has been utilized.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Refund Process',
                'To request a refund, please contact our support team with your order details and the reason for the refund. Once your request is received and reviewed, we will notify you of the approval or rejection. If approved, the refund will be processed to your original method of payment within 5-10 business days, depending on your bank or payment provider.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Partial Refunds',
                'In some cases, partial refunds may be granted for services that were partially used or products that are returned in a condition not suitable for full resale. This will be determined at our sole discretion.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Changes to this Policy',
                'We reserve the right to modify this Refund Policy at any time. Changes will be effective immediately upon posting to the app. Your continued use of the service after any such changes constitutes your acceptance of the new policy.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Contact Support',
                'If you have any questions about this Refund Policy or wish to initiate a refund request, please contact our support team directly at support@mobiking.com.', // Changed to your specific email
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