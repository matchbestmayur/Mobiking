import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import '../../../controllers/cart_controller.dart';
import '../../../data/product_model.dart';
import 'package:collection/collection.dart'; // Make sure this is imported for firstWhereOrNull

class CartItemTile extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final String variantName;

  const CartItemTile({
    Key? key,
    required this.product,
    required this.quantity,
    required this.variantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the price and stock for the specific variant
    double displayPrice = 0.0;
    int? variantStock;


    final CartController cartController = Get.find<CartController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.neutralBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Delivered At',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'Shipping Items 1',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 5,
            color: Colors.grey[100],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty && product.images[0].isNotEmpty
                      ? Image.network(
                    product.images[0],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  )
                      : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Unnamed Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Variant: $variantName',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (variantStock != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Stock: ${variantStock! > 0 ? variantStock : 'Out of Stock'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: variantStock! > 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrement Button
                        GestureDetector(
                          onTap: cartController.isLoading.value
                              ? null // Disable tap when loading
                              : () {
                            if (quantity > 0) {
                              cartController.removeFromCart(
                                productId: product.id!,
                                variantName: variantName,
                              );
                            }
                          },
                          child: Obx( // Wrap with Obx to react to isLoading
                                () => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (quantity > 1 && !cartController.isLoading.value)
                                    ? Colors.green[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: cartController.isLoading.value
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              )
                                  : Icon(
                                Icons.remove,
                                size: 18,
                                color: (quantity > 1 && !cartController.isLoading.value)
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$quantity',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Increment Button
                        GestureDetector(
                          onTap: cartController.isLoading.value
                              ? null // Disable tap when loading
                              : () {
                            if (variantStock == null || quantity < variantStock!) {
                              cartController.addToCart(
                                productId: product.id!,
                                variantName: variantName,
                              );
                            } else {
                              Get.snackbar(
                                'Out of Stock',
                                'Maximum quantity reached for this variant or it is out of stock.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white,
                                icon: const Icon(Icons.warning, color: Colors.white),
                                margin: const EdgeInsets.all(10),
                                borderRadius: 10,
                              );
                            }
                          },
                          child: Obx( // Wrap with Obx to react to isLoading
                                () => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ((variantStock == null || quantity < variantStock!) && !cartController.isLoading.value)
                                    ? Colors.green[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: cartController.isLoading.value
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              )
                                  : Icon(
                                Icons.add,
                                size: 18,
                                color: ((variantStock == null || quantity < variantStock!) && !cartController.isLoading.value)
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}