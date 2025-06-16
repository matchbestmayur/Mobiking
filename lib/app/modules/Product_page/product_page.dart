import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Assuming AppColors is accessible from app_theme.dart if you uncomment it
// import 'package:mobiking/app/themes/app_theme.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../data/product_model.dart';
// import '../../dummy/products_data.dart'; // This line seems to be for dummy data, likely not needed in production
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

  // Removed _isIncrementing and _isDecrementing local bools.
  // We'll rely solely on cartController.isLoading.

  final TextEditingController _pincodeController = TextEditingController();
  final RxBool _isCheckingDelivery = false.obs;
  final RxString _deliveryStatusMessage = ''.obs;
  final RxBool _isDeliverable = false.obs;

  // Initialize controllers using Get.find()
  final CartController cartController = Get.find<CartController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  final RxInt _currentVariantStock = 0.obs;
  final RxString _currentSelectedVariantName = ''.obs; // Reactive variable for currently selected variant name

  @override
  void initState() {
    super.initState();
    // Initialize selected variant and its name
    if (widget.product.variants.isNotEmpty) {
      selectedVariantIndex = 0;
      _currentSelectedVariantName.value = widget.product.variants.keys.elementAt(selectedVariantIndex);
    } else {
      _currentSelectedVariantName.value = 'Default Variant'; // Fallback if no variants
    }

    _pincodeController.addListener(_resetDeliveryStatus);

    _syncVariantStock(); // Initial sync of stock for the default/selected variant

    // No need for explicit 'ever' here. The Obx widgets will react to cartController.cartData directly.
  }

  @override
  void dispose() {
    _pincodeController.removeListener(_resetDeliveryStatus);
    _pincodeController.dispose();
    super.dispose();
  }

  // --- Helper Methods ---

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
      _syncVariantStock(); // Resync stock when variant changes
    });
  }

  void _syncVariantStock() {
    // Get the stock for the currently selected variant.
    // If the variant name doesn't exist in the map, default to 0.
    final stockForSelectedVariant = widget.product.variants[_currentSelectedVariantName.value] ?? 0;
    _currentVariantStock.value = stockForSelectedVariant;
  }

  Future<void> _incrementQuantity() async {
    final String productId = widget.product.id.toString();
    final String variantName = _currentSelectedVariantName.value;

    final quantityInCart = cartController.getVariantQuantity(
      productId: productId,
      variantName: variantName,
    );

    // Check if cart operation is already in progress or if stock limit is reached
    if (cartController.isLoading.value || _currentVariantStock.value <= quantityInCart) {
      if (_currentVariantStock.value <= quantityInCart) {
        Get.snackbar(
          'Limit Reached',
          'You have reached the maximum available quantity for this variant or it\'s out of stock.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
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

    // Set loading state in controller. This will trigger Obx rebuilds.
    cartController.isLoading.value = true;
    try {
      await cartController.addToCart(productId: productId, variantName: variantName);
    } finally {
      // Reset loading state in controller after operation
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

    // Only allow decrement if quantity is above 0 and not already processing
    if (quantityInCart <= 0 || cartController.isLoading.value) return;

    // Set loading state in controller. This will trigger Obx rebuilds.
    cartController.isLoading.value = true;
    try {
      await cartController.removeFromCart(productId: productId, variantName: variantName);
    } finally {
      // Reset loading state in controller after operation
      cartController.isLoading.value = false;
    }
  }

  Future<void> _checkDeliveryAvailability(String pincode) async {
    if (pincode.isEmpty || pincode.length < 6) {
      _deliveryStatusMessage.value = 'Please enter a valid 6-digit pincode.';
      _isDeliverable.value = false;
      return;
    }

    _isCheckingDelivery.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      // Simple dummy logic for delivery check
      final bool deliverable = pincode.startsWith('457');

      final DateTime now = DateTime.now();
      final DateTime expectedDelivery = now.add(const Duration(days: 1)); // Next day
      final String formattedDate = "${expectedDelivery.day}/${expectedDelivery.month}/${expectedDelivery.year}";

      if (deliverable) {
        _deliveryStatusMessage.value = 'Deliverable to $pincode. Expected by $formattedDate.';
        _isDeliverable.value = true;
      } else {
        _deliveryStatusMessage.value = 'Not deliverable to $pincode.';
        _isDeliverable.value = false;
      }
    } catch (e) {
      print('Delivery check error: $e'); // Debug print
      _deliveryStatusMessage.value = 'Error checking delivery. Please try again.';
      _isDeliverable.value = false;
    } finally {
      _isCheckingDelivery.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final originalPrice = product.sellingPrice.isNotEmpty
        ? product.sellingPrice.first.price
        : 0;
    final discountedPrice = product.sellingPrice.length > 1
        ? product.sellingPrice[1].price
        : originalPrice;

    final variantNames = product.variants.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Product Image Banner with Wishlist integration ---
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Obx(() {
                  // Listen to wishlistController for changes in favorite status
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

              // --- Product Title and Price ---
              ProductTitleAndPrice(
                title: product.fullName,
                originalPrice: originalPrice.toDouble(),
                discountedPrice: discountedPrice.toDouble(),
              ),
              const SizedBox(height: 12),

              // --- Variant Selection (if variants exist) ---
              if (variantNames.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Variant',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List<Widget>.generate(variantNames.length, (index) {
                        final isSelected = selectedVariantIndex == index;
                        final variantStock = product.variants[variantNames[index]] ?? 0;
                        final isVariantOutOfStock = variantStock <= 0;

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
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: isVariantOutOfStock ? Colors.red.shade100 : Colors.grey[200],
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: isSelected
                                ? Colors.white
                                : (isVariantOutOfStock ? Colors.red.shade700 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          elevation: isSelected ? 3 : 1,
                          pressElevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : (isVariantOutOfStock ? Colors.red.shade400 : Colors.grey.shade400),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // --- Delivery Availability Check ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check Delivery Availability',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter pincode',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            counterText: '', // Hides the default maxLength counter
                          ),
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => ElevatedButton(
                        onPressed: _isCheckingDelivery.value || _pincodeController.text.length != 6
                            ? null // Disable if checking or pincode is not 6 digits
                            : () => _checkDeliveryAvailability(_pincodeController.text),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 50),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: _isCheckingDelivery.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                            : Text('Check', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      )),
                    ],
                  ),
                  Obx(() => _deliveryStatusMessage.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _deliveryStatusMessage.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _isDeliverable.value ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 20),

              // --- Quantity Controls and Add to Cart Button ---
              Obx(() {
                // This entire section reacts to changes in _currentVariantStock and cartController.cartData
                if (_currentVariantStock.value <= 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied_outlined, color: Colors.red.shade700, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Out of Stock for this variant!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get the current quantity of the selected variant in the cart
                final quantityInCartForSelectedVariant = cartController.getVariantQuantity(
                  productId: product.id,
                  variantName: _currentSelectedVariantName.value,
                );

                // Determine if buttons should be disabled based on loading state or quantity limits
                final bool isBusy = cartController.isLoading.value;
                final bool canDecrement = quantityInCartForSelectedVariant > 0 && !isBusy;
                final bool canIncrement = quantityInCartForSelectedVariant < _currentVariantStock.value && !isBusy;


                return Row(
                  children: [
                    // Decrement Button
                    InkWell(
                      onTap: canDecrement ? _decrementQuantity : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: canDecrement ? Colors.grey[200] : Colors.grey[300], // Visual cue for disabled
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isBusy // Show loading if any cart operation is busy
                            ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blueAccent),
                          ),
                        )
                            : const Icon(Icons.remove, size: 24, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Display Current Quantity in Cart
                    Text(
                      '$quantityInCartForSelectedVariant',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const SizedBox(width: 16),

                    // Increment Button
                    InkWell(
                      onTap: canIncrement ? _incrementQuantity : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: canIncrement ? Colors.grey[200] : Colors.grey[300], // Visual cue for disabled
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isBusy // Show loading if any cart operation is busy
                            ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blueAccent),
                          ),
                        )
                            : const Icon(Icons.add, size: 24, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Add to Cart / Update Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy
                            ? null // Disable button if cart operation is in progress
                            : () async {
                          // If quantity is 0, add to cart
                          if (quantityInCartForSelectedVariant == 0) {
                            await _incrementQuantity(); // Use the existing increment logic
                          }
                          // If already in cart, the +/- buttons handle updates.
                          // The "Add to Cart" button effectively becomes a "view cart" or "update"
                          // action if items are already present.
                          // For simplicity, we can also disable it or make it do nothing if quantity > 0
                          // unless you want it to navigate to cart.
                          // For this context, it will just not re-increment if quantity > 0
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: isBusy
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : Text(
                          // Dynamically change button text
                          quantityInCartForSelectedVariant > 0 ? 'Update Cart' : 'Add to Cart',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // --- Product Description ---
              SectionText(
                title: 'Product Description',
                content: product.description.isNotEmpty
                    ? product.description
                    : 'No detailed description is available for this product. This product offers cutting-edge technology and superior performance, designed to meet your everyday needs with efficiency and style. Enjoy seamless integration and robust features that enhance your overall user experience.',
              ),
              const SizedBox(height: 24),

              // --- Key Information (Specifications) ---
              SectionText(
                title: 'Key Information',
                content: // Assuming product has a brand property
                'Weight: ${product.variants.entries.isNotEmpty ? product.variants.entries.first.key : 'N/A'}\n' // This might be a placeholder for a specific variant weight, adjust as needed
                    'SKU: ${product.id}\n'
                    'Availability: ${(_currentVariantStock.value > 0) ? 'In Stock' : 'Out of Stock'}\n'
                    'Material: High-Quality Components',
              ),
              const SizedBox(height: 32),

              // --- "You might also like" section ---
              Text(
                'You might also like',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              // Placeholder for related products list/grid
              Container(
                height: 150,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: Text('Placeholder for "You might also like" products', style: GoogleFonts.poppins(color: Colors.grey[700])),
              ),

              const SizedBox(height: 32),

              // --- Featured Offer ---
              Text(
                'Featured Offer',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FeaturedProductBanner(
                  imageUrl: product.images.length > 1
                      ? product.images[1] // Use second image if available, else a placeholder
                      : 'https://via.placeholder.com/400x200?text=Featured+Product',
                ),
              ),
              const SizedBox(height: 48),

              // --- "Explore More Categories" section ---
              Text(
                'Explore More Categories',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              // Placeholder for category grid
              Container(
                height: 200,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Text('Placeholder for Shop by Category / GroupGridSection', style: GoogleFonts.poppins(color: Colors.grey[700])),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}