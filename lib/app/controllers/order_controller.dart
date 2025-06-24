// app/controllers/order_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

import 'package:mobiking/app/modules/Order_confirmation/Confirmation_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Import your data models
import '../data/AddressModel.dart';
import '../data/Order_get_data.dart'; // Contains CreateOrderRequestModel
import '../data/order_model.dart'; // The full OrderModel (Response Model) - CRUCIAL to have 'requests' field
import '../data/razor_pay.dart'; // Contains RazorpayVerifyRequest

// Import your controllers and services
import '../controllers/cart_controller.dart';
import '../controllers/address_controller.dart';
import '../modules/bottombar/Bottom_bar.dart' show MainContainerScreen;
import '../modules/checkout/widget/user_info_dialog_content.dart';
import '../services/order_service.dart';
import '../themes/app_theme.dart';

// Helper function for themed snackbars (defined once, globally accessible)
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
  // Dismiss any existing snackbar to prevent overlap
  if (Get.isSnackbarOpen) {
    Get.back();
  }

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
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
  );
}

class OrderController extends GetxController {
  final GetStorage _box = GetStorage();
  final OrderService _orderService = Get.find<OrderService>();

  final CartController _cartController = Get.find<CartController>();
  final AddressController _addressController = Get.find<AddressController>();

  var isLoading = false.obs; // General loading for actions like placing order/sending requests
  var orderHistory = <OrderModel>[].obs;

  var isLoadingOrderHistory = false.obs;
  var orderHistoryErrorMessage = ''.obs;
  late Razorpay _razorpay;

  String? _currentBackendOrderId;
  String? _currentRazorpayOrderId;

  // Define STATUS_PROGRESS based on your backend's order statuses
  // IMPORTANT: These strings MUST exactly match the 'orderStatus' and 'shippingStatus' values from your backend.
  static const List<String> STATUS_PROGRESS = [
    "Picked Up",
    "IN TRANSIT",
    "Shipped",
    "Delivered",
    "Returned",
    "CANCELLED", // Case-sensitive
    "Cancelled", // Case-sensitive
  ];

  // New RxString for selected reason
  var selectedReasonForRequest = ''.obs;

  // List of predefined reasons from the image
  final List<String> predefinedReasons = [
    'Ordered wrong item',
    'Found cheaper price',
    'Delivery taking too long',
    'Need to change address',
    'Other (please specify)',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print('Razorpay initialized and listeners registered.');
  }

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
    _razorpay.clear();
    print('Razorpay listeners cleared.');
    super.onClose();
  }

  // --- Razorpay Payment Callbacks ---
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Razorpay Payment Success: ${response.paymentId}, ${response.orderId}, ${response.signature}');
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

      final verifyRequest = RazorpayVerifyRequest(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        orderId: _currentBackendOrderId!,
      );

      print('Calling backend for payment verification...');
      final verifiedOrder = await _orderService.verifyRazorpayPayment(verifyRequest);
      print('Backend verification successful for order: ${verifiedOrder.orderId}');

      await _box.write('last_placed_order', verifiedOrder.toJson());
      _cartController.clearCartData();

      _showModernSnackbar(
        'Order Placed!',
        'Your order ID ${verifiedOrder.orderId ?? 'N/A'} has been placed successfully!',
        isError: false,
        icon: Icons.receipt_long_outlined,
        backgroundColor: Colors.green.shade600,
        snackPosition: SnackPosition.TOP,
      );
      Get.offAll(() => OrderConfirmationScreen()); // Navigate to confirmation after successful order
      // Removed isLoading.value = false here as it's handled in finally block, to prevent premature hiding if navigation is fast

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
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Payment Error: Code ${response.code} - Description: ${response.message}');
    isLoading.value = false;
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
    _currentBackendOrderId = null;
    _currentRazorpayOrderId = null;

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

    Map<String, dynamic> user = Map<String, dynamic>.from(_box.read('user') ?? {});
    String? userId = user['_id'];
    String? name = user['name'];
    String? email = user['email'];
    String? phone = user['phoneNo'] ?? user['phone'];

    bool userInfoIncomplete = [userId, name, email, phone].any((e) => e == null || e.toString().trim().isEmpty);

    if (userInfoIncomplete) {
      final bool detailsConfirmed = await _promptUserInfo();

      if (!detailsConfirmed) {
        _showModernSnackbar(
          'Details Not Saved',
          'User details were not updated. Please fill them out to proceed with your order.',
          icon: Icons.info_outline_rounded,
          backgroundColor: AppColors.textLight.withOpacity(0.8),
          isError: false,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      user = Map<String, dynamic>.from(_box.read('user') ?? {});
      userId = user['_id'];
      name = user['name'];
      email = user['email'];
      phone = user['phoneNo'] ?? user['phone'];

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

    final CreateUserReferenceRequestModel userRefRequest = CreateUserReferenceRequestModel(
      id: userId!,
      email: email!,
      phoneNo: phone!,
    );

    final double subtotal = _calculateSubtotal();
    const double deliveryCharge = 45.0;
    final double gst = 0.0; // Assuming GST is a double for calculation here before conversion to String for OrderModel
    final double total = subtotal + deliveryCharge;

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
        // Corrected: productData['sellingPrice'] is a List, not a Map
        final List<dynamic> sellingPricesList = productData['sellingPrice'];
        if (sellingPricesList.isNotEmpty && sellingPricesList[0] is Map<String, dynamic>) {
          itemPrice = (sellingPricesList[0]['price'] as num?)?.toDouble() ?? 0.0;
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

    final createOrderRequest = CreateOrderRequestModel(
      userId: userRefRequest,
      cartId: cartId,
      name: name!,
      email: email!,
      phoneNo: phone!,
      orderAmount: total,
      discount: 0,
      deliveryCharge: deliveryCharge,
      gst: gst, // Passed as double here, OrderModel expects String
      subtotal: subtotal,
      address: '${address.street}, ${address.city}, ${address.state}, ${address.pinCode}',
      method: method,
      items: orderItemsRequest,
      addressId: addressId,
    );

    try {
      isLoading.value = true;

      if (method == 'COD') {
        final createdOrder = await _orderService.placeCodOrder(createOrderRequest);

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
        Get.offAll(() => OrderConfirmationScreen());
        // Removed isLoading.value = false here as it's handled in finally block, to prevent premature hiding if navigation is fast
      } else if (method == 'Online') {
        print('Initiating online payment with backend...');
        final Map<String, dynamic> initiateResponse = await _orderService.initiateOnlineOrder(createOrderRequest);
        print('Backend initiate response: $initiateResponse');

        final String? razorpayOrderId = initiateResponse['razorpayOrderId'] as String?;
        final int? amountInPaise = initiateResponse['amount'] as int?;
        final String? currency = initiateResponse['currency'] as String?;
        final String? razorpayKey = initiateResponse['key'] as String?;
        final String? newOrderId = initiateResponse['newOrderId'] as String?;

        if (razorpayOrderId == null || amountInPaise == null || currency == null || razorpayKey == null || newOrderId == null) {
          throw OrderServiceException(
            'Missing essential Razorpay initiation data from backend.',
            statusCode: 500,
          );
        }

        _currentBackendOrderId = newOrderId;
        _currentRazorpayOrderId = razorpayOrderId;

        final Map<String, dynamic> options = {
          'key': razorpayKey,
          'amount': amountInPaise,
          'name': 'MobiKing E-commerce',
          'description': 'Order from MobiKing',
          'order_id': _currentRazorpayOrderId,
          'currency': currency,
          'prefill': {
            'email': email,
            'contact': phone,
          },
          'external': {
            'wallets': ['paytm', 'google_pay'],
          },
          'theme': {
            'color': '#3399FF'
          },
        };
        print('Opening Razorpay checkout with options: $options');
        _razorpay.open(options);

      } else {
        isLoading.value = false;
        _showModernSnackbar(
          'Payment Method Invalid!',
          'The selected payment method is not currently supported.',
          isError: true,
          icon: Icons.not_interested_outlined,
          backgroundColor: Colors.red.shade400,
          snackPosition: SnackPosition.TOP,
        );
        return;
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
      isLoading.value = false;
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
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderHistory() async {
    isLoadingOrderHistory.value = true;
    orderHistoryErrorMessage.value = '';
    try {
      final List<OrderModel> fetchedOrders = await _orderService.getUserOrders();

      if (fetchedOrders.isNotEmpty) {
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

  Future<bool> _promptUserInfo() async {
    final GetStorage _box = GetStorage();
    final user = _box.read('user') ?? {};

    final bool? result = await Get.to<bool?>(
          () => UserInfoScreen(initialUser: user),
      fullscreenDialog: true,
      transition: Transition.rightToLeft,
    );
    return result ?? false;
  }

  // --- NEW METHODS FOR ORDER REQUESTS ---

  /// Handles the process of sending a cancel, warranty, or return request for an order.
  /// `requestType` can be 'Cancel', 'Warranty', or 'Return'.
  Future<void> sendOrderRequest(String orderId, String requestType) async {
    // Reset selected reason each time a new request dialog is opened
    selectedReasonForRequest.value = '';
    final TextEditingController reasonController = TextEditingController(); // For "Other" option

    final bool? dialogResult = await Get.dialog<bool>(
      GestureDetector(
        onTap: () => FocusScope.of(Get.context!).unfocus(), // Tap outside to dismiss keyboard
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly less rounded for consistency with image
          ),
          backgroundColor: AppColors.white,
          // Removed contentPadding and actionsPadding to allow more flexible sizing like the image
          // buttonPadding: EdgeInsets.zero, // Default button padding is often fine for a single button

          titlePadding: const EdgeInsets.fromLTRB(24, 20, 10, 0), // Adjusted title padding
          contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 0), // Adjust content padding for radio tiles

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align title and close icon
            children: [
              Expanded( // Take remaining space for title
                child: Text(
                  '${requestType.capitalizeFirst} Request', // Title matches image
                  style: Get.textTheme.titleMedium?.copyWith( // Smaller title as in image
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textLight), // Close icon as in image
                onPressed: () {
                  Get.back(result: false);
                },
                splashRadius: 20, // Smaller splash radius for close icon
              ),
            ],
          ),

          content: Obx(() => SingleChildScrollView( // Use Obx to react to selectedReasonForRequest
            child: Column(
              mainAxisSize: MainAxisSize.min, // Essential for dynamic content
              children: [
                // List of Radio Tiles for reasons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding to align with title
                  child: Text(
                    'Select a reason for your ${requestType.toLowerCase()}:', // Helper text
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...predefinedReasons.map((reasonOption) { // Use predefinedReasons from the controller
                  return RadioListTile<String>(
                    title: Text(
                      reasonOption,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: reasonOption,
                    groupValue: selectedReasonForRequest.value, // Use controller's RxString
                    onChanged: (String? value) {
                      selectedReasonForRequest.value = value!; // Update controller's RxString
                    },
                    activeColor: AppColors.primaryPurple, // Accent color for selected radio
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding for list tile
                    visualDensity: VisualDensity.compact, // Reduce vertical spacing
                  );
                }).toList(),

                // Conditional TextField for 'Other' reason
                if (selectedReasonForRequest.value == 'Other (please specify)') // Check against the exact "Other" text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), // Adjusted padding for text field
                    child: TextField(
                      controller: reasonController,
                      maxLines: 3,
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Please specify your reason here...',
                        hintStyle: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.neutralBackground),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.white),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralBackground,
                      ),
                    ),
                  ),
              ],
            ),
          )),

          // Single action button at the bottom
          actions: [
            Center( // Center the button
              child: SizedBox(
                width: double.infinity, // Full width button
                child: ElevatedButton(
                  onPressed: () {
                    String currentReason = selectedReasonForRequest.value; // Use controller's RxString
                    if (currentReason.isEmpty) {
                      _showModernSnackbar(
                        'Reason Required',
                        'Please select a reason.',
                        isError: true,
                        icon: Icons.info_outline,
                        backgroundColor: Colors.orange,
                      );
                    } else if (currentReason == 'Other (please specify)' && (reasonController.text.trim().isEmpty || reasonController.text.trim().length < 10)) {
                      _showModernSnackbar(
                        'Reason Required',
                        reasonController.text.trim().isEmpty ? 'Please enter a reason for "Other (please specify)".' : 'Reason must be at least 10 characters long.',
                        isError: true,
                        icon: Icons.info_outline,
                        backgroundColor: Colors.orange,
                      );
                    } else {
                      Get.back(result: true); // Valid reason, dismiss with true
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Larger padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  child: Text(
                    'Place Request', // Text from image
                    style: Get.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Padding around the action button
        ),
      ),
    );

    reasonController.dispose(); // Dispose the controller when dialog closes

    if (dialogResult == null || !dialogResult) {
      print('$requestType request cancelled by user or no reason provided.');
      return; // User cancelled or didn't provide a reason
    }

    // Determine the final reason to send to the backend
    String finalReasonToSend;
    if (selectedReasonForRequest.value == 'Other (please specify)') {
      finalReasonToSend = reasonController.text.trim();
    } else {
      finalReasonToSend = selectedReasonForRequest.value;
    }

    isLoading.value = true; // Show loading indicator
    try {
      Map<String, dynamic> response;
      String successMessage;

      switch (requestType) {
        case 'Cancel':
          response = await _orderService.requestCancel(orderId, finalReasonToSend);
          successMessage = 'Cancel request sent successfully!';
          break;
        case 'Warranty':
          response = await _orderService.requestWarranty(orderId, finalReasonToSend);
          successMessage = 'Warranty request sent successfully!';
          break;
        case 'Return':
          response = await _orderService.requestReturn(orderId, finalReasonToSend);
          successMessage = 'Return request sent successfully!';
          break;
        default:
          throw Exception('Invalid request type: $requestType');
      }

      _showModernSnackbar(
        'Success',
        successMessage,
        isError: false,
        icon: Icons.check_circle_outline,
        backgroundColor: Colors.green,
      );
      print('$requestType request for Order $orderId successful: $response');
      // Refresh order history to reflect the new request status
      // This is crucial for button visibility logic to update.
      await fetchOrderHistory();

    } on OrderServiceException catch (e) {
      _showModernSnackbar(
        'Request Failed',
        e.message,
        isError: true,
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
      print('Service Error for $requestType request: ${e.message}');
    } catch (e) {
      _showModernSnackbar(
        'Error',
        'An unexpected error occurred: $e',
        isError: true,
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
      print('Unexpected Error for $requestType request: $e');
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
  }

  // --- Helper Methods for Button Visibility Logic ---

  /// Checks if a request of a specific type has been raised and is active (not rejected/resolved).
  /// This ensures "only one request of each type can be placed at most" (Rule 1 & 5 for same type)
  /// and also that a request, once raised, makes the button for that type disappear.
  bool _isSpecificRequestActive(OrderModel order, String type) {
    if (order.requests == null || order.requests!.isEmpty) {
      return false;
    }
    return order.requests!.any((r) {
      final requestType = r.type; // Access RequestModel property
      final isRaised = r.isRaised; // Access RequestModel property
      final status = r.status.toLowerCase(); // Access RequestModel property
      // An active request is one that is raised and NOT explicitly rejected or resolved/completed.
      // 'Accepted' is a type of active state that also blocks further requests.
      return requestType.toLowerCase() == type.toLowerCase() && isRaised && status != "rejected" && status != "resolved";
    });
  }

  /// Checks if ANY request (Cancel, Return, Warranty) is currently active or accepted.
  /// This implements Rules 3 and 4: "If a request is placed and is unresolved/pending
  /// or accepted, then no other requests can be placed."
  bool _isAnyRequestActiveOrAccepted(OrderModel order) {
    if (order.requests == null || order.requests!.isEmpty) {
      return false;
    }
    return order.requests!.any((r) {
      final isRaised = r.isRaised; // Access RequestModel property
      final status = r.status.toLowerCase(); // Access RequestModel property

      // If a request is raised AND its status is not 'rejected' and not 'resolved',
      // then it's considered active and blocks other requests.
      return isRaised && status != "rejected" && status != "resolved";
    });
  }

  // --- Display Logic for Buttons on Order Item (Aligned with original pseudo-code and new rules) ---

  /// Determines if the 'Cancel' button should be shown for a given order.
  bool showCancelButton(OrderModel order) {
    // Rule: Can only be shown if the order status is "New" or "Accepted".
    final bool isEligibleStatus = order.status.toLowerCase() == 'new' ||
        order.status.toLowerCase() == 'accepted';

    // Rule: Cannot be shown if a "Cancel" request is already active.
    final bool hasActiveCancelRequest = _isSpecificRequestActive(order, 'Cancel');

    // Rule: Cannot be shown if *any* other request (Cancel, Return, Warranty) is already active/accepted.
    // This is a broader check to prevent multiple simultaneous requests of any type.
    final bool hasAnyActiveRequest = _isAnyRequestActiveOrAccepted(order);

    return isEligibleStatus && !hasActiveCancelRequest && !hasAnyActiveRequest;
  }

  /// Determines if the 'Warranty' button should be shown for a given order.
  bool showWarrantyButton(OrderModel order) {
    // Rule: Can only be shown if the order status is "Delivered".
    final bool isEligibleStatus = order.status.toLowerCase() == 'delivered';

    // Rule: Cannot be shown if a "Warranty" request is already active.
    final bool hasActiveWarrantyRequest = _isSpecificRequestActive(order, 'Warranty');

    // Rule: Cannot be shown if *any* other request (Cancel, Return, Warranty) is already active/accepted.
    final bool hasAnyActiveRequest = _isAnyRequestActiveOrAccepted(order);

    return isEligibleStatus && !hasActiveWarrantyRequest && !hasAnyActiveRequest;
  }

  /// Determines if the 'Return' button should be shown for a given order.
  bool showReturnButton(OrderModel order) {
    // Rule: Can only be shown if the order status is "Delivered".
    final bool isEligibleStatus = order.status.toLowerCase() == 'delivered';

    // Rule: Cannot be shown if a "Return" request is already active.
    final bool hasActiveReturnRequest = _isSpecificRequestActive(order, 'Return');

    // Rule: Cannot be shown if *any* other request (Cancel, Return, Warranty) is already active/accepted.
    final bool hasAnyActiveRequest = _isAnyRequestActiveOrAccepted(order);

    return isEligibleStatus && !hasActiveReturnRequest && !hasAnyActiveRequest;
  }
}
