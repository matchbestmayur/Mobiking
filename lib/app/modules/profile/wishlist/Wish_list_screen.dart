import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Ensure you have Get imported correctly
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Your AppColors and AppTheme

import '../../../controllers/wishlist_controller.dart';
import 'Wish_list_card.dart'; // Assuming this widget will be styled similarly

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final controller = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Consistent background
      appBar: AppBar(
        elevation: 1, // Subtle elevation for professionalism
        backgroundColor: AppColors.primaryPurple, // Consistent AppBar background
        leading: IconButton( // Use IconButton for better tap area and semantics
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), // Consistent icon and color
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Wishlist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, // Bolder title
            fontSize: 20, // Larger font size for title
            color: Colors.white, // Consistent title color
          ),
        ),
        centerTitle: true, // Center title as per your AppTheme
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPurple), // Consistent loading indicator color
                const SizedBox(height: 16),
                Text(
                  'Loading your wishlist...',
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight),
                ),
              ],
            ),
          );
        }

        if (controller.wishlist.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.textLight), // Themed icon
                  const SizedBox(height: 24),
                  Text(
                    'Your wishlist is empty!',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your favorite items here to easily find them later.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Assuming you have a route to navigate to a product listing screen
                      // Or simply go back to previous screen (e.g., home)
                      Get.back(); // Or Get.toNamed('/products') if you have a product list route
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple, // Consistent button style
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      'Start Exploring Products',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16), // Increased padding for better spacing
          itemCount: controller.wishlist.length,
          itemBuilder: (context, index) {
            final product = controller.wishlist[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16), // Increased bottom padding between cards
              child: WishlistCard(
                product: product,
                onRemove: () => controller.removeFromWishlist(product.id), // Ensure product.id is correct type
              ),
            );
          },
        );
      }),
    );
  }
}