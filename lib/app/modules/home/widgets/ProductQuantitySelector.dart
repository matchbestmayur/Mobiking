// lib/app/modules/home/widgets/ProductQuantitySelector.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/data/product_model.dart'; // Make sure this path is correct


import '../../../controllers/cart_controller.dart';
import 'ProductVariantBottomSheet.dart'; // NEW IMPORT

class ProductQuantitySelector extends StatelessWidget {
  final ProductModel product;

  const ProductQuantitySelector({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use Get.find<CartController>() here because this widget directly interacts with the cart.
    final cartController = Get.find<CartController>();

    return Obx(() {
      final totalQuantityInCart = cartController.getTotalQuantityForProduct(productId: product.id);
      final bool isBusy = cartController.isLoading.value;

      if (totalQuantityInCart > 0) {
        // Get current cart items for this product to determine if multiple variants exist
        final List<Map<String, dynamic>> productCartItems = cartController.cartItems
            .where((item) => item['productId']?['_id'] == product.id)
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button
              InkWell(
                onTap: isBusy
                    ? null
                    : () {
                  if (productCartItems.length == 1) {
                    // If only one variant of this product in cart, decrement it directly
                    final String variantName = productCartItems.first['variantName'];
                    cartController.removeFromCart(
                      productId: product.id,
                      variantName: variantName,
                    );
                  } else {
                    // If multiple variants or complex scenario, open bottom sheet
                    ProductVariantBottomSheet.show(context, product, isAdding: false);
                  }
                },
                child: Icon(Icons.remove, color: Colors.green.shade800, size: 20),
              ),
              Text(
                '$totalQuantityInCart',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Increment Button
              InkWell(
                onTap: isBusy
                    ? null
                    : () {
                  ProductVariantBottomSheet.show(context, product, isAdding: true);
                },
                child: Icon(Icons.add, color: Colors.green.shade800, size: 20),
              ),
            ],
          ),
        );
      } else {
        // ADD button when product is not in cart
        return OutlinedButton(
          onPressed: () {
            ProductVariantBottomSheet.show(context, product, isAdding: true);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6),
            side: const BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: Colors.white,
          ),
          child: Text(
            'ADD',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
    });
  }
}