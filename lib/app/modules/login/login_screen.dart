import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/login_controller.dart';
import 'package:mobiking/app/modules/opt/Otp_screen.dart';

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
                    
                    
                    
                    image: AssetImage('assets/images/img.png'),
                    fit: BoxFit.fill, 
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            
            Text(
              "Mobiking Wholesale",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            
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
                  focusedBorder: OutlineInputBorder( 
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder( 
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              
              child: Obx(
                    () => SizedBox( 
                  width: double.infinity, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14), 
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16, 
                      ),
                      elevation: 4, 
                    ),
                    onPressed: loginController.isLoading.value
                        ? null 
                        : () async { 
                      await loginController.login(); 
                      
                      
                      Get.to(() => OtpVerificationScreen(phoneNumber: loginController.phoneController.text));
                    },
                    child: loginController.isLoading.value
                        ? const SizedBox( 
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3, 
                      ),
                    )
                        : Text(
                      'Login with Mobile',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), 
          ],
        ),
      ),
    );
  }
}