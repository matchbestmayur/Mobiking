import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if you still need specific GoogleFonts calls outside the theme
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import '../controllers/tab_controller_getx.dart';
import 'CategoryTab.dart'; // Assumed location of TabControllerGetX


class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key});

  final tabController = Get.find<TabControllerGetX>();
  final subCategoryController = Get.find<SubCategoryController>(); // Get the CategoryController instance

  @override
  Widget build(BuildContext context) {
    // Get the TextTheme from the current context's theme
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(() {
      String? backgroundImage;
      final int selectedIndex = tabController.selectedIndex.value;

      // Safely attempt to get the background image from the selected sub-category
      if (selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length) {
        final currentSubCategory = subCategoryController.subCategories[selectedIndex];
        // Ensure upperBanner is not null or empty before trying to use it
        if (currentSubCategory.upperBanner != null && currentSubCategory.upperBanner!.isNotEmpty) {
          backgroundImage = currentSubCategory.upperBanner;
        }
      }

      return Container(
        padding: EdgeInsets.only(top: 15),
        height: 80, // Give it a fixed height or use media query for responsiveness
        decoration: BoxDecoration(
          color: AppColors.darkPurple, // Fallback color if no image or during loading
          image: backgroundImage != null
              ? DecorationImage(
            image: NetworkImage(backgroundImage!), // Use ! as we've checked for null above
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
                          // Use a text style from your theme for main app bar title
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white, // Override color to ensure it's white over the image
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // Display the name of the currently selected sub-category
                          selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length
                              ? subCategoryController.subCategories[selectedIndex].name
                              : 'Select Category', // Default text if no category selected
                          // Use a smaller text style from your theme
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70, // Override color for a subtle look
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