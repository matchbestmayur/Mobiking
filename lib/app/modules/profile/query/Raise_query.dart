// lib/widgets/raise_query_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../themes/app_theme.dart'; // Import AppColors

class RaiseQueryDialog extends StatefulWidget {
  final Function(String title, String message) onAddQuery;

  const RaiseQueryDialog({super.key, required this.onAddQuery});

  @override
  State<RaiseQueryDialog> createState() => _RaiseQueryDialogState();
}

class _RaiseQueryDialogState extends State<RaiseQueryDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Keep dialog background white for crisp contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Slightly more rounded dialog corners
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0), // More vertical padding for title
      title: Text(
        'Raise a Query',
        style: GoogleFonts.poppins(
          fontSize: 24, // Larger, more prominent title
          fontWeight: FontWeight.bold,
          color: AppColors.darkPurple, // Use darkPurple for a strong, branded title
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Consistent horizontal content padding
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                cursorColor: AppColors.primaryPurple, // Themed cursor color
                decoration: InputDecoration(
                  labelText: 'Query Title', // More descriptive label
                  hintText: 'e.g., Issue with delivery of order #12345', // More specific hint
                  labelStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.9), fontSize: 15), // Slightly larger label text
                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.6), fontSize: 15), // Consistent hint size
                  border: OutlineInputBorder( // Explicit border for text fields
                    borderRadius: BorderRadius.circular(12), // Slightly more rounded input fields
                    borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0), // Finer border
                  ),
                  enabledBorder: OutlineInputBorder( // Define enabled border
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightPurple.withOpacity(0.7), width: 1.0), // Softer enabled border
                  ),
                  focusedBorder: OutlineInputBorder( // Highlight on focus
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryPurple, width: 2), // Primary color on focus, slightly thicker
                  ),
                  errorBorder: OutlineInputBorder( // Error state border
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.danger, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder( // Focused error state
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.danger, width: 2),
                  ),
                  filled: true, // Fill the background
                  fillColor: Colors.grey.shade50, // Light gray fill color for subtle contrast
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Generous padding
                ),
                style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 16), // Clear input text
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty.'; // More user-friendly message
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Consistent spacing
              TextFormField(
                controller: _messageController,
                cursorColor: AppColors.primaryPurple, // Themed cursor color
                decoration: InputDecoration(
                  labelText: 'Detailed Message', // More descriptive label
                  hintText: 'Please describe your query in detail, including any relevant dates or order numbers.', // More helpful hint
                  labelStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.9), fontSize: 15),
                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.6), fontSize: 15),
                  alignLabelWithHint: true, // Align label to top for multi-line
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightPurple.withOpacity(0.7), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.danger, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.danger, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Generous padding
                ),
                style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 16),
                maxLines: 7, // Allow more lines for detailed messages
                minLines: 4, // Ensure a minimum height
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message cannot be empty.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24), // Consistent horizontal padding, more vertical for actions
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textLight, // More subtle cancel text
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15), // Slightly smaller, less bold
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), // Add padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Match input field radius
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onAddQuery(_titleController.text.trim(), _messageController.text.trim());
              Get.back(); // Close dialog after successful submission
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPurple, // Dark purple submit button
            foregroundColor: Colors.white, // White text
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16), // Stronger text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Match input field border radius
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Generous padding for a prominent button
            elevation: 6, // Increased elevation for a clearer "lifted" effect
          ),
          child: const Text('Submit Query'),
        ),
      ],
    );
  }
}