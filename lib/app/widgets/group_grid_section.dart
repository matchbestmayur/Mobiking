import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import '../data/group_model.dart';
import '../data/product_model.dart';
import '../controllers/cart_controller.dart';
import '../modules/Product_page/product_page.dart';
import '../modules/home/widgets/GroupProductsScreen.dart';

class GroupWithProductsSection extends StatelessWidget {
  final List<GroupModel> groups;

  const GroupWithProductsSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: groups.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final group = groups[index];

        if (group.products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
                child: Text(
                  group.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: group.products.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                  itemBuilder: (context, prodIndex) {
                    final product = group.products[prodIndex];
                    return _ProductCard(
                      product: product,
                      onTap: (tappedProduct) {
                        Get.to(() => ProductPage(product: tappedProduct));
                        print('Navigating to product page for: ${tappedProduct.name}');
                      },
                    );
                  },
                ),
              ),
              // --- ADDED SEE MORE BUTTON HERE ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0), // Adjust padding as needed
                child: Align( // Aligns the button to the end (right)
                  alignment: Alignment.centerRight,
                  child: TextButton( // Using TextButton for a subtle "See More" look
                    onPressed: () {
                      Get.to(() => GroupProductsScreen(group: group));
                      // Navigate to a page showing all products for this specific group// Pass the entire group model
                      print('Navigating to all products for group: ${group.name}');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryPurple, // Theme color for text
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.lightPurple, width: 1), // Subtle border
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Make button fit content
                      children: [
                        Text(
                          'See More',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
              // --- END ADDED SEE MORE BUTTON ---
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel)? onTap;

  const _ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = product.images.isNotEmpty && product.images[0].isNotEmpty;
    final hasSellingPrice = product.sellingPrice.isNotEmpty;
    // **FIXME: Pull originalPrice from product.sellingPrice if available or your product data model.**
    final originalPrice = 5999;
    final sellingPrice = hasSellingPrice ? product.sellingPrice[0].price : originalPrice;

    int discountPercent = 0;
    if (hasSellingPrice && originalPrice > sellingPrice) {
      discountPercent = (((originalPrice - sellingPrice) / originalPrice) * 100).round();
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap?.call(product),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 108,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: hasImage
                      ? Image.network(product.images[0], fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (discountPercent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$discountPercent% OFF",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "₹$sellingPrice",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (discountPercent > 0)
                          Text(
                            "₹$originalPrice",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final cartController = Get.find<CartController>();
                        final totalQuantityInCart = cartController.getTotalQuantityForProduct(productId: product.id);

                        if (totalQuantityInCart > 0) {
                          // Pass the context, product, and cartController to the helper
                          return _buildQuantitySelectorButton(
                            context, // Pass context here
                            totalQuantityInCart,
                            product,
                            cartController,
                          );
                        } else {
                          return OutlinedButton(
                            onPressed: () {
                              // Initial add, always shows variant selection
                              _showVariantBottomSheet(context, product, isAdding: true);
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
                      }),
                    )
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

// --- Helper Functions ---

// Helper function: _buildQuantitySelectorButton
// **MODIFIED:** `context` is now passed. Logic for '-' button enhanced.
Widget _buildQuantitySelectorButton(
    BuildContext context, // Accept context
    int totalQuantity,
    ProductModel product,
    CartController cartController,
    ) {
  final bool isBusy = cartController.isLoading.value;

  // Get current cart items for this product
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
            // If only one unique variant of this product is in cart, decrement it directly
            if (productCartItems.length == 1) {
              final String variantName = productCartItems.first['variantName'];
              cartController.removeFromCart(
                productId: product.id,
                variantName: variantName,
              );
            } else {
              // If multiple variants or complex scenario, open bottom sheet
              _showVariantBottomSheet(context, product, isAdding: false);
            }
          },
          child: Icon(Icons.remove, color: Colors.green.shade800, size: 20),
        ),
        Text(
          '$totalQuantity', // Still shows total quantity
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
            // Increment always opens bottom sheet for variant selection
            _showVariantBottomSheet(context, product, isAdding: true);
          },
          child: Icon(Icons.add, color: Colors.green.shade800, size: 20),
        ),
      ],
    ),
  );
}

// Helper function: _showVariantBottomSheet
void _showVariantBottomSheet(
    BuildContext context,
    ProductModel product,
    {required bool isAdding}
    ) {
  final CartController cartController = Get.find<CartController>();
  final List<MapEntry<String, int>> variantEntries = product.variants.entries.toList();

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
                    controller: scrollController,
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

                      // Determine if the variant is selectable for current action
                      final bool canPerformAction = isAdding
                          ? variantStock > 0 // Can add if stock > 0
                          : currentVariantQuantity > 0; // Can remove if variant is in cart

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
                            Navigator.pop(context, variantName); // Dismiss the bottom sheet
                          }
                              : null, // Disable onTap if action not allowed
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
        },
      );
    },
  ).then((selectedVariantName) {
    if (selectedVariantName != null) {
      print('Bottom sheet dismissed. Selected Variant: $selectedVariantName');
    }
  });
}