import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Keep shimmer for loading effect

import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart' show SubCategoryController;
import '../../themes/app_theme.dart'; // Import your AppTheme and AppColors
import 'widgets/CategoryTile.dart'; // Ensure CategoryTile is properly defined and imported

class CategorySectionScreen extends StatelessWidget {
  final CategoryController categoryController = Get.find<CategoryController>();
  final SubCategoryController subCategoryController = Get.find<SubCategoryController>();

  CategorySectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Blinkit-like background
      appBar: AppBar(
        title: Text(
          "Categories",
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textDark, // Dark text color for App Bar
            fontWeight: FontWeight.w700, // Bold title
          ),
        ),
        centerTitle: false, // Title aligned to the left
        backgroundColor: AppColors.white, // White app bar for clean look
        elevation: 0.5, // Subtle shadow for app bar
        foregroundColor: AppColors.textDark, // Dark back arrow/icons
        automaticallyImplyLeading: false, // If this is a bottom nav tab
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return _buildLoadingState(context);
        } else {
          final allCategories = categoryController.categories;
          final availableSubCategories = subCategoryController.subCategories;

          final availableSubCatIds = availableSubCategories.map((e) => e.id).toSet();

          // Filter categories to only show those that have at least one associated sub-category
          // that exists in the availableSubCategories list.
          final filteredCategories = allCategories.where((category) {
            final subCatIdsInThisCategory = List<String>.from(category.subCategoryIds ?? []);
            return subCatIdsInThisCategory.any((id) => availableSubCatIds.contains(id));
          }).toList();

          if (filteredCategories.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Prevent inner scroll
                  itemCount: filteredCategories.length,
                  padding: const EdgeInsets.symmetric(vertical: 8), // Padding around the whole list of sections
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final String title = category.name ?? "Unnamed Category";

                    // Get sub-categories actually linked to this main category and are available
                    final matchingSubCategories = availableSubCategories
                        .where((sub) => (category.subCategoryIds ?? []).contains(sub.id))
                        .toList();

                    if (matchingSubCategories.isEmpty) {
                      return const SizedBox.shrink(); // Hide category section if no sub-categories
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Section Header (e.g., "Fruits & Vegetables") ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12), // Adjusted padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: textTheme.titleLarge?.copyWith( // titleLarge for section titles
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700, // Bold
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement navigation to a page showing ALL products/subcategories for this category
                                  Get.toNamed('/category_products', arguments: category);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.success, // Blinkit green for "See All"
                                  textStyle: textTheme.labelLarge?.copyWith( // labelLarge for "See All"
                                    fontWeight: FontWeight.w600, // Semi-bold
                                  ),
                                  minimumSize: Size.zero, // Remove default min button size
                                  padding: EdgeInsets.zero, // Remove default padding
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                                ),
                                child: Text(
                                  "See All",
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // --- Horizontal Sub-Category/Product List ---
                        SizedBox(
                          height: 120, // Reduced height for more compact horizontal list
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16), // Horizontal padding
                            itemCount: matchingSubCategories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10), // Tighter separation
                            itemBuilder: (context, i) {
                              final sub = matchingSubCategories[i];
                              final image = (sub.photos?.isNotEmpty ?? false)
                                  ? sub.photos![0]
                                  : "https://via.placeholder.com/150x150/E0E0E0/A0A0A0?text=No+Image";

                              return CategoryTile( // Use the new CategoryTile
                                title: sub.name ?? 'Unknown',
                                imageUrl: image,
                                onTap: () {
                                  // TODO: Navigate to specific sub-category products or details
                                  print('Tapped on sub-category: ${sub.name}');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16), // Space after horizontal list before next section
                      ],
                    );
                  },
                ),
                // --- Mobiking Branding Section ---
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40), // Consistent horizontal padding, increased bottom
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobiking",
                        textAlign: TextAlign.left,
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.textLight.withOpacity(0.5), // Lighter, more subtle branding
                          letterSpacing: -1.0, // Reduced letter spacing
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8), // Tighter spacing
                      Text(
                        "Your Wholesale Partner",
                        textAlign: TextAlign.left,
                        style: textTheme.headlineSmall?.copyWith( // Using headlineSmall
                          color: AppColors.textLight.withOpacity(0.6),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12), // Tighter spacing
                      Text(
                        "Buy in bulk, save big. Get the best deals on mobile phones and accessories, delivered directly to your doorstep.",
                        textAlign: TextAlign.left,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 60), // Space at bottom
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  // --- Loading State ---
  Widget _buildLoadingState(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      itemCount: 3, // Show 3 shimmer sections
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for section title
              Shimmer.fromColors(
                baseColor: Colors.grey[200]!, // Lighter base color
                highlightColor: Colors.grey[50]!, // Even lighter highlight
                child: Container(
                  width: 180, // Wider shimmer for title
                  height: textTheme.titleLarge?.fontSize ?? 22, // Use titleLarge font size
                  // White shimmer background
                 decoration: BoxDecoration(
                   color: AppColors.white,borderRadius: BorderRadius.circular(4),
                 ), // Slightly rounded corners
                ),
              ),
              const SizedBox(height: 16),
              // Shimmer for horizontal list
              SizedBox(
                height: 120, // Matches CategoryTile height
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[200]!,
                      highlightColor: Colors.grey[50]!,
                      child: Container(
                        width: 90, // Matches CategoryTile width
                        height: 120, // Matches CategoryTile height
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10), // Matches CategoryTile border radius
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: AppColors.textLight.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              'No categories available at the moment.',
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.textMedium, // Softer color for empty state message
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check back later!',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => categoryController.fetchCategories(),
              icon: const Icon(Icons.refresh, color: AppColors.white),
              label: Text('Retry', style: textTheme.labelLarge?.copyWith(color: AppColors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, // Blinkit green button
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}