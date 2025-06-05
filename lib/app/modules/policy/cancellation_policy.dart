import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_theme.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

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
          'Cancellation Policy',
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
                'This Cancellation Policy outlines the conditions under which you can cancel your services or orders made through our app.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Cancellation Timeframe',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You may cancel your order or subscription within 24 hours of placing it. After this period, cancellations may not be accepted.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'How to Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'To cancel your order, navigate to the “My Orders” or “Subscriptions” section in the app and follow the cancellation steps.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Cancellation Charges',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Some cancellations may be subject to a small fee to cover processing costs, depending on the service or product.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Refunds After Cancellation',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If your cancellation qualifies for a refund, it will be processed as per our Refund Policy.',
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
                'If you need help with cancellations, please contact our support team at support@example.com.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 80), // To ensure space at bottom
            ],
          ),
        ),
      ),
    );
  }
}
