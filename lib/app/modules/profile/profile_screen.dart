import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/modules/address/AddressPage.dart';
import 'package:mobiking/app/modules/policy/cancellation_policy.dart';
import 'package:mobiking/app/modules/policy/refund_policy.dart';
import 'package:mobiking/app/modules/policy/terms_conditions.dart';
import 'package:mobiking/app/modules/profile/query/query_screen.dart';
import 'package:mobiking/app/modules/profile/wishlist/Aboout_screen.dart';
import 'package:mobiking/app/modules/profile/wishlist/Support_Screen.dart';
import 'package:mobiking/app/modules/profile/wishlist/Wish_list_screen.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/profile_reusable_widget.dart';
import '../orders/order_screen.dart' show OrderHistoryScreen;
import '../policy/logout_screen.dart'; // Assuming showLogoutDialog is defined here
import '../policy/privacy_policy.dart';
import '../../controllers/login_controller.dart'; // Import your LoginController

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get an instance of your LoginController
    final LoginController loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Info
              Text(
                'Your account',
                style: GoogleFonts.poppins(
                  fontSize: 18, // smaller & cleaner than before
                  fontWeight: FontWeight.w600, // semi-bold for emphasis
                  color: Colors.black87, // slightly softer than pure black
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Obx(() {
                    // 1. Get the current user data from the observable in the controller
                    final userMap = loginController.currentUser.value;

                    // 2. Initialize default display values
                    String displayText = 'N/A';
                    IconData displayIcon = Icons.person_outline; // Default generic icon if neither email nor phone is found

                    // 3. Check if user data exists
                    if (userMap != null) {
                      // 4. Safely extract email and phoneNumber from the userMap
                      final String? email = userMap['email'] as String?;
                      final String? phoneNumber = userMap['phoneNo'] as String?; // Key from your backend response

                      // 5. Apply the logic: Prefer email, then phone, else default
                      if (email?.isNotEmpty == true) { // If email exists and is not empty
                        displayText = email!; // Use email as text
                        displayIcon = Icons.email_outlined; // Use email icon
                      } else if (phoneNumber?.isNotEmpty == true) { // Else if phone number exists and is not empty
                        displayText = phoneNumber!; // Use phone number as text
                        displayIcon = Icons.phone_outlined; // Use phone icon
                      }
                    }

                    // 6. Return the Row with the dynamically chosen icon and text
                    return Row(
                      children: [
                        Icon(displayIcon), // Display the chosen icon based on the logic
                        const SizedBox(width: 8),
                        Text(
                          displayText, // Display the chosen text based on the logic
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Top 3 Boxes (unchanged)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoBox(icon: Icons.headset_mic_outlined, title: 'Support',
                    onPressed: (){
                      showSupportDialog(context);
                    },),
                  InfoBox(icon: Icons.payment_outlined, title: 'Payment'
                      ,onPressed: (){
                        /*Get.back();*/
                      }),
                  InfoBox(icon: Icons.info_outline, title: 'About Us'
                      , onPressed: (){
                        showAboutUsDialog(context);
                      }
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Text(
                'YOUR INFORMATION',
                style: GoogleFonts.poppins(
                  fontSize: 12, // smaller, subtle header
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2, // add spacing for neatness
                ),
              ),

              const SizedBox(height: 16),

           /*   // Info List (added navigation to OrderHistoryScreen for 'Your orders')
              ProfileListTile(
                icon: Icons.receipt_long,
                title: 'Your orders',
                onTap: () {
                  Get.to(
                    OrderHistoryScreen(), // Navigate to OrderHistoryScreen
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),*/
              ProfileListTile(
                icon: Icons.message_outlined,
                title: 'Query',
                onTap: () {
                  Get.to(
                    QueriesScreen(),
                    transition: Transition.rightToLeftWithFade, // or use Transition.rightToLeft
                    duration: const Duration(milliseconds: 300), // optional for smoothness
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.favorite_border_outlined,
                title: 'Wishlist',
                onTap: () {
                  Get.to(
                    WishlistScreen(), // 🔁 Replace with your screen
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.location_on_outlined,
                title: 'Delivery Address',
                onTap: () {
                  // Navigate to the address screen (replace with your actual screen)
                  Get.to(
                    AddressPage(), // 🔁 Replace with your screen
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),

              ProfileListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Get.to(
                    const PrivacyPolicyScreen(),
                    transition: Transition.rightToLeftWithFade, // or use Transition.rightToLeft
                    duration: const Duration(milliseconds: 300), // optional for smoothness
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.article_outlined,
                title: 'Terms & Conditions',
                onTap: () {
                  Get.to(
                    const TermsAndConditionsScreen(),
                    transition: Transition.rightToLeftWithFade, // or use Transition.rightToLeft
                    duration: const Duration(milliseconds: 300), // optional for smoothness
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.cancel_outlined,
                title: 'Cancellation Policy',
                onTap: (){
                  Get.to(
                    const CancellationPolicyScreen(),
                    transition: Transition.rightToLeftWithFade, // or use Transition.rightToLeft
                    duration: const Duration(milliseconds: 300), // optional for smoothness
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.money_off_csred_outlined,
                title: 'Refund Policy',
                onTap: (){
                  Get.to(
                    const RefundPolicyScreen(),
                    transition: Transition.rightToLeftWithFade, // or use Transition.rightToLeft
                    duration: const Duration(milliseconds: 300), // optional for smoothness
                  );
                },
              ),
              ProfileListTile(
                icon: Icons.share_outlined,
                title: 'Share The App',
                onTap: () {
                  Share.share(
                    'Hey! Check out this awesome app: https://play.google.com/store/apps/details?id=com.yourcompany.yourapp',
                    subject: 'Download this amazing app!',
                  );
                },
              ),

              const SizedBox(height: 10),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    loginController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}