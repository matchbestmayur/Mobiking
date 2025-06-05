import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/login_controller.dart';
import 'package:mobiking/app/modules/opt/Otp_screen.dart';
import 'package:mobiking/app/services/login_service.dart';
import 'package:mobiking/app/themes/app_theme.dart';

class PhoneAuthScreen extends StatelessWidget {
  PhoneAuthScreen({Key? key}) : super(key: key);

  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Grid
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                height: 360,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.textDark,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://img.freepik.com/free-vector/realistic-cyber-monday-sale-banner_52683-142053.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // App Name
            Text(
              "Mobiking Wholesale",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            // Phone Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextFormField(
                controller: loginController.phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your mobile number',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Login Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  onPressed: loginController.isLoading.value
                      ? null // Disable the button while loading
                      : () {
                          // Call the login method from the controller
                          loginController.login();
                          Get.to(OtpVerificationScreen(phoneNumber: loginController.phoneController.text));
                        },
                  child: loginController.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Login with Mobile',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
