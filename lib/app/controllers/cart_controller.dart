import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {
  RxMap<String, dynamic> cartData = <String, dynamic>{}.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadCartData();
  }

  void loadCartData() {
    final userData = box.read('userData');
    print('Loaded user data: $userData');

    try {
      final cart = userData?['data']?['user']?['cart'];
      if (cart != null) {
        cartData.value = Map<String, dynamic>.from(cart);
        print('Cart data loaded: ${cartData.value}');
      } else {
        cartData.value = {};
      }
    } catch (e) {
      print('Error loading cart data: $e');
      cartData.value = {};
    }
  }

  Future<void> addToCart({
    required String productId,
    required String variantName,
  }) async {
    final userId = box.read('userData')?['data']?['user']?['_id'];
    if (userId == null) {
      Get.snackbar("Error", "User ID not found. Please login again.");
      return;
    }

    try {
      final response = await CartService().addToCart(
        productId: productId,
        cartId: userId,
        variantName: variantName,
      );
      print("Add to cart response: $response");

      if (response['success'] == true) {
        final updatedCart = response['data']?['user']?['cart'];
        if (updatedCart != null) {
          cartData.value = Map<String, dynamic>.from(updatedCart);

          // Optional: Save updated userData if needed
          var storedUserData = box.read('userData');
          if (storedUserData != null) {
            storedUserData['data']['user']['cart'] = updatedCart;
            box.write('userData', storedUserData);
          }

          Get.snackbar("Success", "Product added to cart");
        } else {
          cartData.value = {};
        }
      } else {
        Get.snackbar("Error", "Failed to add product to cart");
      }
    } catch (e) {
      print("Add to cart error: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }

  double get totalCartValue {
    try {
      return (cartData.value['totalCartValue'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  List<dynamic> get cartItems {
    try {
      return List<dynamic>.from(cartData.value['items'] ?? []);
    } catch (e) {
      return [];
    }
  }
}
