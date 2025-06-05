import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_theme.dart';


class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        automaticallyImplyLeading: false,
        title: Text(
          'Refund Policy',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.darkPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We strive to ensure your satisfaction with our app. If you are not completely satisfied, you may be eligible for a refund under certain conditions.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Eligibility for Refunds',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'To be eligible for a refund, the request must be made within 7 days of the purchase date. Refunds are only applicable for unused or defective services.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Non-Refundable Items',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Certain items or services are non-refundable, including digital goods, completed services, and promotional offers.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Refund Process',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Once your refund request is received and reviewed, we will notify you of the approval or rejection. If approved, the refund will be processed to your original payment method within a few days.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Contact Support',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If you have any questions or wish to request a refund, please contact our support team at support@example.com.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 80), // ensure enough space for scroll
            ],
          ),
        ),
      ),
    );
  }
}
