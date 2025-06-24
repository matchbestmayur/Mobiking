import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If your AppTheme exclusively defines all text styles, you can remove this.
// Otherwise, if it uses GoogleFonts internally or for base styles, keep it.
// import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_theme.dart'; // Import your AppTheme

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

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
          'Cancellation Policy',
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
                'This Cancellation Policy outlines the conditions under which you can cancel your services or orders made through our app. Please read it carefully before proceeding with any transactions.',
              ),
              const SizedBox(height: 24), // Consistent spacing between sections

              _buildSection(
                textTheme,
                'Cancellation Timeframes & Eligibility',
                'Eligibility for cancellation depends on the type of service or product and the time elapsed since the order was placed. Generally, orders can be cancelled without charge within a specific window (e.g., 15-30 minutes for quick deliveries, or before dispatch for scheduled services). Refer to specific product/service details for exact terms.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'How to Cancel an Order',
                'To cancel an eligible order, navigate to the “My Orders” or “Active Services” section within the app. Select the order you wish to cancel and follow the prompts. If direct cancellation is not available, please contact our customer support immediately.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Cancellation Charges & Refunds',
                'Some cancellations, especially those made after the specified free cancellation window or for custom/perishable items, may be subject to a cancellation fee or may not be eligible for a full refund. Any applicable charges will be clearly communicated during the cancellation process. Refunds, if eligible, will be processed as per our Refund Policy, typically within 5-7 business days.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Force Majeure',
                'We reserve the right to cancel any order due to unforeseen circumstances, including but not limited to, natural disasters, strikes, technical issues, or unavailability of products/services. In such cases, a full refund will be initiated.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Changes to this Policy',
                'We may update this Cancellation Policy periodically. Any changes will be posted on this page and will become effective immediately upon posting. Your continued use of the service after such modifications constitutes your acceptance of the new policy.',
              ),
              const SizedBox(height: 24),

              _buildSection(
                textTheme,
                'Contact Us',
                'For any assistance with cancellations or queries regarding this policy, please contact our dedicated support team at support@mobiking.com.', // Changed to your specific email
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