import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';


import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart' show SubCategoryController;
import 'widgets/CategoryTile.dart'; // Ensure CategoryTile is properly defined and imported

class CategorySectionScreen extends StatelessWidget {
  final CategoryController categoryController = Get.find<CategoryController>();
  final SubCategoryController subCategoryController = Get.find<SubCategoryController>();

  CategorySectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background for a cleaner look
      appBar: AppBar(
        title: Text(
          "Categories",
          style: GoogleFonts.poppins(
            fontSize: 22, // Slightly larger for app bar title
            fontWeight: FontWeight.w700, // Bolder
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // White app bar for a modern feel
        elevation: 1, // Subtle shadow for app bar
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return _buildLoadingState(); // Show loading state
        } else {
          final allCategories = categoryController.categories;
          final availableSubCategories = subCategoryController.subCategories;

          final availableSubCatIds = availableSubCategories.map((e) => e.id).toSet();

          final filteredCategories = allCategories.where((category) {
            final subCatIds = List<String>.from(category.subCategoryIds ?? []);
            return subCatIds.any((id) => availableSubCatIds.contains(id));
          }).toList();

          if (filteredCategories.isEmpty) {
            return _buildEmptyState(); // Show empty state
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCategories.length,
                  padding: const EdgeInsets.symmetric(vertical: 8), // Adjusted padding
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final String title = category.name ?? "Unnamed Category";

                    final matchingSubCategories = availableSubCategories
                        .where((sub) => (category.subCategoryIds ?? []).contains(sub.id))
                        .toList();

                    // Only show category section if there are matching sub-categories
                    if (matchingSubCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Section Header ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12), // Top padding for separation
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 20, // Larger and bolder for section title
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to full category page
                                  Get.toNamed('/category_products', arguments: category); // Example navigation
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColor, // Use primary color
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text("See All"),
                              )
                            ],
                          ),
                        ),

                        // --- Horizontal Product List ---
                        SizedBox(
                          height: 180, // Consistent height for product tiles
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: matchingSubCategories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final sub = matchingSubCategories[i];
                              final image = (sub.photos?.isNotEmpty ?? false)
                                  ? sub.photos![0]
                                  : "https://placehold.co/150x150/E0E0E0/A0A0A0?text=No+Image"; // Better placeholder

                              return ProductTile( // Corrected to CategoryTile
                                title: sub.name ?? 'Unknown',
                                imageUrl: image,
                                onTap: () {
                                  // TODO: Navigate to sub-category/product list page
                                  // Example: Get.toNamed('/sub_category_products', arguments: sub);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16), // Spacing after each horizontal list
                      ],
                    );
                  },
                ),
                // --- Mobiking Branding Section ---
                const SizedBox(height: 40), // Increased spacing before branding
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 24.0, 0), // Adjust padding for left alignment
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                    children: [
                      Text(
                        "Mobiking",
                        textAlign: TextAlign.left, // Explicitly left align
                        style: GoogleFonts.poppins( // Use GoogleFonts for Poppins
                          fontSize: 48, // Slightly larger for impact
                          fontWeight: FontWeight.w800, // Very bold
                          color: Colors.grey, // Light grey color for "wall text" effect
                          letterSpacing: -2.0, // Tighter letter spacing
                          height: 1.0, // Reduce line height for compactness
                        ),
                      ),
                      const SizedBox(height: 10), // Adjust spacing
                      Text(
                        "Your Wholesale Partner",
                        textAlign: TextAlign.left, // Explicitly left align
                        style: GoogleFonts.poppins(
                          fontSize: 20, // Slightly larger
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700, // Darker grey for contrast
                          height: 1.2, // Maintain readability
                        ),
                      ),
                      const SizedBox(height: 16), // Adjust spacing
                      Text(
                        "Buy in bulk, save big. Get the best deals on mobile phones and accessories, delivered directly to your doorstep.",
                        textAlign: TextAlign.left, // Explicitly left align
                        style: GoogleFonts.poppins(
                          fontSize: 15, // Slightly larger for readability
                          color: Colors.grey.shade600, // Medium grey
                          height: 1.4, // Good line height for body text
                        ),
                      ),
                      const SizedBox(height: 60), // Extra space at the very bottom
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

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3, // Show 3 placeholder sections
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for section title
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 150,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Shimmer for horizontal list
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4, // Show 4 placeholder tiles
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No categories available at the moment.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => categoryController.fetchCategories(), // Retry button
            icon: const Icon(Icons.refresh),
            label: Text('Retry', style: GoogleFonts.poppins(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
