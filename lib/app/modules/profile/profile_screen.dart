import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/modules/address/AddressPage.dart';
import 'package:mobiking/app/modules/policy/cancellation_policy.dart';
import 'package:mobiking/app/modules/policy/refund_policy.dart';
import 'package:mobiking/app/modules/policy/terms_conditions.dart';
import 'package:mobiking/app/modules/profile/wishlist/Wish_list_screen.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/profile_reusable_widget.dart';
import '../policy/logout_screen.dart';
import '../policy/privacy_policy.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
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
                  const Icon(Icons.email_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'xyz0111@gmail.com',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, // medium weight
                      fontSize: 14, // smaller font size for subtlety
                      decoration: TextDecoration.underline,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top 3 Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoBox(icon: Icons.headset_mic_outlined, title: 'Support',
                    onPressed: (){
                    Get.back();
                  },),
                  InfoBox(icon: Icons.payment_outlined, title: 'Payment'
                  ,onPressed: (){
                        Get.back();
                      }),
                   InfoBox(icon: Icons.info_outline, title: 'About Us'
                      , onPressed: (){
        Get.back();
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

              // Info List
              ProfileListTile(
                icon: Icons.receipt_long,
                title: 'Your orders',
                onTap: (){},
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
                    showLogoutDialog(context);
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
