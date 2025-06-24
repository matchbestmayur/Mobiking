// lib/widgets/raise_query_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/query_getx_controller.dart';
import '../../../themes/app_theme.dart'; // Import AppColors and AppTheme

class RaiseQueryDialog extends StatefulWidget {
  // The onAddQuery callback is no longer needed here as the dialog directly
  // interacts with the QueryGetXController to submit the query.
  const RaiseQueryDialog({super.key});

  @override
  State<RaiseQueryDialog> createState() => _RaiseQueryDialogState();
}

class _RaiseQueryDialogState extends State<RaiseQueryDialog> {
  // Text editing controllers for the title and message input fields.
  // These controllers are used to read the current text entered by the user.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // A GlobalKey is used to access the FormState of the Form widget.
  // This allows us to call methods like validate() on the form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Get the instance of your QueryGetXController.
  // This assumes that the QueryGetXController has been registered
  // with GetX's dependency injection (e.g., using Get.put() in main.dart or a binding).
  final QueryGetXController queryController = Get.find<QueryGetXController>();

  @override
  void dispose() {
    // It's crucial to dispose of TextEditingControllers when the widget
    // is removed from the widget tree to prevent memory leaks.
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// This method is called when the "Submit Query" button is pressed.
  /// It first validates the form input and then delegates the query submission
  /// logic to the QueryGetXController.
  Future<void> _submitQuery() async {
    // Validate the form. If all validators return null, the form is valid.
    if (_formKey.currentState?.validate() ?? false) {
      // Added a print statement to confirm _submitQuery is being called
      print('RaiseQueryDialog: _submitQuery called. Attempting to raise query...');

      // Call the raiseQuery method from the QueryGetXController.
      // This method handles the API call, updates the state, and shows snackbars.
      await queryController.raiseQuery(
        title: _titleController.text.trim(),   // Get trimmed text from title field
        message: _messageController.text.trim(), // Get trimmed text from message field
      );

      // After the query has been submitted (and the controller has provided feedback),
      // close the dialog using GetX's navigation system.
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the current TextTheme from the application's theme.
    // This ensures consistent typography across the app based on your AppTheme.
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // Adding a GestureDetector allows us to dismiss the keyboard
      // when the user taps outside of any text input fields within the dialog.
      onTap: () {
        FocusScope.of(context).unfocus(); // Request focus to be removed from any focused widget
      },
      child: AlertDialog(
        backgroundColor: AppColors.white, // Set dialog background color using AppColors
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Apply rounded corners to the dialog
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0), // Custom padding for the title
        title: Text(
          'Raise a Query',
          textAlign: TextAlign.center,
          // Apply text style using the theme's headlineSmall, with overrides for specific properties.
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 24, // Explicit font size for the title
            fontWeight: FontWeight.bold, // Bold font weight
            color: AppColors.darkPurple, // Specific title color from AppColors
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Consistent horizontal padding for content
        content: Form(
          key: _formKey, // Associate the GlobalKey with the Form
          child: SingleChildScrollView( // Allows content to scroll if it overflows
            child: Column(
              mainAxisSize: MainAxisSize.min, // Column takes minimum space needed vertically
              children: [
                // Text input field for the query title
                TextFormField(
                  controller: _titleController, // Link to the title controller
                  cursorColor: AppColors.primaryPurple, // Custom cursor color
                  decoration: InputDecoration(
                    labelText: 'Query Title', // Label for the input field
                    hintText: 'e.g., Issue with delivery of order #12345', // Hint text
                    // Styling for label and hint text using theme's styles and AppColors.
                    labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.textLight.withOpacity(0.9), fontSize: 15),
                    hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textLight.withOpacity(0.6), fontSize: 15),
                    // Define various border states for the input field.
                    border: OutlineInputBorder( // Default border
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder( // Border when enabled but not focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightPurple.withOpacity(0.7), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder( // Border when focused
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryPurple, width: 2), // Highlight with primary color
                    ),
                    errorBorder: OutlineInputBorder( // Border when an error occurs
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.danger, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder( // Border when focused with an error
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.danger, width: 2),
                    ),
                    filled: true, // Fill the background of the input field
                    fillColor: AppColors.neutralBackground, // Background fill color
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Internal padding
                  ),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textDark, fontSize: 16), // Input text style
                  validator: (value) {
                    // Validator function for input validation.
                    if (value == null || value.trim().isEmpty) {
                      return 'Title cannot be empty.'; // Error message if invalid
                    }
                    return null; // No error
                  },
                ),
                const SizedBox(height: 20.0), // Spacing between input fields
                // Text input field for the detailed message
                TextFormField(
                  controller: _messageController, // Link to the message controller
                  cursorColor: AppColors.primaryPurple, // Custom cursor color
                  decoration: InputDecoration(
                    labelText: 'Detailed Message',
                    hintText: 'Please describe your query in detail, including any relevant dates or order numbers.',
                    labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.textLight.withOpacity(0.9), fontSize: 15),
                    hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textLight.withOpacity(0.6), fontSize: 15),
                    alignLabelWithHint: true, // Aligns label to top for multiline input
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
                    fillColor: AppColors.neutralBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textDark, fontSize: 16),
                  maxLines: 7, // Allow up to 7 lines of input
                  minLines: 4, // Ensure a minimum height of 4 lines
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
        actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24), // Padding for action buttons
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog without submitting
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textLight, // Text color for the button
              textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Match input field radius
              ),
            ),
            child: const Text('Cancel'),
          ),
          // Submit Query button
          ElevatedButton(
            // onPressed callback.
            // It checks queryController.isLoading to prevent multiple submissions
            // while a query is already being processed.
            onPressed: () {
              if (!queryController.isLoading) { // Access value property for RxBool
                _submitQuery(); // Call the local method to handle form validation and controller interaction
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPurple, // Background color of the button
              foregroundColor: AppColors.white, // Text color of the button
              textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Match input field border radius
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              elevation: 6, // Add a slight shadow for a lifted effect
            ),
            // Obx widget makes the child reactive to changes in queryController.isLoading.
            // When isLoading is true, a CircularProgressIndicator is shown; otherwise, "Submit Query" text.
            child: Obx(
                  () => queryController.isLoading // Access value property for RxBool
                  ? const SizedBox(
                height: 20, // Size of the loading indicator
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white, // Color of the loading indicator
                  strokeWidth: 2, // Thickness of the loading indicator line
                ),
              )
                  : const Text('Submit Query'), // Default text when not loading
            ),
          ),
        ],
      ),
    );
  }
}
