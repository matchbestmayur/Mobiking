import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Ensure correct path to AppColors

import '../../../controllers/cart_controller.dart';
import '../../../data/product_model.dart'; // Ensure correct path to ProductModel


class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double cardWidth;
  // Removed onAddToCart as it will be handled internally now

  const ProductCard({
    super.key,
    required this.product,
    this.cardWidth = 130,
  });

  @override
  Widget build(BuildContext context) {
    // Get an instance of CartController
    final CartController cartController = Get.find<CartController>();

    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final num sellingPriceValue = product.sellingPrice.isNotEmpty ? product.sellingPrice.first.price : 0.0;
    final num originalPriceValue = product.sellingPrice.isNotEmpty
        ? (product.sellingPrice.first.price ?? sellingPriceValue)
        : 0.0;

    final bool hasDiscount = originalPriceValue > sellingPriceValue && originalPriceValue > 0;

    // Assuming a default variant name if your products don't always have named variants
    // Adjust this if your ProductModel guarantees a variantName or if you have a way
    // to determine the 'default' variant for a general product card.
    // For now, let's assume the first variant key or a placeholder.
    final String defaultVariantName = product.variants.keys.isNotEmpty
        ? product.variants.keys.first
        : 'Default'; // Fallback if no variants

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 📷 Product Image
            AspectRatio(
              aspectRatio: 1.0,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.success,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 50, color: Colors.grey.shade400),
                ),
              )
                  : Container(
                color: Colors.grey.shade100,
                child: Icon(Icons.image_not_supported_outlined,
                    size: 50, color: Colors.grey.shade400),
              ),
            ),

            /// 📝 Product Info & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "₹${sellingPriceValue.toStringAsFixed(0)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          "₹${originalPriceValue.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            /// 🛒 Add to Cart / Quantity Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: Obx(() {
                final quantityInCart = cartController.getVariantQuantity(
                  productId: product.id,
                  variantName: defaultVariantName,
                );

                final bool isBusy = cartController.isLoading.value;
                final bool canDecrement = quantityInCart > 0 && !isBusy;
                final bool canIncrement = !isBusy;

                if (quantityInCart > 0) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Decrement Button
                      InkWell(
                        onTap: canDecrement
                            ? () => cartController.removeFromCart(
                          productId: product.id,
                          variantName: defaultVariantName,
                        )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: canDecrement ? Colors.grey[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isBusy
                                ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.success),
                            )
                                : const Icon(Icons.remove, size: 18, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Display Current Quantity in Cart
                      Text(
                        '$quantityInCart',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 8),

                      // Increment Button
                      InkWell(
                        onTap: canIncrement
                            ? () => cartController.addToCart(
                          productId: product.id,
                          variantName: defaultVariantName,
                        )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: canIncrement ? AppColors.success : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isBusy
                                ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Icon(Icons.add, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // If item is not in cart, show the single "Add" button
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: isBusy
                            ? null // Disable if busy
                            : () => cartController.addToCart(
                          productId: product.id,
                          variantName: defaultVariantName,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Center(
                            // **** THIS IS THE KEY CHANGE ****
                            child: isBusy
                                ? const SizedBox(
                              width: 20, // Indicator size for single button
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                                : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}