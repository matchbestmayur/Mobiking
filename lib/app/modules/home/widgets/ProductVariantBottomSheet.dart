// lib/app/modules/home/widgets/ProductVariantBottomSheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/data/product_model.dart'; // Make sure this path is correct


import '../../../controllers/cart_controller.dart'; // Make sure this path is correct

class ProductVariantBottomSheet extends StatelessWidget {
  final ProductModel product;
  final bool isAdding;

  const ProductVariantBottomSheet({
    Key? key,
    required this.product,
    required this.isAdding,
  }) : super(key: key);

  // Static method to show the bottom sheet
  static void show(BuildContext context, ProductModel product, {required bool isAdding}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return ProductVariantBottomSheet(
              product: product,
              isAdding: isAdding,
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

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final List<MapEntry<String, int>> variantEntries = product.variants.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Text(
            isAdding ? 'Select a Variant to Add' : 'Select a Variant to Remove',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: Get.find<ScrollController>(), // Use Get.find to get the scroll controller passed by DraggableScrollableSheet
              itemCount: variantEntries.length,
              itemBuilder: (context, index) {
                final entry = variantEntries[index];
                final variantName = entry.key;
                final variantStock = entry.value;

                final int currentVariantQuantity = cartController.getVariantQuantity(
                  productId: product.id,
                  variantName: variantName,
                );

                final String variantImageUrl =
                product.images.isNotEmpty ? product.images[0] : 'https://via.placeholder.com/50';

                final bool canPerformAction = isAdding
                    ? variantStock > 0
                    : currentVariantQuantity > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: canPerformAction ? Colors.white : Colors.grey.shade100,
                  child: InkWell(
                    onTap: canPerformAction
                        ? () {
                      if (isAdding) {
                        cartController.addToCart(
                          productId: product.id,
                          variantName: variantName,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $variantName to cart!')),
                        );
                      } else {
                        cartController.removeFromCart(
                          productId: product.id,
                          variantName: variantName,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed $variantName from cart!')),
                        );
                      }
                      Navigator.pop(context, variantName);
                    }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              variantImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variantName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: canPerformAction ? Colors.black : Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  isAdding
                                      ? 'Available: $variantStock'
                                      : 'In Cart: $currentVariantQuantity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: canPerformAction ? Colors.grey[700] : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (canPerformAction)
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                          else
                            const Icon(Icons.block, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}