// lib/screens/faq_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../themes/app_theme.dart'; // Ensure this path is correct

class FaqDialog extends StatelessWidget {
  final TextEditingController queryController;

  const FaqDialog({super.key, required this.queryController});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the dialog
      ),
      elevation: 10.0,
      backgroundColor: AppColors.neutralBackground, // Light background for the dialog itself
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Common Questions about Returns & Defects',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Returns Policy Section
                  Text(
                    'Returns Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildQuestionList(
                    context,
                    queryController,
                    [
                      'What is your return policy for wholesale orders?',
                      'How long do I have to return a product?',
                      'What are the conditions for a product to be eligible for return?',
                      'Do I need a Return Merchandise Authorization (RMA) number?',
                      'Who pays for return shipping?',
                      'How long does it take to process a refund or replacement for a returned item?',
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // Defect & Warranty Section
                  Text(
                    'Defect & Warranty',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildQuestionList(
                    context,
                    queryController,
                    [
                      'What is your warranty policy for defective products?',
                      'How do I report a defective product?',
                      'What information do I need to provide for a defect claim?',
                      'Will I receive a replacement or a repair for a defective item?',
                      'Are there any products not covered by warranty?',
                      'What is the process for sending back a defective unit for inspection?',
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24.0),
                color: AppColors.textLight, // Use a light text color for the close icon
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

  // Helper function to build a list of query suggestions
  Widget _buildQuestionList(BuildContext context, TextEditingController controller, List<String> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: questions.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: AppColors.lightPurple.withOpacity(0.1), // Light, translucent background
            borderRadius: BorderRadius.circular(10.0), // Slightly rounded corners
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                controller.text = question;
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Query field updated!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)), // Subtle border
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    fontSize: 15.0,
                    color: AppColors.textDark, // Dark text for readability
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
