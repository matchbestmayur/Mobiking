import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import AppColors and AppTheme

import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../data/product_model.dart';
import 'widgets/product_image_banner.dart';
import 'widgets/product_title_price.dart';
import 'widgets/section_text.dart';
import 'widgets/featured_product_banner.dart';

class ProductPage extends StatefulWidget {
  final ProductModel product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedVariantIndex = 0;

  final TextEditingController _pincodeController = TextEditingController();
  final RxBool _isCheckingDelivery = false.obs;
  final RxString _deliveryStatusMessage = ''.obs;
  final RxBool _isDeliverable = false.obs;

  final CartController cartController = Get.find<CartController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  final RxInt _currentVariantStock = 0.obs;
  final RxString _currentSelectedVariantName = ''.obs;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      selectedVariantIndex = 0;
      _currentSelectedVariantName.value = widget.product.variants.keys.elementAt(selectedVariantIndex);
    } else {
      // If no variants defined, default to a placeholder variant name and total stock
      _currentSelectedVariantName.value = 'Default Variant';
    }

    _pincodeController.addListener(_resetDeliveryStatus);

    _syncVariantData();
  }

  @override
  void dispose() {
    _pincodeController.removeListener(_resetDeliveryStatus);
    _pincodeController.dispose();
    super.dispose();
  }

  void _resetDeliveryStatus() {
    if (_deliveryStatusMessage.isNotEmpty) {
      _deliveryStatusMessage.value = '';
      _isDeliverable.value = false;
    }
  }

  void onVariantSelected(int index) {
    setState(() {
      selectedVariantIndex = index;
      _currentSelectedVariantName.value = widget.product.variants.keys.elementAt(selectedVariantIndex);
      _syncVariantData();
    });
  }

  void _syncVariantData() {
    if (widget.product.variants.isNotEmpty && selectedVariantIndex < widget.product.variants.length) {
      final variantKey = widget.product.variants.keys.elementAt(selectedVariantIndex);
      // Correct: Direct use of int value as stock (as per your current ProductModel)
      _currentVariantStock.value = widget.product.variants[variantKey] ?? 0;
    } else {
      // For products without explicit variants, use totalStock as the only stock
      _currentVariantStock.value = widget.product.totalStock;
    }
  }


  Future<void> _incrementQuantity() async {
    final String productId = widget.product.id.toString();
    final String variantName = _currentSelectedVariantName.value;

    final quantityInCart = cartController.getVariantQuantity(
      productId: productId,
      variantName: variantName,
    );

    if (cartController.isLoading.value || _currentVariantStock.value <= quantityInCart) {
      if (_currentVariantStock.value <= quantityInCart) {
        Get.snackbar(
          'Limit Reached',
          'You have reached the maximum available quantity for this variant or it\'s out of stock.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          animationDuration: const Duration(milliseconds: 300),
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    cartController.isLoading.value = true;
    try {
      await cartController.addToCart(productId: productId, variantName: variantName);
    } finally {
      cartController.isLoading.value = false;
    }
  }

  Future<void> _decrementQuantity() async {
    final String productId = widget.product.id.toString();
    final String variantName = _currentSelectedVariantName.value;

    final quantityInCart = cartController.getVariantQuantity(
      productId: productId,
      variantName: variantName,
    );

    if (quantityInCart <= 0 || cartController.isLoading.value) return;

    cartController.isLoading.value = true;
    try {
      await cartController.removeFromCart(productId: productId, variantName: variantName);
    } finally {
      cartController.isLoading.value = false;
    }
  }




  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final originalPrice = product.sellingPrice.isNotEmpty
        ? product.sellingPrice.first.price
        : 0;
    final discountedPrice = product.sellingPrice.length > 1
        ? product.sellingPrice[1].price
        : originalPrice;

    final variantNames = product.variants.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Obx(() {
                      final isFavorite = wishlistController.wishlist.any((p) => p.id == product.id);
                      return ProductImageBanner(
                        imageUrls: product.images,
                        badgeText: "20% OFF",
                        isFavorite: isFavorite,
                        onBack: () => Get.back(),
                        onFavorite: () {
                          if (isFavorite) {
                            wishlistController.removeFromWishlist(product.id);
                          } else {
                            wishlistController.addToWishlist(product.id.toString());
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Product price displayed here will *not* change with variant selection
                  // because your ProductModel's variants map only contains stock (int), not price.
                  ProductTitleAndPrice(
                    title: product.fullName,
                    originalPrice: originalPrice.toDouble(),
                    discountedPrice: discountedPrice.toDouble(),
                  ),
                  const SizedBox(height: 12),

                  if (variantNames.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Variant',
                          style: textTheme.titleMedium?.copyWith(color: AppColors.textDark),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List<Widget>.generate(variantNames.length, (index) {
                            final isSelected = selectedVariantIndex == index;
                            final variantStockValue = product.variants[variantNames[index]] ?? 0; // Directly get the int stock

                            // CORRECTED: isVariantOutOfStock check (same as before)
                            final isVariantOutOfStock = variantStockValue <= 0;

                            return ChoiceChip(
                              label: Text(
                                variantNames[index] + (isVariantOutOfStock ? ' (Out of Stock)' : ''),
                              ),
                              selected: isSelected,
                              onSelected: isVariantOutOfStock ? null : (selected) {
                                if (selected) {
                                  onVariantSelected(index);
                                }
                              },
                              selectedColor: AppColors.primaryPurple,
                              backgroundColor: isVariantOutOfStock ? AppColors.danger.withOpacity(0.1) : AppColors.lightPurple.withOpacity(0.4),
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isVariantOutOfStock ? AppColors.danger : AppColors.textDark),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              elevation: isSelected ? 3 : 1,
                              pressElevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : (isVariantOutOfStock ? AppColors.danger.withOpacity(0.5) : AppColors.lightPurple),
                                  width: 1,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  SectionText(
                    title: 'Product Description',
                    content: product.description.isNotEmpty
                        ? product.description
                        : 'No detailed description is available for this product. This product offers cutting-edge technology and superior performance, designed to meet your everyday needs with efficiency and style. Enjoy seamless integration and robust features that enhance your overall user experience.',
                  ),
                  const SizedBox(height: 24),

                  // Key Information - Weight is still N/A as it's not in your Map<String, int>
                  SectionText(
                    title: 'Key Information',
                    content: 'Weight: N/A (Variant weight not available with current data structure)\n' // Weight remains N/A
                        'SKU: ${product.id}\n'
                        'Availability: ${(_currentVariantStock.value > 0) ? 'In Stock' : 'Out of Stock'}\n'
                        'Material: High-Quality Components',
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'You might also like',
                    style: textTheme.headlineMedium?.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    color: AppColors.neutralBackground.withOpacity(0.8),
                    alignment: Alignment.center,
                    child: Text('Placeholder for "You might also like" products', style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight)),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Featured Offer',
                    style: textTheme.headlineMedium?.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FeaturedProductBanner(
                      imageUrl: product.images.length > 1 && product.images[1] is String
                          ? product.images[1].toString()
                          : 'https://via.placeholder.com/400x200?text=Featured+Product',
                    ),
                  ),
                  const SizedBox(height: 48),

                  Text(
                    'Explore More Categories',
                    style: textTheme.headlineMedium?.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    color: AppColors.neutralBackground.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: Text('Placeholder for Shop by Category / GroupGridSection', style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomCartBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCartBar(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final product = widget.product;

    return Obx(() {
      final quantityInCartForSelectedVariant = cartController.getVariantQuantity(
        productId: product.id,
        variantName: _currentSelectedVariantName.value,
      );
      final bool isBusy = cartController.isLoading.value;
      final bool isOutOfStock = _currentVariantStock.value <= 0;

      final bool isInCart = quantityInCartForSelectedVariant > 0;
      final bool canIncrement = quantityInCartForSelectedVariant < _currentVariantStock.value && !isBusy;
      final bool canDecrement = quantityInCartForSelectedVariant > 0 && !isBusy;


      return Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final totalItems = cartController.totalCartItemsCount;
              final totalValue = cartController.totalCartValue;
              if (totalItems == 0) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$totalItems Items',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMedium)),
                  Text('₹${totalValue.toStringAsFixed(0)}',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ],
              );
            }),

            if (isOutOfStock)
              Expanded(
                child: Center(
                  child: Text(
                    'Out of Stock',
                    style: textTheme.titleMedium?.copyWith(color: AppColors.danger),
                  ),
                ),
              )
            else if (!isInCart)
            // Adjusted 'Add' button size here
              SizedBox( // Use SizedBox to give it a fixed width
                width: 100, // Reduced width for the add button
                child: ElevatedButton(
                  onPressed: isBusy ? null : _incrementQuantity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10), // Reduced vertical padding
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap area
                  ),
                  child: isBusy
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : Text('Add', style: textTheme.titleMedium?.copyWith(color: Colors.white)),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      context: context,
                      icon: Icons.remove,
                      onTap: canDecrement ? _decrementQuantity : null,
                      isDisabled: !canDecrement,
                      isLoading: isBusy && (quantityInCartForSelectedVariant == 1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$quantityInCartForSelectedVariant',
                      style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    _buildQuantityButton(
                      context: context,
                      icon: Icons.add,
                      onTap: canIncrement ? _incrementQuantity : null,
                      isDisabled: !canIncrement,
                      isLoading: isBusy && (quantityInCartForSelectedVariant < _currentVariantStock.value),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onTap,
    required bool isDisabled,
    required bool isLoading,
  }) {
    final Color buttonColor = AppColors.success;
    final Color iconColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDisabled ? buttonColor.withOpacity(0.5) : buttonColor,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        )
            : Icon(
          icon,
          size: 18,
          color: isDisabled ? iconColor.withOpacity(0.5) : iconColor,
        ),
      ),
    );
  }
}