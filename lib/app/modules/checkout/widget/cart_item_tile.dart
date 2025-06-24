import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Removed as AppTheme provides comprehensive text styles
// import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppTheme
import '../../../controllers/cart_controller.dart';
import '../../../data/product_model.dart';
import 'package:collection/collection.dart'; // Make sure this is imported for firstWhereOrNull

class CartItemTile extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final String variantName;
  // If you need to pass an onTap for product details from this tile, add it here
  // final VoidCallback? onProductTap;

  const CartItemTile({
    Key? key,
    required this.product,
    required this.quantity,
    required this.variantName,
    // this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CartController cartController = Get.find<CartController>();

    // Determine the price and stock for the specific variant
    double displayPrice = 0.0;
    int? variantStock;

    // Logic to find price and stock for the given variantName
    final productVariant = product.variants[variantName];

      displayPrice = product.sellingPrice[0].price!.toDouble();
      variantStock = product.totalStock; // Fallback to total stock if variant stock not specific


    // Determine the primary image URL
    String imageUrl = 'https://via.placeholder.com/100'; // Default placeholder
    if (product.images.isNotEmpty) {
      // Assuming product.images[0] is the primary URL string
      imageUrl = product.images[0];
    }


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding inside the card
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0), // No external margin, controlled by parent
      decoration: BoxDecoration(
        color: AppColors.white, // White background for the card
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners, less than main checkout container
        border: Border.all(color: AppColors.neutralBackground, width: 1), // Subtle border
        // No explicit shadow here, let the parent container (in CheckoutScreen) handle it.
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded image corners
                child: Image.network(
                  imageUrl,
                  width: 80, // Larger image size for prominence
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.neutralBackground, // Light grey for error background
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.textLight, // Lighter icon for error
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Spacing between image and text

              // Product Details (Name, Variant, Price)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unnamed Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith( // titleSmall for product name
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4), // Small space after product name
                    Text(
                      variantName, // Only show variant, as price is separate
                      style: textTheme.bodyMedium?.copyWith( // bodyMedium for variant
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium, // Subtler color
                      ),
                      maxLines: 1, // Usually 1 line for variant
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Space before price
                    Text(
                      '₹${displayPrice.toStringAsFixed(0)}', // Price, bold and dark
                      style: textTheme.titleSmall?.copyWith( // titleSmall for price
                        fontWeight: FontWeight.w700, // Very bold
                        color: AppColors.textDark,
                      ),
                    ),
                    if (variantStock != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${variantStock! > 0 ? variantStock : 'Out of Stock'}',
                        style: textTheme.bodySmall?.copyWith( // bodySmall for stock
                          fontSize: 11, // Slightly smaller
                          fontWeight: FontWeight.w500,
                          color: variantStock! > 0 ? AppColors.success : AppColors.danger, // Green for in stock, red for out
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Quantity Selector
              Align(
                alignment: Alignment.bottomRight, // Align to bottom right of the row
                child: Obx(
                      () {
                    final bool isLoading = cartController.isLoading.value;
                    final bool isDecrementDisabled = isLoading || quantity <= 1; // Disable decrement if quantity is 1
                    final bool isIncrementDisabled = isLoading || (variantStock != null && quantity >= variantStock!);

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Padding around buttons
                      decoration: BoxDecoration(
                        color: AppColors.success, // Light green background for quantity selector bar
                        borderRadius: BorderRadius.circular(10), // Highly rounded corners
                        border: Border.all(color: AppColors.success, width: 0.5), // Subtle green border
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Wrap content tightly
                        children: [
                          // Decrement Button
                          _buildQuantityButton(
                            context: context,
                            icon: Icons.remove,
                            onTap: isDecrementDisabled
                                ? null
                                : () {
                              cartController.removeFromCart(
                                productId: product.id!,
                                variantName: variantName,
                              );
                            },
                            isDisabled: isDecrementDisabled,
                            isLoading: isLoading && quantity <= 1, // Only show loading if decreasing to 0
                          ),
                          const SizedBox(width: 8), // Smaller space between buttons and quantity
                          // Quantity Text
                          Text(
                            '$quantity',
                            style: textTheme.labelLarge?.copyWith( // labelLarge for quantity
                              fontWeight: FontWeight.w700, // Bold
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Increment Button
                          _buildQuantityButton(
                            context: context,
                            icon: Icons.add,
                            onTap: isIncrementDisabled
                                ? null
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
                                  backgroundColor: AppColors.danger.withOpacity(0.8),
                                  colorText: AppColors.white,
                                  icon: const Icon(Icons.warning, color: AppColors.white),
                                  margin: const EdgeInsets.all(10),
                                  borderRadius: 10,
                                );
                              }
                            },
                            isDisabled: isIncrementDisabled,
                            isLoading: isLoading && (variantStock == null || quantity < variantStock!), // Show loading if valid increment
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for quantity buttons
  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onTap,
    required bool isDisabled,
    required bool isLoading, // Added isLoading flag for individual button state
  }) {
    // Determine button color based on disabled state and theme
    final Color buttonColor = isDisabled ? AppColors.success : AppColors.success;
    final Color iconColor = isDisabled ? AppColors.textLight : AppColors.white; // White icon on active, light grey on disabled

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6), // Consistent padding for circular buttons
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle, // Circular shape
        ),
        child: isLoading // Show loading indicator only if this specific button action is loading
            ? SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor), // Loading indicator matches icon color
          ),
        )
            : Icon(
          icon,
          size: 18, // Icon size
          color: iconColor,
        ),
      ),
    );
  }
}