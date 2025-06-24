import 'package:flutter/material.dart'; // Keep for Colors, IconData
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {

  RxMap<String, dynamic> cartData = <String, dynamic>{}.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  // --- REMOVED: All animation-related fields and methods ---


  @override
  void onInit() {
    super.onInit();
    loadCartData();
  }

  // --- Core Cart Data Loading ---
  void loadCartData() {
    print('🛒 CartController: Attempting to load cart data from storage...');
    try {
      final Map<String, dynamic>? user = box.read('user');

      if (user != null && user.containsKey('cart') && user['cart'] is Map) {
        cartData.value = Map<String, dynamic>.from(user['cart']);
        print('🛒 CartController: Cart data loaded from storage: ${cartData.value}');
      } else {
        // Initialize an empty cart if no valid data is found
        cartData.value = {
          'items': [],
          'totalCartValue': 0.0,
        };
        print('🛒 CartController: No valid cart data found in stored user object, initializing to empty structure.');
      }
    } catch (e) {
      print('🛒 CartController: Error loading cart data from storage: $e');
      // Fallback to empty cart on error
      cartData.value = {
        'items': [],
        'totalCartValue': 0.0,
      };
    }
    print('🛒 CartController: Current totalCartItemsCount after loadData: ${totalCartItemsCount}'); // Added print for clarity
  }

  // --- Getters for Cart Data ---
  List<Map<String, dynamic>> get cartItems {
    try {
      // Ensure 'items' key exists and is a List
      if (cartData.containsKey('items') && cartData['items'] is List) {
        return (cartData['items'] as List).map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return []; // Return empty list if 'items' is missing or not a List
    } catch (e) {
      print('🛒 CartController: Error getting cartItems: $e');
      return [];
    }
  }

  Map<String, int> getCartItemsForProduct({required String productId}) {
    final Map<String, int> productVariantsInCart = {};
    for (var item in cartItems) {
      final itemProductId = item['productId']?['_id'];
      if (itemProductId == productId) {
        final itemVariantName = item['variantName'] as String? ?? 'Default'; // Use 'Default' or handle as needed
        final int quantity = item['quantity'] as int? ?? 0;
        if (quantity > 0) {
          productVariantsInCart[itemVariantName] = quantity;
        }
      }
    }
    print('🛒 CartController: Variants in cart for product $productId: $productVariantsInCart');
    return productVariantsInCart;
  }

  int getVariantQuantity({required String productId, required String variantName}) {
    for (var item in cartItems) {
      final itemProductId = item['productId']?['_id'];
      final itemVariantName = item['variantName'];

      if (itemProductId == productId && itemVariantName == variantName) {
        final int quantity = item['quantity'] as int? ?? 0; // **Directly reading 'quantity'**
        print('🛒 CartController: Found quantity for ProductID: $productId, Variant: $variantName -> $quantity');
        return quantity;
      }
    }
    print('🛒 CartController: No item found for ProductID: $productId, Variant: $variantName. Quantity -> 0');
    return 0; // Return 0 if the item is not found in the cart
  }

  int getTotalQuantityForProduct({required String productId}) {
    int totalQuantity = 0;
    for (var item in cartItems) {
      final itemProductId = item['productId']?['_id'];
      if (itemProductId == productId) {
        totalQuantity += item['quantity'] as int? ?? 0; // **Summing 'quantity' directly**
      }
    }
    print('🛒 CartController: Calculated total quantity for product $productId -> $totalQuantity');
    return totalQuantity;
  }

  int get totalCartItemsCount {
    int totalCount = 0;
    for (var item in cartItems) {
      totalCount += item['quantity'] as int? ?? 0; // **Summing 'quantity' directly**
    }
    print('🛒 CartController: Calculating totalCartItemsCount (sum of quantities from backend): $totalCount');
    return totalCount;
  }

  double get totalCartValue {
    double total = 0.0;
    for (var item in cartItems) {
      final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
      final int itemQuantity = item['quantity'] as int? ?? 0;
      total += itemPrice * itemQuantity; // **Multiplying price by 'quantity'**
    }
    print('🛒 CartController: Calculating totalCartValue (frontend from backend data): $total');
    return total;
  }

  // --- Cart Operations ---
  // MODIFIED: Removed animation-related parameters from addToCart
  Future<bool> addToCart({
    required String productId,
    required String variantName,
  }) async {
    final cartId = box.read('cartId');
    if (cartId == null) {
      _showSnackbar('Cart Error', 'Could not find your cart ID. Please log in again.', Colors.red, Icons.shopping_cart_outlined);
      return false;
    }
    print('🛒 CartController: Adding to cart: productId=$productId, variantName=$variantName, cartId=$cartId');

    isLoading.value = true; // Start loading state
    try {
      final response = await CartService().addToCart(
        productId: productId,
        cartId: cartId,
        variantName: variantName,
      );

      if (response['success'] == true) {
        await _updateStorageAndCartData(response);
        _showSnackbar('Added to Cart', 'Product quantity increased successfully!', Colors.green, Icons.add_shopping_cart_outlined);
        return true;
      } else {
        _showSnackbar('Add to Cart Failed', response['message'] ?? 'Could not add product to cart.', Colors.orange, Icons.error_outline);
        return false;
      }
    } catch (e) {
      print("🛒 CartController: Add to cart error: $e");
      _showSnackbar('Cart Error', 'Something went wrong while adding to cart. Please try again.', Colors.red, Icons.cloud_off_outlined);
      return false;
    } finally {
      isLoading.value = false; // End loading state
    }
  }

  Future<void> removeFromCart({
    required String productId,
    required String variantName,
  }) async {
    final cartId = box.read('cartId');
    if (cartId == null) {
      _showSnackbar('Cart Error', 'Could not find your cart ID. Please log in again.', Colors.red, Icons.shopping_cart_outlined);
      return;
    }
    print('🛒 CartController: Removing from cart: productId=$productId, variantName=$variantName, cartId=$cartId');

    isLoading.value = true; // Start loading state
    try {
      final response = await CartService().removeFromCart(
        productId: productId,
        cartId: cartId,
        variantName: variantName,
      );

      if (response['success'] == true) {
        await _updateStorageAndCartData(response);
        _showSnackbar('Removed from Cart', 'Product quantity decreased successfully!', Colors.blueGrey, Icons.remove_shopping_cart_outlined);
      } else {
        _showSnackbar('Remove Failed', response['message'] ?? 'Could not remove product from cart.', Colors.orange, Icons.error_outline);
      }
    } catch (e) {
      print("🛒 CartController: Remove from cart error: $e");
      _showSnackbar('Cart Error', 'Something went wrong while removing from cart. Please try again.', Colors.red, Icons.cloud_off_outlined);
    } finally {
      isLoading.value = false; // End loading state
    }
  }

  Future<void> _updateStorageAndCartData(Map<String, dynamic> apiResponse) async {
    print('🛒 CartController: Starting _updateStorageAndCartData...');
    print('🛒 CartController: Full API Response for cart update: $apiResponse');

    final updatedUser = apiResponse['data']?['user'];
    print('🛒 CartController: Extracted updatedUser from response: $updatedUser');

    if (updatedUser != null && updatedUser is Map) {
      // Store the entire updated user object, which includes the cart
      await box.write('user', updatedUser);
      print('🛒 CartController: Stored updated user object directly to "user" key in GetStorage.');

      final updatedCart = updatedUser['cart'];
      if (updatedCart != null && updatedCart is Map) {
        cartData.value = Map<String, dynamic>.from(updatedCart);
        print('🛒 CartController: Updated cartData.value observable with latest cart: ${cartData.value}');
      } else {
        // Fallback: If 'cart' is missing or invalid in the updated user, reset local cart.
        _resetLocalCartData();
        print('🛒 CartController: Warning: Updated user object from API did not contain a valid "cart". Local cartData reset.');
      }
    } else {
      // Fallback: If 'user' itself is missing or invalid, reset local cart.
      _resetLocalCartData();
      print('🛒 CartController: Warning: No updated user data (apiResponse[\'data\'][\'user\']) in cart response. Local cartData reset.');
    }
  }

  // Helper to reset cartData to an empty structure
  void _resetLocalCartData() {
    cartData.value = {
      'items': [],
      'totalCartValue': 0.0,
    };
  }

  void clearCartData() async {
    print('🛒 CartController: Clearing cart data...');

    // Update the stored user object with an empty cart
    var userInStorage = box.read('user');
    if (userInStorage != null && userInStorage is Map) {
      userInStorage['cart'] = {'items': [], 'totalCartValue': 0.0}; // Explicitly set 'cart' to an empty structure
      await box.write('user', userInStorage);
      print('🛒 CartController: Stored user object in GetStorage updated with cleared cart.');
    } else {
      // If no user object, just ensure a minimal cart structure is set in storage
      await box.write('user', {'cart': {'items': [], 'totalCartValue': 0.0}});
      print('🛒 CartController: No existing user/cart in storage, set to empty cart in storage.');
    }

    // Reset the local reactive cartData
    _resetLocalCartData();
    print('🛒 CartController: Local cartData observable cleared.');

    _showSnackbar('Cart Cleared', 'All items have been removed from your cart.', Colors.blue, Icons.delete_sweep_outlined);
  }

  // --- UI Feedback ---
  void _showSnackbar(String title, String message, Color color, IconData icon) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.8),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
    );
  }
}