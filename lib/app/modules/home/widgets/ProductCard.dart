// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math'; // For random numbers in the example

import '../../../controllers/cart_controller.dart';
import '../../../data/product_model.dart';
import '../../../themes/app_theme.dart';
import 'app_star_rating.dart';
import 'favorite_toggle_button.dart'; // <--- Import the new widget

class ProductCards extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel)? onTap;

  const ProductCards({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  static final Random _random = Random(); // Keep Random here for demo data

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final hasImage = product.images.isNotEmpty && product.images[0].isNotEmpty;

    final int sellingPrice = product.sellingPrice.isNotEmpty
        ? (product.sellingPrice[0].price ?? 0).toInt()
        : 0;

    // Use originalPrice from sellingPrice list if available, otherwise default to sellingPrice
    final int originalPrice = product.sellingPrice.isNotEmpty
        ? (product.sellingPrice[0].price ?? sellingPrice).toInt()
        : sellingPrice;


    int discountPercent = 0;
    if (originalPrice > 0 && sellingPrice < originalPrice) {
      discountPercent = (((originalPrice - sellingPrice) / originalPrice) * 100).round();
    }

    // Always generate random rating and count for demonstration
    final double demoRating = 3.0 + _random.nextDouble() * 2.0; // Random double between 3.0 and 5.0
    final int demoRatingCount = 10 + _random.nextInt(1000); // Random int between 10 and 1009

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap?.call(product),
        child: Container(
          width: 140, // Fixed width for the product card
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 108,
                      width: double.infinity,
                      color: AppColors.neutralBackground,
                      child: hasImage
                          ? Image.network(product.images[0], fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image, size: 40, color: AppColors.textLight),
                          ))
                          : Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textLight),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteToggleButton( // <--- Replaced with the new widget
                      productId: product.id.toString(), // Pass the product ID
                      iconSize: 18,
                      padding: 4,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Use the new AppStarRating widget
                        AppStarRating(
                          rating: demoRating,
                          ratingCount: demoRatingCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (discountPercent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.discountGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$discountPercent% OFF",
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹$sellingPrice",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (originalPrice > 0 && sellingPrice < originalPrice)
                          Text(
                            "₹$originalPrice",
                            style: textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final cartController = Get.find<CartController>();
                        int totalProductQuantityInCart = 0;
                        for (var variantEntry in product.variants.entries) {
                          totalProductQuantityInCart += cartController.getVariantQuantity(
                              productId: product.id, variantName: variantEntry.key);
                        }

                        final int availableVariantCount = product.variants.entries
                            .where((entry) => entry.value > 0)
                            .length;

                        if (totalProductQuantityInCart > 0) {
                          return _buildQuantitySelectorButton(
                            totalProductQuantityInCart,
                            product,
                            cartController,
                            context,
                          );
                        } else {
                          if (availableVariantCount > 1) {
                            return ElevatedButton(
                              onPressed: () {
                                _showVariantBottomSheet(context, product.variants, product);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(color: AppColors.success, width: 1),
                                ),
                                elevation: 0,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ADD',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '$availableVariantCount options',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (availableVariantCount == 1) {
                            return ElevatedButton(
                              onPressed: () {
                                final singleVariant = product.variants.entries.firstWhere((element) => element.value > 0);
                                cartController.addToCart(productId: product.id, variantName: singleVariant.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${singleVariant.key} to cart!'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'ADD',
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.neutralBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sold Out',
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// These helper functions remain outside for now, but could be made into separate widgets too if needed elsewhere.
Widget _buildQuantitySelectorButton(
    int totalQuantity,
    ProductModel product,
    CartController cartController,
    BuildContext context,
    ) {
  final TextTheme textTheme = Theme.of(context).textTheme;

  return Container(
    height: 30,
    decoration: BoxDecoration(
      color: AppColors.success,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            if (totalQuantity == 1) {
              final cartItemsForProduct = cartController.getCartItemsForProduct(productId: product.id);
              if (cartItemsForProduct.isNotEmpty) {
                cartController.removeFromCart(productId: product.id, variantName: cartItemsForProduct.keys.first);
              }
            } else {
              _showVariantBottomSheet(context, product.variants, product);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.remove, color: AppColors.white, size: 18),
          ),
        ),
        Text(
          '$totalQuantity',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        InkWell(
          onTap: () {
            _showVariantBottomSheet(context, product.variants, product);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.add, color: AppColors.white, size: 18),
          ),
        ),
      ],
    ),
  );
}

void _showVariantBottomSheet(BuildContext context, Map<String, int> variantsMap, ProductModel product) {
  final TextTheme textTheme = Theme.of(context).textTheme;
  final CartController cartController = Get.find<CartController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final List<MapEntry<String, int>> variantEntries = variantsMap.entries.toList();

      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                Text(
                  'Select a Variant',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: variantEntries.length,
                    itemBuilder: (context, index) {
                      final entry = variantEntries[index];
                      final variantName = entry.key;
                      final variantStock = entry.value;

                      final bool isOutOfStock = variantStock <= 0;
                      final int quantityInCart = cartController.getVariantQuantity(productId: product.id, variantName: variantName);

                      final String variantImageUrl =
                      product.images.isNotEmpty ? product.images[0] : 'https://placehold.co/50x50/cccccc/ffffff?text=No+Img';

                      return Card(
                        color: AppColors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.neutralBackground, width: 1)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  color: AppColors.neutralBackground,
                                  child: isOutOfStock
                                      ? Center(
                                    child: Text(
                                      'Sold Out',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                      : Image.network(
                                    variantImageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, color: AppColors.textLight),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      variantName,
                                      style: textTheme.titleSmall?.copyWith(
                                        color: isOutOfStock ? AppColors.textLight : AppColors.textDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isOutOfStock)
                                      Text(
                                        'Out of Stock',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!isOutOfStock)
                                Obx(() {
                                  final currentVariantQuantity = cartController.getVariantQuantity(productId: product.id, variantName: variantName);

                                  if (currentVariantQuantity > 0) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              cartController.removeFromCart(productId: product.id, variantName: variantName);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Icon(Icons.remove, color: AppColors.white, size: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$currentVariantQuantity',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () {
                                              cartController.addToCart(productId: product.id, variantName: variantName);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Icon(Icons.add, color: AppColors.white, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return ElevatedButton(
                                      onPressed: () {
                                        cartController.addToCart(productId: product.id, variantName: variantName);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Added $variantName to cart!'),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(milliseconds: 700),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        elevation: 0,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'ADD',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                })
                              else
                                const Icon(Icons.info_outline, size: 20, color: AppColors.danger),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  ).then((selectedVariantName) {
    if (selectedVariantName != null) {
      print('Bottom sheet dismissed. Selected Variant: $selectedVariantName');
    }
  });
}