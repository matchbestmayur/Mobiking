import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Import your data models
import '../data/AddressModel.dart'; // Correct path assumed
// IMPORTANT: Ensure this import points to your CreateOrderRequestModel

import '../data/Order_get_data.dart';
import '../data/order_model.dart'; // The full OrderModel (Response Model)
// You might still use ProductModel for cart item structure, so keeping it
import '../data/product_model.dart'; // If you still use ProductModel for cart item structure

// Import your controllers and services
import '../controllers/cart_controller.dart';
import '../controllers/address_controller.dart';
import '../data/razor_pay.dart';
import '../modules/bottombar/Bottom_bar.dart' show MainContainerScreen;
import '../services/order_service.dart';
import '../modules/home/home_screen.dart'; // Or your order success screen
import '../themes/app_theme.dart';

// Helper function for themed snackbars (ensure this is defined once and accessible)
void _showModernSnackbar(String title, String message, {
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  SnackPosition snackPosition = SnackPosition.TOP,
  Duration? duration,
  EdgeInsets? margin,
  double? borderRadius,
  bool isError = false,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: snackPosition,
    backgroundColor: backgroundColor ?? (isError ? AppColors.danger : AppColors.primaryPurple),
    colorText: textColor ?? Colors.white,
    icon: icon != null ? Icon(icon, color: textColor ?? Colors.white) : null,
    margin: margin ?? const EdgeInsets.all(16),
    borderRadius: borderRadius ?? 12,
    animationDuration: const Duration(milliseconds: 300),
    duration: duration ?? const Duration(seconds: 3),
  );
}

class OrderController extends GetxController {
  final GetStorage _box = GetStorage();
  final OrderService _orderService = Get.find<OrderService>(); // Assuming OrderService is already registered

  final CartController _cartController = Get.find<CartController>();
  final AddressController _addressController = Get.find<AddressController>();

  var isLoading = false.obs;
  var orderHistory = <OrderModel>[].obs; // This list holds the FULL OrderModel (response)

  var isLoadingOrderHistory = false.obs;
  var orderHistoryErrorMessage = ''.obs;
  late Razorpay _razorpay;

  // Variables to hold order IDs during the online payment flow
  // These will be populated from the backend's initiate response and used for verification.
  String? _currentBackendOrderId; // Your app's internal order ID
  String? _currentRazorpayOrderId; // Razorpay's order ID

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
    // Initialize Razorpay and register listeners
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print('Razorpay initialized and listeners registered.');
  }

  /// Calculates the subtotal of items in the cart.
  double _calculateSubtotal() {
    return _cartController.cartItems.fold(0.0, (sum, item) {
      final productData = item['productId'] as Map<String, dynamic>?;
      if (productData != null && productData.containsKey('sellingPrice') && productData['sellingPrice'] is List) {
        final List sellingPrices = productData['sellingPrice'];
        if (sellingPrices.isNotEmpty && sellingPrices[0] is Map<String, dynamic>) {
          final double price = (sellingPrices[0]['price'] as num?)?.toDouble() ?? 0.0;
          final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;
          return sum + (price * quantity);
        }
      }
      return sum;
    });
  }




  @override
  void onClose() {
    // Clear Razorpay listeners to prevent memory leaks
    _razorpay.clear();
    print('Razorpay listeners cleared.');
    super.onClose();
  }

  // --- Razorpay Payment Callbacks ---
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Razorpay Payment Success: ${response.paymentId}, ${response.orderId}, ${response.signature}');
    // Keep loading indicator active during verification
    isLoading.value = true;
    try {
      if (_currentBackendOrderId == null || _currentRazorpayOrderId == null) {
        _showModernSnackbar(
          'Payment Success, but data missing!',
          'Could not retrieve backend order data for verification. Please contact support with Payment ID: ${response.paymentId}',
          isError: true,
          icon: Icons.error_outline,
          backgroundColor: Colors.orange.shade700,
        );
        return;
      }

      // 1. Prepare verification request
      final verifyRequest = RazorpayVerifyRequest(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!, // This is Razorpay's order ID
        razorpaySignature: response.signature!,
        orderId: _currentBackendOrderId!, // This is YOUR backend's order ID
      );

      // 2. Call backend to verify the payment
      print('Calling backend for payment verification...');
      final verifiedOrder = await _orderService.verifyRazorpayPayment(verifyRequest);
      print('Backend verification successful for order: ${verifiedOrder.orderId}');

      // 3. If verification is successful, finalize the order on the client side
      await _box.write('last_placed_order', verifiedOrder.toJson());
      _cartController.clearCartData(); // Clear cart after successful order and verification

      _showModernSnackbar(
        'Order Placed!',
        'Your order ID ${verifiedOrder.orderId ?? 'N/A'} has been placed successfully!',
        isError: false,
        icon: Icons.receipt_long_outlined,
        backgroundColor: Colors.green.shade600,
        snackPosition: SnackPosition.TOP,
      );
      // Navigate to home or order success screen
      Get.offAll(() => MainContainerScreen());

    } on OrderServiceException catch (e) {
      _showModernSnackbar(
        'Payment Verification Failed!',
        e.message,
        isError: true,
        icon: Icons.cancel_outlined,
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.TOP,
      );
      print('Razorpay Verification Service Error: Status ${e.statusCode} - Message: ${e.message}');
    } catch (e) {
      _showModernSnackbar(
        'Payment Verification Error!',
        'An unexpected error occurred during payment verification: $e',
        isError: true,
        icon: Icons.cloud_off_outlined,
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.TOP,
      );
      print('Razorpay Verification Unexpected Error: $e');
    } finally {
      isLoading.value = false; // Always set to false after verification attempt
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Payment Error: Code ${response.code} - Description: ${response.message}');
    isLoading.value = false; // Stop loading on payment error
    _showModernSnackbar(
      'Payment Failed!',
      'Code: ${response.code}\nDescription: ${response.message}',
      isError: true,
      icon: Icons.payments,
      backgroundColor: Colors.red.shade700,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet Selected: ${response.walletName}');
    // Optionally provide user feedback or specific handling for external wallets
    _showModernSnackbar(
      'External Wallet Selected!',
      'Wallet: ${response.walletName ?? 'Unknown'}',
      isError: false,
      icon: Icons.account_balance_wallet_outlined,
      backgroundColor: Colors.blue.shade400,
      snackPosition: SnackPosition.TOP,
    );
  }

  // --- Main placeOrder method ---
  Future<void> placeOrder({required String method}) async {
    // Reset any previous order IDs
    _currentBackendOrderId = null;
    _currentRazorpayOrderId = null;

    // 1. Cart Empty Validation
    if (_cartController.cartItems.isEmpty) {
      _showModernSnackbar(
        'Cart Empty!',
        'Your cart is empty. Please add items before placing an order.',
        isError: true,
        icon: Icons.shopping_cart_outlined,
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // 2. Address Selection Validation
    final AddressModel? address = _addressController.selectedAddress.value;
    if (address == null) {
      _showModernSnackbar(
        'Address Required!',
        'Please select a shipping address to proceed.',
        isError: true,
        icon: Icons.location_off_outlined,
        backgroundColor: Colors.amber.shade700,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // 3. User Info Validation & Prompt
    Map<String, dynamic> user = Map<String, dynamic>.from(_box.read('user') ?? {});
    String? userId = user['_id'];
    String? name = user['name'];
    String? email = user['email'];
    String? phone = user['phoneNo'] ?? user['phone'];

    bool userInfoIncomplete = [userId, name, email, phone].any((e) => e == null || e.toString().trim().isEmpty);

    if (userInfoIncomplete) {
      final bool detailsConfirmed = await _promptUserInfo(); // Await the result

      if (!detailsConfirmed) {
        _showModernSnackbar(
          'Details Not Saved',
          'User details were not updated. Please fill them out to proceed with your order.',
          icon: Icons.info_outline_rounded,
          backgroundColor: AppColors.textLight.withOpacity(0.8),
          isError: false,
          snackPosition: SnackPosition.TOP,
        );
        return; // Stop the order placement process
      }

      // Re-read updated user info AFTER the prompt (if it was confirmed)
      user = Map<String, dynamic>.from(_box.read('user') ?? {});
      userId = user['_id'];
      name = user['name'];
      email = user['email'];
      phone = user['phoneNo'] ?? user['phone'];

      // Fallback double-check (should pass if detailsConfirmed was true)
      if ([userId, name, email, phone].any((e) => e == null || e.toString().trim().isEmpty)) {
        _showModernSnackbar(
          'User Info Incomplete!',
          'Despite confirming, some profile details are still missing. Please try again.',
          isError: true,
          icon: Icons.person_off_outlined,
          backgroundColor: Colors.red.shade400,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }

    // 4. Cart ID Validation
    final cartId = _cartController.cartData['_id'];
    if (cartId == null) {
      _showModernSnackbar(
        'Cart Error!',
        'Could not find your cart ID. Please try again or re-add items.',
        isError: true,
        icon: Icons.shopping_cart_checkout_outlined,
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Construct CreateUserReferenceRequestModel for the request
    final CreateUserReferenceRequestModel userRefRequest = CreateUserReferenceRequestModel(
      id: userId!,
      email: email!,
      phoneNo: phone!,
    );

    // Calculate financials
    final double subtotal = _calculateSubtotal();
    const double deliveryCharge = 45.0; // Assuming fixed delivery charge
    final double gst = (subtotal + deliveryCharge) * 0.18; // 18% GST on subtotal + delivery
    final double total = subtotal + deliveryCharge + gst;

    // Prepare list of CreateOrderItemRequestModel from cart items
    final List<CreateOrderItemRequestModel> orderItemsRequest = [];
    for (var cartItem in _cartController.cartItems) {
      final productData = cartItem['productId'] as Map<String, dynamic>?;
      final variantName = cartItem['variantName'] as String? ?? 'Default';
      final quantity = (cartItem['quantity'] as num?)?.toInt() ?? 1;

      if (productData == null) {
        print('Error: Product data is null for cart item: $cartItem');
        continue;
      }

      final String productIdString = productData['_id'] as String? ?? '';
      if (productIdString.isEmpty) {
        print('Error: Product ID missing for cart item: $cartItem');
        continue;
      }

      double itemPrice = 0.0;
      if (productData.containsKey('sellingPrice') && productData['sellingPrice'] is List) {
        final List sellingPrices = productData['sellingPrice'];
        if (sellingPrices.isNotEmpty && sellingPrices[0] is Map<String, dynamic>) {
          itemPrice = (sellingPrices[0]['price'] as num?)?.toDouble() ?? 0.0;
        }
      }

      orderItemsRequest.add(CreateOrderItemRequestModel(
        productId: productIdString,
        variantName: variantName,
        quantity: quantity,
        price: itemPrice,
      ));
    }

    final AddressController addressController = Get.find<AddressController>();
    String? addressId;
    if (addressController.selectedAddress.value != null) {
      addressId = addressController.selectedAddress.value!.id;
    }

    // Construct the CreateOrderRequestModel to send to the backend
    final createOrderRequest = CreateOrderRequestModel(
      userId: userRefRequest,
      cartId: cartId,
      name: name!,
      email: email!,
      phoneNo: phone!,
      orderAmount: total,
      discount: 0,
      deliveryCharge: deliveryCharge,
      gst: gst,
      subtotal: subtotal,
      address: '${address.street}, ${address.city}, ${address.state}, ${address.pinCode}',
      method: method,
      items: orderItemsRequest,
      addressId: addressId,
    );

    isLoading.value = true; // Start loading for any payment method

    try {
      if (method == 'COD') {
        final createdOrder = await _orderService.placeCodOrder(createOrderRequest);

        // COD order is immediately "placed" by backend, so finalize here
        await _box.write('last_placed_order', createdOrder.toJson());
        _cartController.clearCartData();

        _showModernSnackbar(
          'Order Placed!',
          'Your order ID ${createdOrder.orderId ?? 'N/A'} has been placed successfully!',
          isError: false,
          icon: Icons.receipt_long_outlined,
          backgroundColor: Colors.green.shade600,
          snackPosition: SnackPosition.TOP,
        );
        Get.offAll(() => MainContainerScreen()); // Navigate to home or order success screen
      } else if (method == 'Online') {
        print('Initiating online payment with backend...');
        final Map<String, dynamic> initiateResponse = await _orderService.initiateOnlineOrder(createOrderRequest);
        print('Backend initiate response: $initiateResponse');

        // Extract required data from the response for Razorpay
        final String? razorpayOrderId = initiateResponse['razorpayOrderId'] as String?;
        final int? amountInPaise = initiateResponse['amount'] as int?;
        final String? currency = initiateResponse['currency'] as String?;
        final String? razorpayKey = initiateResponse['key'] as String?;
        final String? newOrderId = initiateResponse['newOrderId'] as String?; // Your backend's order ID

        if (razorpayOrderId == null || amountInPaise == null || currency == null || razorpayKey == null || newOrderId == null) {
          throw OrderServiceException(
            'Missing essential Razorpay initiation data from backend.',
            statusCode: 500,
          );
        }

        // Store these for use in callbacks
        _currentBackendOrderId = newOrderId;
        _currentRazorpayOrderId = razorpayOrderId;

        // Prepare Razorpay options
        final Map<String, dynamic> options = {
          'key': razorpayKey, // Use the key from backend response
          'amount': amountInPaise, // Amount in smallest currency unit (e.g., paise for INR)
          'name': 'MobiKing E-commerce', // Your business name
          'description': 'Order from MobiKing', // Order description
          'order_id': _currentRazorpayOrderId, // Order ID obtained from your backend
          'currency': currency, // e.g., "INR"
          'prefill': {
            'email': email,
            'contact': phone,
          },
          'external': {
            'wallets': ['paytm', 'google_pay'], // Optional: Specify external wallets
          },
          'theme': {
            'color': '#3399FF' // Optional: Custom theme color
          },
        };
        print('Opening Razorpay checkout with options: $options');
        _razorpay.open(options);
        // Note: For online payments, isLoading remains true until _handlePaymentSuccess/_handlePaymentError completes.
        // Cart clear and navigation happen only after successful verification in _handlePaymentSuccess.

      } else {
        _showModernSnackbar(
          'Payment Method Invalid!',
          'The selected payment method is not currently supported.',
          isError: true,
          icon: Icons.not_interested_outlined,
          backgroundColor: Colors.red.shade400,
          snackPosition: SnackPosition.TOP,
        );
        return; // Exit if method is unsupported
      }
    } on OrderServiceException catch (e) {
      _showModernSnackbar(
        'Order Failed!',
        e.message,
        isError: true,
        icon: Icons.cancel_outlined,
        backgroundColor: Colors.orange.shade700,
        snackPosition: SnackPosition.TOP,
      );
      print('Place Order Service Error: Status ${e.statusCode} - Message: ${e.message}');
    } catch (e) {
      _showModernSnackbar(
        'Order Error!',
        'An unexpected client-side error occurred: $e. Please try again later.',
        isError: true,
        icon: Icons.cloud_off_outlined,
        backgroundColor: Colors.red.shade400,
        snackPosition: SnackPosition.TOP,
      );
      print('Place Order Unexpected Error: $e');
    } finally {
      // Only set isLoading to false here if it's a COD order or a general error occurred
      // For 'Online', isLoading is controlled by Razorpay callbacks.
      if (method == 'COD' || (method == 'Online' && (Get.isSnackbarOpen || !isLoading.value))) {
        isLoading.value = false;
      }
    }
  }

  // --- Helper Methods (ensure these are correctly defined in your controller) ---

  // Helper method for displaying snackbars
  void _showModernSnackbar(
      String title,
      String message, {
        required bool isError,
        required IconData icon,
        required Color backgroundColor,
        SnackPosition snackPosition = SnackPosition.BOTTOM,
      }) {
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }



  /// Fetches the user's order history from the backend.
  Future<void> fetchOrderHistory() async {
    isLoadingOrderHistory.value = true;
    orderHistoryErrorMessage.value = '';
    try {
      final List<OrderModel> fetchedOrders = await _orderService.getUserOrders();

      if (fetchedOrders.isNotEmpty) {
        // Sort by createdAt in descending order (most recent first)
        fetchedOrders.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
        orderHistory.assignAll(fetchedOrders);
        print('OrderController: Fetched ${orderHistory.length} orders successfully.');
      } else {
        orderHistory.clear();
        orderHistoryErrorMessage.value = 'No order history found.';
        _showModernSnackbar(
          'No Orders Yet',
          orderHistoryErrorMessage.value,
          isError: false,
          icon: Icons.shopping_bag_outlined,
          backgroundColor: Colors.blue.shade400,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on OrderServiceException catch (e) {
      orderHistory.clear();
      orderHistoryErrorMessage.value = e.message;
      _showModernSnackbar(
        'Order History Failed!',
        e.message,
        isError: true,
        icon: e.statusCode == 401
            ? Icons.login_outlined
            : (e.statusCode == 0 ? Icons.cloud_off_outlined : Icons.history_toggle_off_outlined),
        backgroundColor: e.statusCode == 401
            ? Colors.orange.shade700
            : (e.statusCode == 0 ? Colors.red.shade700 : Colors.red.shade400),
        snackPosition: SnackPosition.TOP,
      );
      print('OrderController: Order History Service Error: Status ${e.statusCode} - Message: ${e.message}');
    } catch (e) {
      orderHistory.clear();
      orderHistoryErrorMessage.value = 'An unexpected error occurred while processing orders: $e';
      _showModernSnackbar(
        'Critical Error',
        'An unexpected client-side error occurred: $e',
        isError: true,
        icon: Icons.bug_report_outlined,
        backgroundColor: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
      );
      print('OrderController: Unexpected Exception in fetchOrderHistory: $e');
    } finally {
      isLoadingOrderHistory.value = false;
    }
  }

  // _promptUserInfo remains the same as previously defined
  Future<bool> _promptUserInfo() async {
    final user = _box.read('user') ?? {};
    final RxString orderFor = (user['orderFor'] as String? ?? 'Self').obs;

    final TextEditingController nameController = TextEditingController(
        text: orderFor.value == 'Self' ? (user['name'] ?? '') : '');
    final TextEditingController phoneController = TextEditingController(text: user['phoneNo'] ?? user['phone'] ?? '');
    final TextEditingController emailController = TextEditingController(text: user['email'] ?? '');

    final bool? result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(Get.context!).unfocus();
          },
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            backgroundColor: Colors.transparent,
            child: Container(
              height: MediaQuery.of(Get.context!).size.height * 0.80,
              decoration: BoxDecoration(
                color: AppColors.neutralBackground,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
                      child: Text(
                        "Confirm Your Details",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(height: 10, thickness: 1, indent: 20, endIndent: 20, color: AppColors.lightPurple),
                    const SizedBox(height: 10),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Obx(() {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),

                              Text(
                                "Is this order for yourself or for someone else?",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.neutralBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.lightPurple, width: 1.0),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (orderFor.value != 'Self') {
                                              orderFor.value = 'Self';
                                              nameController.text = user['name'] ?? '';
                                              phoneController.text = user['phoneNo'] ?? user['phone'] ?? '';
                                              emailController.text = user['email'] ?? '';
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: orderFor.value == 'Self' ? AppColors.primaryPurple.withOpacity(0.1) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Radio<String>(
                                                  value: 'Self',
                                                  groupValue: orderFor.value,
                                                  onChanged: (String? value) {
                                                    if (value != null) {
                                                      orderFor.value = value;
                                                      nameController.text = user['name'] ?? '';
                                                      phoneController.text = user['phoneNo'] ?? user['phone'] ?? '';
                                                      emailController.text = user['email'] ?? '';
                                                    }
                                                  },
                                                  activeColor: AppColors.primaryPurple,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                Text(
                                                  "Self",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: orderFor.value == 'Self' ? AppColors.primaryPurple : AppColors.textDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(color: AppColors.lightPurple.withOpacity(0.7), thickness: 1, width: 1),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (orderFor.value != 'Other') {
                                              orderFor.value = 'Other';
                                              nameController.clear();
                                              phoneController.clear();
                                              emailController.clear();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: orderFor.value == 'Other' ? AppColors.primaryPurple.withOpacity(0.1) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Radio<String>(
                                                  value: 'Other',
                                                  groupValue: orderFor.value,
                                                  onChanged: (String? value) {
                                                    if (value != null) {
                                                      orderFor.value = value;
                                                      nameController.clear();
                                                      phoneController.clear();
                                                      emailController.clear();
                                                    }
                                                  },
                                                  activeColor: AppColors.primaryPurple,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                Text(
                                                  "Other",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: orderFor.value == 'Other' ? AppColors.primaryPurple : AppColors.textDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Name Field
                              TextFormField(
                                controller: nameController,
                                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
                                decoration: InputDecoration(
                                  labelText: orderFor.value == 'Self' ? "Your Name" : "Recipient's Name",
                                  hintText: orderFor.value == 'Self' ? "Your full name" : "e.g., Jane Doe",
                                  labelStyle: GoogleFonts.poppins(color: AppColors.textLight, fontWeight: FontWeight.w500),
                                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryPurple),
                                  filled: true,
                                  fillColor: AppColors.neutralBackground,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0),),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 1.5),),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 2.0),),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),

                              const SizedBox(height: 20),

                              // Phone Number Field
                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  hintText: "e.g., 9876543210",
                                  labelStyle: GoogleFonts.poppins(color: AppColors.textLight, fontWeight: FontWeight.w500),
                                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryPurple),
                                  filled: true,
                                  fillColor: AppColors.neutralBackground,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0),),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 1.5),),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 2.0),),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Enter a valid 10-digit number';
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),

                              const SizedBox(height: 20),

                              // Email Field
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
                                decoration: InputDecoration(
                                  labelText: "Email (Optional)",
                                  hintText: "e.g., example@domain.com",
                                  labelStyle: GoogleFonts.poppins(color: AppColors.textLight, fontWeight: FontWeight.w500),
                                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                                  filled: true,
                                  fillColor: AppColors.neutralBackground,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.lightPurple, width: 1.0),),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 1.5),),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.danger, width: 2.0),),
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 30),
                            ],
                          );
                        }),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Basic validation
                                if (nameController.text.trim().isEmpty) {
                                  _showModernSnackbar(
                                    'Name Required',
                                    'Please enter a full name for the order.',
                                    icon: Icons.person_outline_rounded,
                                    backgroundColor: AppColors.danger,
                                    isError: true,
                                  );
                                  return;
                                }

                                if (phoneController.text.trim().isEmpty || phoneController.text.trim().length < 10) {
                                  _showModernSnackbar(
                                    'Phone Number Required',
                                    'Please enter a valid 10-digit phone number for the order.',
                                    icon: Icons.phone_android_outlined,
                                    backgroundColor: AppColors.danger,
                                    isError: true,
                                  );
                                  return;
                                }

                                // Email validation (only if provided)
                                if (emailController.text.isNotEmpty && !GetUtils.isEmail(emailController.text)) {
                                  _showModernSnackbar(
                                    'Invalid Email',
                                    'Please enter a valid email address or leave it empty.',
                                    icon: Icons.email_outlined,
                                    backgroundColor: AppColors.danger,
                                    isError: true,
                                  );
                                  return;
                                }

                                // If all validations pass, save data and close dialog with 'true'
                                final updatedUser = {
                                  ...user,
                                  'name': nameController.text.trim(),
                                  'phoneNo': phoneController.text.trim(),
                                  'phone': phoneController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'orderFor': orderFor.value,
                                };
                                _box.write('user', updatedUser);
                                Get.back(result: true); // Close the dialog and pass true
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                "Save & Continue",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Get.back(result: false); // Close the dialog immediately
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    return result ?? false;
  }
}