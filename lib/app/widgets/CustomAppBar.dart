import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import 'CategoryTab.dart'; // Assumed location of TabControllerGetX


class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key});

  final tabController = Get.find<TabControllerGetX>();
  final subCategoryController = Get.find<SubCategoryController>(); // Get the CategoryController instance

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String? backgroundImage;
      final int selectedIndex = tabController.selectedIndex.value;

      // Safely attempt to get the background image from the selected sub-category
      if (selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length) {
        final currentSubCategory = subCategoryController.subCategories[selectedIndex];
        if (currentSubCategory.products.isNotEmpty && currentSubCategory.products[0].images.isNotEmpty) {
          backgroundImage = currentSubCategory.upperBanner;
        }
      }

      return Container(
        height: 70, // Give it a fixed height or use media query for responsiveness
        decoration: BoxDecoration(
          color: AppColors.darkPurple, // Fallback color if no image or during loading
          image: backgroundImage != null
              ? DecorationImage(
            image: NetworkImage(backgroundImage),
            fit: BoxFit.cover,
            // Apply a color filter to darken the image for better text readability
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4), // Adjust opacity as needed
              BlendMode.darken,
            ),
          )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // Align content to the bottom
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.storefront, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mobiking Wholesale",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white, // Keep text white for visibility over image
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // Display the name of the currently selected sub-category
                          selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length
                              ? subCategoryController.subCategories[selectedIndex].name
                              : 'Select Category', // Default text if no category selected
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}