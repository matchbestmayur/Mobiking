import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if you still use it directly elsewhere, otherwise can be removed.
import 'package:mobiking/app/modules/Product_page/product_page.dart';
import 'package:mobiking/app/widgets/group_grid_section.dart';
import '../../../data/group_model.dart';
import '../../../data/product_model.dart';
import '../../../data/sub_category_model.dart';
import '../../../themes/app_theme.dart'; // Import your AppTheme
import '../../../widgets/buildProductList.dart';
import 'sub_category_screen.dart';

Widget buildSectionView({
  required String bannerImageUrl,
  required List<SubCategory> subCategories,
  required List<SubCategory>? categoryGridItems, // This parameter seems unused in the provided code
  required List<GroupModel> groups,
}) {
  return Builder( // Use Builder to get a context for Theme.of
      builder: (context) {
        final TextTheme textTheme = Theme.of(context).textTheme; // Get the TextTheme

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📢 Category Banner
            if (bannerImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.darkPurple.withOpacity(0.9),
                    image: DecorationImage(
                      image: NetworkImage(bannerImageUrl),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Colors.black26,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),

            /// 🛒 Product Horizontal Scroll
            if (subCategories.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text(
                  "Top Picks for You",
                  // Apply headlineMedium or titleLarge for prominent section titles
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.textDark, // Ensure color is consistent with theme or override as needed
                  ),
                ),
              ),
              AllProductsListView(
                subCategories: subCategories,
                onProductTap: (product) {
                  Get.to(() => ProductPage(product: product));
                },
              ),
            ],

            /// 🧺 Group Sections with Products
            if (groups.isNotEmpty) ...[
              // The GroupWithProductsSection widget itself should ideally use the theme for its internal text.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GroupWithProductsSection(groups: groups),
              ),
            ],

            /// Optional: Add bottom padding to prevent last item cut-off
            const SizedBox(height: 100),
          ],
        );
      }
  );
}