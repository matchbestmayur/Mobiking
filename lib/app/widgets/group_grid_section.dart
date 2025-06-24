import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Removed: import 'package:google_fonts/google_fonts.dart'; // Keep this only if you have specific, non-themed font needs
import 'package:mobiking/app/themes/app_theme.dart'; // Import AppColors and AppTheme

import '../data/group_model.dart';
import '../data/product_model.dart';
import '../controllers/cart_controller.dart';
import '../modules/Product_page/product_page.dart';
import '../modules/home/widgets/GroupProductsScreen.dart';
import '../modules/home/widgets/ProductCard.dart';


class GroupWithProductsSection extends StatelessWidget {
  final List<GroupModel> groups;

  const GroupWithProductsSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: groups.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final group = groups[index];

        if (group.products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                group.name,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: group.products.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                itemBuilder: (context, prodIndex) {
                  final product = group.products[prodIndex];
                  return ProductCards( // <--- USING THE REUSABLE ProductCard HERE
                    product: product,
                    onTap: (tappedProduct) {
                      Get.to(() => ProductPage(product: tappedProduct));
                      print('Navigating to product page for: ${tappedProduct.name}');
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.to(() => GroupProductsScreen(group: group));
                    print('Navigating to all products for group: ${group.name}');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.lightPurple, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See More',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryPurple),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// NOTE: The _ProductCard and helper functions below are now part of 'product_card.dart'
// and should be removed from this file to avoid duplication and conflicts.
// I am including them here commented out for context of what was removed.
/*
class _ProductCard extends StatelessWidget {
  // ... (this content should be in lib/widgets/product_card.dart)
}

Widget _buildQuantitySelectorButton(
    BuildContext context,
    int totalQuantity,
    ProductModel product,
    CartController cartController,
    ) {
  // ... (this content should be in lib/widgets/product_card.dart or a separate helper file)
}

void _showVariantBottomSheet(
    BuildContext context,
    ProductModel product,
    {required bool isAdding}
    ) {
  // ... (this content should be in lib/widgets/product_card.dart or a separate helper file)
}
*/