import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/cart_controller.dart';
import '../../../data/product_model.dart';
import '../../../data/sub_category_model.dart';

class AllProductsListView extends StatelessWidget {
  final List<SubCategory> subCategories;
  final Function(ProductModel)? onProductTap;

  const AllProductsListView({
    Key? key,
    required this.subCategories,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> allProducts = subCategories.expand((sub) => sub.products).toList();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: allProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = allProducts[index];
          return _ProductCard(product: product, onTap: onProductTap);
        },
      ),
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
    return _buildQuantitySelectorButton(
    totalQuantityInCart,
    product,
    cartController,
    );
    } else {
    return OutlinedButton(
    onPressed: () {
    _showVariantBottomSheet(context, product.variants, product);
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
    )   ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildQuantitySelectorButton(
    int totalQuantity,
    ProductModel product,
    CartController cartController,
    ) {
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
        InkWell(
          onTap: () {
            String? variantToDecrement;
            for (var entry in product.variants.keys) {
              if (cartController.getVariantQuantity(productId: product.id, variantName: entry) > 0) {
                variantToDecrement = entry;
                break;
              }
            }

            if (variantToDecrement != null) {
              cartController.removeFromCart(productId: product.id, variantName: variantToDecrement);
            }
          },
          child: Icon(Icons.remove, color: Colors.green.shade800, size: 20),
        ),
        Text(
          '$totalQuantity',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.green.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: () {
            _showVariantBottomSheet(Get.context!, product.variants, product);
          },
          child: Icon(Icons.add, color: Colors.green.shade800, size: 20),
        ),
      ],
    ),
  );
}


void _showVariantBottomSheet(BuildContext context, Map<String, int> variantsMap, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final List<MapEntry<String, int>> variantEntries = variantsMap.entries.toList();

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
                  'Select a Variant',
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

                      final bool isOutOfStock = variantStock <= 0;

                      // For variant image, using the first product image as a placeholder.
                      // In a real app, you'd associate specific images with specific variants.
                      final String variantImageUrl =
                      product.images.isNotEmpty ? product.images[0] : 'https://via.placeholder.com/50';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          // Disable onTap if out of stock
                          onTap: isOutOfStock
                              ? null
                              : () {
                            final cartController = Get.find<CartController>();
                            cartController.addToCart(
                                productId: product.id,
                                variantName: variantName); // Assuming quantity 1 for simplicity

                            Navigator.pop(context, variantName); // Dismiss the bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added $variantName to cart!')),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[100], // Background color for the image/banner area
                                    child: isOutOfStock
                                        ? Center(
                                      child: Text(
                                        'Sold Out',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                        : Image.network(
                                      variantImageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isOutOfStock ? Colors.grey : Colors.black87, // Grey out name if out of stock
                                        ),
                                      ),
                                      Text(
                                        isOutOfStock ? 'Out of Stock' : 'In Stock: $variantStock',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: isOutOfStock ? Colors.red.shade700 : Colors.grey[700],
                                          fontWeight: isOutOfStock ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Show a different icon if out of stock
                                if (!isOutOfStock)
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                                else
                                  const Icon(Icons.info_outline, size: 20, color: Colors.red),
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
