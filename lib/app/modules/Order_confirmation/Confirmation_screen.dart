// lib/screens/order_confirmation_screen.dart
import 'dart:ui'; // Required for ImageFilter and BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mobiking/app/controllers/login_controller.dart'; // Assuming LoginController exists

// Ensure these imports are correct based on your project structure
import '../../controllers/address_controller.dart'; // Assuming AddressController exists
import '../../controllers/order_controller.dart'; // Assuming this is OrderGetXController
import '../../data/AddressModel.dart'; // Assuming AddressModel exists
import '../../data/order_model.dart'; // Import the updated OrderModel
import '../../themes/app_theme.dart'; // Your custom AppColors and AppTheme
import '../bottombar/Bottom_bar.dart'; // To navigate back to main container

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with SingleTickerProviderStateMixin {
  // Use 'late' to ensure controllers are found before use, assuming they are registered via Get.put
  late final OrderController orderController = Get.find<OrderController>();
  late final AddressController addressController = Get.find<AddressController>(); // If you need to access addresses

  late AnimationController _lottieController;
  final RxBool _showLottie = true.obs;
  final RxBool _isLottiePlayedOnce = false.obs; // Track if Lottie has played its initial animation

  @override
  void initState() {
    super.initState();
    debugPrint('OrderConfirmationScreen initState called');

    _lottieController = AnimationController(vsync: this);

    // Initial check and fetch
    _initializeDataAndLottie();

    // Listen for changes in order history loading state
    // This will trigger after initial fetch, or any subsequent refresh
    ever(orderController.isLoadingOrderHistory, (bool isLoading) {
      debugPrint('isLoadingOrderHistory changed to: $isLoading');
      if (!isLoading) {
        debugPrint('Order History Count: ${orderController.orderHistory.length}');
        // debugPrint('Address Count: ${addressController.addresses.length}'); // Addresses might not be relevant here if order has its own address
        debugPrint('Error Message: ${orderController.orderHistoryErrorMessage.value}');

        // If loading is complete, ensure Lottie plays (if it hasn't) then hide it
        _playLottieAndShowDetails();
      }
    });
  }

  // Helper method to handle initial data fetch and Lottie display
  void _initializeDataAndLottie() {
    // Only show Lottie initially and if it hasn't played through yet for the first time
    if (!_isLottiePlayedOnce.value) {
      _showLottie.value = true;
      debugPrint('Setting _showLottie to true for initial animation.');
    }

    // Only fetch if data is not already present and not currently loading
    // Assuming the most recent order is always the one just placed
    if (orderController.orderHistory.isEmpty && !orderController.isLoadingOrderHistory.value) {
      debugPrint('Triggering initial order history fetch.');
      orderController.fetchOrderHistory();
    } else if (orderController.orderHistory.isNotEmpty && !_isLottiePlayedOnce.value) {
      // If data is already there and Lottie hasn't played, just play Lottie
      debugPrint('Order history already loaded. Playing Lottie for transition.');
      _playLottieAndShowDetails();
    }
  }

  // Helper method to play Lottie and then show order details
  void _playLottieAndShowDetails() {
    // Only play Lottie if it hasn't completed its full cycle yet
    if (!_isLottiePlayedOnce.value && _lottieController.duration != null) {
      debugPrint('Attempting to play Lottie animation.');
      _lottieController.forward(from: 0.0).then((_) { // Ensure it starts from beginning
        debugPrint('Lottie animation completed. Hiding Lottie.');
        _showLottie.value = false;
        _isLottiePlayedOnce.value = true; // Mark as played
      }).onError((error, stackTrace) {
        debugPrint('Lottie animation error: $error');
        _showLottie.value = false; // Hide on error too
        _isLottiePlayedOnce.value = true;
      });
    } else if (_isLottiePlayedOnce.value) {
      // If Lottie has already played its initial animation, just hide it
      debugPrint('Lottie already played, hiding immediately.');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showLottie.value = false;
      });
    } else {
      // Fallback if duration is not set or other issues
      debugPrint('Lottie duration not set or other issue. Hiding Lottie immediately as fallback.');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showLottie.value = false;
      });
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _showLottie.close();
    _isLottiePlayedOnce.close();
    debugPrint('OrderConfirmationScreen dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: Obx(() {
        debugPrint('--- BUILD TRIGGERED ---');
        debugPrint('Current isLoadingOrderHistory: ${orderController.isLoadingOrderHistory.value}');
        debugPrint('Current _showLottie: ${_showLottie.value}');
        debugPrint('Current _isLottiePlayedOnce: ${_isLottiePlayedOnce.value}');

        // Determine which screen to show based on state
        if (_showLottie.value || orderController.isLoadingOrderHistory.value) {
          debugPrint('Displaying Lottie Animation or Loading State.');
          return _buildLottieAnimation(context, textTheme);
        } else if (orderController.orderHistoryErrorMessage.isNotEmpty) {
          debugPrint('Displaying Error State.');
          return _buildError(context, textTheme);
        } else if (orderController.orderHistory.isEmpty) {
          debugPrint('Displaying No Orders Found State.');
          return _buildNoOrders(context, textTheme);
        } else {
          debugPrint('Displaying Order Details Screen.');
          return _buildOrderDetails(context, textTheme);
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        // Hide button during loading, Lottie display, or if no orders or error
        if (_showLottie.value || orderController.isLoadingOrderHistory.value || orderController.orderHistory.isEmpty || orderController.orderHistoryErrorMessage.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              Get.offAll(() => MainContainerScreen()); // Navigate to main screen
              // Show a more Blinkit-style success snackbar (using AppColors)
              Get.snackbar(
                "🎉 Order Confirmed!", // Emojis add a nice touch
                "Your order has been successfully placed. Explore more products!",
                backgroundColor: AppColors.success.withOpacity(0.9), // Slightly transparent for a modern look
                colorText: AppColors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12, // Slightly more rounded
                icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
                duration: const Duration(seconds: 4),
                animationDuration: const Duration(milliseconds: 400),
                // You can add more interactive elements if desired, like a button to view order
                mainButton: TextButton(
                  onPressed: () {
                    Get.back(); // Dismiss snackbar
                    // Logic to navigate to order history if you have one
                  },
                  child: Text('View Order', style: textTheme.labelMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 24), // Updated icon for shopping
            label: Text(
              "Continue Shopping",
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.white, fontSize: 18), // Slightly larger/bolder
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple, // Your primary color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(60), // Taller button
              elevation: 8, // More prominent shadow
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLottieAnimation(BuildContext context, TextTheme textTheme) {
    return Container(
      color: AppColors.white, // Clean white background for Lottie
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/order.json', // Ensure this path is correct
              controller: _lottieController,
              onLoaded: (composition) {
                debugPrint('Lottie animation loaded. Duration: ${composition.duration}');
                if (_lottieController.duration != composition.duration) {
                  _lottieController.duration = composition.duration;
                  // Only forward if not already animating or completed its full run
                  if (!_lottieController.isAnimating && _lottieController.status != AnimationStatus.completed) {
                    // Only start playing if it's the initial unplayed state
                    if (!_isLottiePlayedOnce.value) {
                      _lottieController.forward();
                    }
                  }
                }
              },
              repeat: false,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Lottie asset loading error: $error');
                // Fallback UI if Lottie fails to load
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: AppColors.danger),
                    Text('Failed to load animation.', style: textTheme.bodyMedium?.copyWith(color: AppColors.danger)),
                    Text('Error: $error', style: textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.textLight)),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Wrap text with Obx to react to loading state
            Obx(() => Text(
              orderController.isLoadingOrderHistory.value ? 'Fetching your order details...' : 'Confirming your order...',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            ),
            if (orderController.isLoadingOrderHistory.value)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CircularProgressIndicator(color: AppColors.primaryPurple, strokeWidth: 3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 70, color: AppColors.danger), // Slightly different icon
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong while fetching your order. ${orderController.orderHistoryErrorMessage.value}',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showLottie.value = true; // Show Lottie again on retry
                _isLottiePlayedOnce.value = false; // Allow Lottie to play again
                _lottieController.reset(); // Reset Lottie animation
                orderController.fetchOrderHistory(); // Re-fetch data
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
              label: Text('Retry', style: textTheme.labelLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrders(BuildContext context, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 80, color: AppColors.primaryPurple), // Another shopping icon
            const SizedBox(height: 24),
            Text(
              'No recent orders to show!',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 12),
            Text(
              'It looks like you haven\'t placed any orders yet. Let\'s get you started!',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Get.offAll(() => MainContainerScreen()); // Navigate to main screen
              },
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.white),
              label: Text('Start Shopping', style: textTheme.labelLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, TextTheme textTheme) {
    // Safely get the first order, if available
    final OrderModel? order = orderController.orderHistory.isNotEmpty ? orderController.orderHistory.first : null;
    if (order == null) {
      debugPrint('Error: Order details requested but order is null, falling back to no orders.');
      return _buildNoOrders(context, textTheme); // Fallback to no orders if somehow null
    }

    // Determine the delivery address to display. Prioritize order's specific address.
    // If order.addressId refers to an AddressModel object, you'd fetch it here.
    // Given the Mongoose schema, `order.address` is a string, so we'll use that directly.
    final String deliveryAddressText = order.address ?? 'Address not available for this order.';

    final orderTime = order.createdAt != null
        ? DateFormat('dd MMM, HH:mm').format(order.createdAt!.toLocal()) // More readable date format
        : 'N/A';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Elevated Success Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), // More padding
            decoration: BoxDecoration(
              color: AppColors.success, // Keep success green
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)), // More rounded
              boxShadow: [ // Add a subtle shadow to make it pop
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 70, color: AppColors.white), // Larger icon
                const SizedBox(height: 16),
                Text(
                  "Order Confirmed!",
                  style: textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 32), // Bigger, bolder
                ),
                const SizedBox(height: 8),
                Text(
                  "Your order #**${order.orderId ?? 'N/A'}** has been successfully placed.", // Emphasize Order ID, null safe
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(color: AppColors.white.withOpacity(0.9)), // Slightly subdued
                ),
                const SizedBox(height: 10),
                Text(
                  "A confirmation email has been sent to ${order.email ?? 'your registered email'}.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 10),
                Text(
                  "Order placed at: $orderTime",
                  style: textTheme.bodySmall?.copyWith(color: AppColors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // More space below the header

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24), // Increased horizontal padding
            child: Column(
              children: [
                _sectionTitle(context, textTheme, 'Delivery Address', Icons.location_on_outlined), // Add icon to section title
                _buildAddressCard(context, textTheme, deliveryAddressText), // Pass the string address
                const SizedBox(height: 24),

                _sectionTitle(context, textTheme, 'Shipping Details', Icons.local_shipping_outlined), // New section for shipping details
                _buildShippingDetailsCard(context, textTheme, order), // Pass order to new method
                const SizedBox(height: 24),

                _sectionTitle(context, textTheme, 'Items in Your Order', Icons.shopping_bag_outlined), // Add icon
                if (order.items.isNotEmpty)
                  ...order.items.map((item) => _buildOrderItemCard(context, textTheme, item)).toList()
                else
                  Card( // If no items, show message in a card
                    color: AppColors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No items listed for this order.',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight), textAlign: TextAlign.center),
                    ),
                  ),
                const SizedBox(height: 24),

                _sectionTitle(context, textTheme, 'Payment Summary', Icons.summarize_outlined), // Add icon
                _buildOrderSummary(context, textTheme, order),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  // Modified _sectionTitle to include an icon
  Widget _sectionTitle(BuildContext context, TextTheme textTheme, String title, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), // Slightly less vertical padding
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 28), // Larger icon for title
            const SizedBox(width: 10),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 22), // Bolder, slightly larger
            ),
          ],
        ),
      ),
    );
  }

  // Modified _buildAddressCard to accept a String address
  Widget _buildAddressCard(BuildContext context, TextTheme textTheme, String addressText) {
    return Card(
      color: AppColors.white, // Ensure card is white
      elevation: 2, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: AppColors.primaryPurple, size: 22), // Consistent icon
                const SizedBox(width: 8),
                // Assuming you want to show the order's recipient name here
                Text('Recipient: ${orderController.orderHistory.firstOrNull?.name ?? 'N/A'}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark)), // Adjusted title
              ],
            ),
            const SizedBox(height: 8),
            Text(
              addressText,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMedium), // Use textMedium for subtitle
            ),
            // Re-enabled phone number display with null check using order's phoneNo
            if (orderController.orderHistory.firstOrNull?.phoneNo != null && orderController.orderHistory.firstOrNull!.phoneNo!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppColors.textLight, size: 18),
                    const SizedBox(width: 6),
                    Text(orderController.orderHistory.firstOrNull!.phoneNo!, style: textTheme.bodySmall?.copyWith(color: AppColors.textLight)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // NEW WIDGET: _buildShippingDetailsCard to display courier, AWB, etc.
  Widget _buildShippingDetailsCard(BuildContext context, TextTheme textTheme, OrderModel order) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRowWithIcon(textTheme, Icons.local_shipping_outlined, 'Shipping Status', order.shippingStatus.capitalizeFirst ?? 'N/A'),
            if (order.courierName != null && order.courierName!.isNotEmpty)
              _detailRowWithIcon(textTheme, Icons.send_outlined, 'Courier', order.courierName!),
            if (order.awbCode != null && order.awbCode!.isNotEmpty)
              _detailRowWithIcon(textTheme, Icons.numbers_outlined, 'AWB Code', order.awbCode!),
            if (order.expectedDeliveryDate != null && order.expectedDeliveryDate!.isNotEmpty)
              _detailRowWithIcon(textTheme, Icons.calendar_today_outlined, 'Expected Delivery', DateFormat('dd MMM yyyy').format(DateTime.tryParse(order.expectedDeliveryDate!) ?? DateTime.now())),
            if (order.deliveredAt != null && order.deliveredAt!.isNotEmpty)
              _detailRowWithIcon(textTheme, Icons.check_circle_outline, 'Delivered On', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(order.deliveredAt!) ?? DateTime.now())),
            _detailRowWithIcon(textTheme, Icons.payment_outlined, 'Payment Method', order.method.capitalizeFirst ?? 'N/A'),
            if (order.razorpayPaymentId != null && order.razorpayPaymentId!.isNotEmpty)
              _detailRowWithIcon(textTheme, Icons.credit_card_outlined, 'Razorpay ID', order.razorpayPaymentId!),
            // Add other relevant fields like pickupTokenNumber, pickupDate, etc. if needed
          ],
        ),
      ),
    );
  }

  // Helper for detail rows with icons
  Widget _detailRowWithIcon(TextTheme textTheme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 10),
          SizedBox(
            width: 120, // Fixed width for labels for alignment
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOrderItemCard(BuildContext context, TextTheme textTheme, OrderItemModel item) {
    // Correctly access product details from item.productDetails
    final String imageUrl = item.productDetails?.images?.isNotEmpty == true
        ? item.productDetails!.images!.first
        : 'https://via.placeholder.com/70/D1C4E9/757575?text=No+Image'; // Placeholder

    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Increased padding
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 70, // Slightly larger image
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported, color: AppColors.textLight, size: 35),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productDetails?.fullName ?? item.productDetails?.name ?? 'Product Name N/A', // Using product's full name or name
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark), // Bolder item name
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.variantName.isNotEmpty && item.variantName != 'Default')
                    Text(
                      item.variantName,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
                    ),
                  Text(
                    "Qty: ${item.quantity} x ${NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2).format(item.price)}",
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMedium), // Consistent textMedium
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2).format(item.price * item.quantity),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primaryPurple), // Highlight total price
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, TextTheme textTheme, OrderModel order) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18), // Increased padding
        child: Column(
          children: [
            // Ensure values are not null before calculations
            _buildSummaryRow(context, textTheme, "Subtotal", order.subtotal ?? 0.0),
            if ((order.discount ?? 0.0) > 0)
              _buildSummaryRow(context, textTheme, "Discount", -(order.discount ?? 0.0), isDiscount: true),
            _buildSummaryRow(context, textTheme, "Delivery Fee", order.deliveryCharge), // deliveryCharge is non-nullable now
            _buildSummaryRow(context, textTheme, "GST", double.tryParse(order.gst ?? '0.0') ?? 0.0), // Parse GST string to double
            const Divider(height: 24, thickness: 1.5, color: AppColors.lightPurple), // Thicker divider
            _buildSummaryRow(context, textTheme, "Grand Total", order.orderAmount, isTotal: true), // orderAmount is non-nullable now
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, TextTheme textTheme, String title, double value, {bool isTotal = false, bool isDiscount = false}) {
    final style = isTotal
        ? textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 20) // Bigger, bolder total
        : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textDark); // Consistent with titles

    final valueColor = isDiscount ? AppColors.danger : (isTotal ? AppColors.primaryPurple : AppColors.textDark); // Total value in primaryPurple

    IconData getIconForTitle(String title) {
      switch (title) {
        case "Subtotal": return Icons.shopping_bag_outlined;
        case "Delivery Fee": return Icons.delivery_dining; // More specific icon
        case "Discount": return Icons.percent; // Percent icon for discount
        case "GST": return Icons.receipt_long; // Icon for GST
        case "Grand Total": return Icons.payments_outlined; // Payment icon for total
        default: return Icons.info_outline;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // More vertical spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(getIconForTitle(title), size: isTotal ? 24 : 20, color: AppColors.primaryPurple), // Larger icon for total
              const SizedBox(width: 10),
              Text(title, style: style),
            ],
          ),
          Text(
            NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2).format(value),
            style: style?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
