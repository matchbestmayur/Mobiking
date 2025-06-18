// user_info_dialog_content.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';

import '../../../themes/app_theme.dart'; // Make sure to import GetStorage


class UserInfoDialogContent extends StatefulWidget {
  final Map<String, dynamic> initialUser;

  const UserInfoDialogContent({Key? key, required this.initialUser}) : super(key: key);

  @override
  _UserInfoDialogContentState createState() => _UserInfoDialogContentState();
}

class _UserInfoDialogContentState extends State<UserInfoDialogContent> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late RxString _orderFor; // Reactive for UI updates
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GetStorage _box = GetStorage(); // Access GetStorage here or pass it

  @override
  void initState() {
    super.initState();
    _orderFor = (widget.initialUser['orderFor'] as String? ?? 'Self').obs;

    _nameController = TextEditingController(
      text: _orderFor.value == 'Self' ? (widget.initialUser['name'] ?? '') : '',
    );
    _phoneController = TextEditingController(
      text: widget.initialUser['phoneNo'] ?? widget.initialUser['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialUser['email'] ?? '',
    );

    // Add listener to update name/phone/email when orderFor changes
    _orderFor.listen((value) {
      if (value == 'Self') {
        _nameController.text = widget.initialUser['name'] ?? '';
        _phoneController.text = widget.initialUser['phoneNo'] ?? widget.initialUser['phone'] ?? '';
        _emailController.text = widget.initialUser['email'] ?? '';
      } else {
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _orderFor.close(); // Dispose RxString as well
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: BoxDecoration(
          color: AppColors.neutralBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
                child: Text(
                  "Confirm Your Details",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                  height: 10,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.lightPurple),
              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Obx(() { // Obx still needed for _orderFor reactivity
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Is this order for yourself or for someone else?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Self/Other Radio Button Section
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.neutralBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.lightPurple, width: 1.0),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_orderFor.value != 'Self') {
                                          _orderFor.value = 'Self';
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: _orderFor.value == 'Self'
                                              ? AppColors.primaryPurple.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Radio<String>(
                                              value: 'Self',
                                              groupValue: _orderFor.value,
                                              onChanged: (String? value) {
                                                if (value != null) {
                                                  _orderFor.value = value;
                                                }
                                              },
                                              activeColor: AppColors.primaryPurple,
                                              materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            Text(
                                              "Self",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _orderFor.value == 'Self'
                                                    ? AppColors.primaryPurple
                                                    : AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                      color: AppColors.lightPurple.withOpacity(0.7),
                                      thickness: 1,
                                      width: 1),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_orderFor.value != 'Other') {
                                          _orderFor.value = 'Other';
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: _orderFor.value == 'Other'
                                              ? AppColors.primaryPurple.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Radio<String>(
                                              value: 'Other',
                                              groupValue: _orderFor.value,
                                              onChanged: (String? value) {
                                                if (value != null) {
                                                  _orderFor.value = value;
                                                }
                                              },
                                              activeColor: AppColors.primaryPurple,
                                              materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            Text(
                                              "Other",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _orderFor.value == 'Other'
                                                    ? AppColors.primaryPurple
                                                    : AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: AppColors.textDark),
                            decoration: InputDecoration(
                              labelText: _orderFor.value == 'Self'
                                  ? "Your Name"
                                  : "Recipient's Name",
                              hintText: _orderFor.value == 'Self'
                                  ? "Your full name"
                                  : "e.g., Jane Doe",
                              labelStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500),
                              hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.person_outline_rounded,
                                  color: AppColors.primaryPurple),
                              filled: true,
                              fillColor: AppColors.neutralBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.lightPurple, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primaryPurple, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),

                          const SizedBox(height: 20),

                          // Phone Number Field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: AppColors.textDark),
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              hintText: "e.g., 9876543210",
                              labelStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500),
                              hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.phone_outlined,
                                  color: AppColors.primaryPurple),
                              filled: true,
                              fillColor: AppColors.neutralBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.lightPurple, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primaryPurple, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.trim().length < 10) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),

                          const SizedBox(height: 20),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: AppColors.textDark),
                            decoration: InputDecoration(
                              labelText: "Email (Optional)",
                              hintText: "e.g., example@domain.com",
                              labelStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500),
                              hintStyle: GoogleFonts.poppins(
                                  color: AppColors.textLight.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: AppColors.primaryPurple),
                              filled: true,
                              fillColor: AppColors.neutralBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.lightPurple, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primaryPurple, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.danger, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !GetUtils.isEmail(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Use the FormState to validate all fields
                          if (_formKey.currentState?.validate() ?? false) {
                            // If all validations pass, save data and close dialog with 'true'
                            final updatedUser = {
                              ...widget.initialUser, // Use initialUser from widget
                              'name': _nameController.text.trim(),
                              'phoneNo': _phoneController.text.trim(),
                              'phone': _phoneController.text.trim(), // Keep both for safety
                              'email': _emailController.text.trim(),
                              'orderFor': _orderFor.value,
                            };
                            _box.write('user', updatedUser);
                            Get.back(result: true); // Close the dialog and pass true
                          } else {
                            // If validation fails, show a general error message
                            _showModernSnackbar(
                              'Validation Error',
                              'Please correct the errors in the form.',
                              icon: Icons.error_outline,
                              backgroundColor: AppColors.danger,
                              isError: true,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          "Save & Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Get.back(result: false); // Close the dialog and pass false
                      },
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Assuming _showModernSnackbar is a top-level function or in a utility class
void _showModernSnackbar(
    String title,
    String message, {
      IconData? icon,
      Color? backgroundColor,
      Color? colorText,
      bool isError = false,
      SnackPosition snackPosition = SnackPosition.BOTTOM,
    }) {
  Get.snackbar(
    title,
    message,
    icon: icon != null ? Icon(icon, color: colorText ?? Colors.white) : null,
    backgroundColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
    colorText: colorText ?? Colors.white,
    snackPosition: snackPosition,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(seconds: 3),
  );
}