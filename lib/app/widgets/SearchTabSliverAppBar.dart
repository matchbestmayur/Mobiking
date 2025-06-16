import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/modules/search/SearchPage.dart';
import 'package:mobiking/app/themes/app_theme.dart';

 // Make sure this path is correct
import 'CategoryTab.dart'; // Assumed location of TabControllerGetX and CustomTabBarSection

class SearchTabSliverAppBar extends StatelessWidget {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;

  SearchTabSliverAppBar({
    Key? key,
    this.searchController,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickySearchAndTabBarDelegate(
        searchController: searchController,
        onSearchChanged: onSearchChanged,
      ),
    );
  }
}

// Create sticky delegate
class _StickySearchAndTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;

  _StickySearchAndTabBarDelegate({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => 152; // Minimum height when collapsed
  @override
  double get maxExtent => 152; // Fixed height to prevent expansion

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final tabController = Get.find<TabControllerGetX>();
    final subCategoryController = Get.find<SubCategoryController>(); // Find the CategoryController instance

    return Obx(() {
      String? backgroundImage;
      final int selectedIndex = tabController.selectedIndex.value;

      // Attempt to get the background image from the selected sub-category
      if (selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length) {
        final currentSubCategory = subCategoryController.subCategories[selectedIndex];
        if (currentSubCategory.products.isNotEmpty && currentSubCategory.products[0].images.isNotEmpty) {
          backgroundImage = currentSubCategory.upperBanner;
        }
      }

      return SafeArea(
        top: false, // Prevents double padding, assuming your main app bar handles top inset
        child: Container(
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
                : DecorationImage(image: NetworkImage("")),
          ),
          child: Column(
            children: [
              // Search bar
              Padding(
                // Adjusted top padding for more balanced spacing from the element above it
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: ClipRRect( // Added ClipRRect to ensure the borderRadius is perfectly applied
                  borderRadius: BorderRadius.circular(30), // Increased for a more pronounced pill shape (half of 50 height)
                  child: Container(
                    height: 45, // Slightly taller for better touch target and visual presence
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // The borderRadius here is technically redundant if ClipRRect is used,
                      // but it's good practice to keep it for clarity and fallback.
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15), // Softer, yet more visible shadow
                          blurRadius: 8, // Increased blur for a diffused shadow
                          offset: const Offset(0, 4), // Deeper shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged, // Will not be triggered by user typing due to readOnly
                      onTap: () {
                        Get.to(
                              () => const SearchPage(),
                          transition: Transition.fadeIn, // Smooth transition
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      readOnly: true, // <--- This makes the TextField static (non-editable)
                      // Use AppColors for text color and GoogleFonts for consistency
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark),
                      cursorColor: AppColors.primaryPurple, // Themed cursor color
                      decoration: InputDecoration(
                        border: InputBorder.none, // Removed default TextField border for a cleaner look
                        hintText: 'Search products, brands...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15, // Match input text size for consistency
                          color: AppColors.textLight, // Lighter color for hint text
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight), // Themed search icon
                        // Changed suffixIcon to a static navigation indicator
                        suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.textLight),
                        // Adjusted content padding for better vertical alignment within the 50 height
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Tabs section
              // The CustomTabBarSection will render on top of the background image.
              // Ensure its background is transparent or semi-transparent if you want the image to show through.
              // If it has its own opaque background, it will cover the image.
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                color: Colors.transparent, // Set to transparent to show the background image
                child: CustomTabBarSection(),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Returning `false` is generally fine here because the `Obx` widget
    // inside `build` handles reactive updates to the UI when the selectedIndex changes.
    // The delegate's size or layout properties aren't changing, only its internal content.
    return false;
  }
}