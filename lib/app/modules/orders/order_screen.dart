// Path: lib/app/modules/order_history/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../controllers/order_controller.dart';
import '../../data/order_model.dart'; // This is your FULL OrderModel (the response model)
import '../../themes/app_theme.dart'; // Your custom AppColors and AppTheme
import '../home/home_screen.dart'; // To navigate back to home

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  // Using Get.find() because the controller should be initialized elsewhere (e.g., in a binding)
  final OrderController controller = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Use neutralBackground from your theme
      body: Obx(() {
        if (controller.isLoadingOrderHistory.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPurple), // Use primaryPurple
                SizedBox(height: 16),
                Text(
                  'Loading your orders...',
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight),
                ),
              ],
            ),
          );
        } else if (controller.orderHistoryErrorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied_outlined, size: 70, color: AppColors.textLight), // More friendly icon
                  const SizedBox(height: 24),
                  Text(
                    'Failed to load orders: ${controller.orderHistoryErrorMessage.value}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.fetchOrderHistory,
                    icon: const Icon(Icons.refresh_rounded, size: 20), // Rounded icon
                    label: Text(
                      'Try Again',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple, // Primary button color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (controller.orderHistory.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textLight), // Iconic for empty state
                  const SizedBox(height: 24),
                  Text(
                    'No orders found yet!',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Looks like you haven\'t placed any orders. Start shopping to fill this space!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => HomeScreen()); // Navigate back to home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple, // Use primaryPurple for positive action
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // More rounded
                      elevation: 4,
                    ),
                    child: Text(
                      'Start Shopping Now',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchOrderHistory();
            },
            color: AppColors.primaryPurple, // Color of the refresh indicator
            backgroundColor: AppColors.neutralBackground, // Background color of the refresh indicator
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.orderHistory.length,
              itemBuilder: (context, index) {
                final order = controller.orderHistory[index];
                return _buildOrderCard(order);
              },
            ),
          );
        }
      }),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    String statusText = order.status?.capitalizeFirst ?? 'Unknown';
    switch (order.status?.toLowerCase()) {
      case 'pending':
        statusColor = AppColors.accentNeon; // Using accentNeon for pending
        break;
      case 'processing':
        statusColor = AppColors.darkPurple; // Using darkPurple for processing
        break;
      case 'delivered':
        statusColor = AppColors.success; // Green for delivered
        break;
      case 'cancelled':
        statusColor = AppColors.danger; // Red for cancelled
        break;
      default:
        statusColor = AppColors.textLight; // Default grey
    }

    String orderDate = 'N/A';
    if (order.createdAt != null) {
      // Formatted with year and proper time
      orderDate = DateFormat('dd MMM, hh:mm a').format(order.createdAt!);
    }

    return Card(
      color: Colors.white, // White card background
      elevation: 6, // More pronounced shadow
      shadowColor: Colors.black.withOpacity(0.08), // Softer, more spread shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Larger border radius
      margin: const EdgeInsets.only(bottom: 18.0), // Increased margin
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding inside card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Order Header: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Order #${order.orderId ?? 'N/A'}', // Use '#' for order ID
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Bolder ID
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Larger padding
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.18), // Slightly more opaque background
                    borderRadius: BorderRadius.circular(10), // More rounded badge
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // Reduced space for date
            Text(
              'Placed on: $orderDate',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            const Divider(height: 28, thickness: 1, color: AppColors.lightPurple), // Using lightPurple for divider

            /// Order Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, itemIndex) {
                final item = order.items[itemIndex];
                final product = item.productId;

                final String? imageUrl = product.images.isNotEmpty ? product.images[0] : null;

                final String productName = product.fullName;
                final String variantText = item.variantName != 'Default' && item.variantName.isNotEmpty
                    ? 'Variant: ${item.variantName}'
                    : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // More vertical spacing for items
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Slightly larger image border radius
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          height: 70, // Increased image size
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                height: 70, width: 70,
                                color: AppColors.neutralBackground, // Lighter background
                                child: const Icon(Icons.broken_image_rounded, size: 35, color: AppColors.textLight), // Rounded broken image icon
                              ),
                        )
                            : Container(
                          height: 70, width: 70,
                          color: AppColors.neutralBackground,
                          child: const Icon(Icons.image_not_supported_rounded, size: 35, color: AppColors.textLight), // Rounded icon for no image
                        ),
                      ),
                      const SizedBox(width: 16), // More space between image and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: GoogleFonts.poppins(
                                fontSize: 15, // Adjusted font size
                                fontWeight: FontWeight.w600, // Slightly bolder
                                color: AppColors.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (variantText.isNotEmpty)
                              Text(
                                variantText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13, // Adjusted font size
                                  color: AppColors.textLight,
                                ),
                              ),
                            const SizedBox(height: 4), // Space between variant and quantity
                            Text(
                              'Qty: ${item.quantity}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500, // Added some weight
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15, // Adjusted font size
                            fontWeight: FontWeight.w700, // Bolder price
                            color: AppColors.primaryPurple, // Highlight price with primary color
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 28, thickness: 1, color: AppColors.lightPurple), // Thicker divider

            /// Order Summary
            _buildSummaryRow('Subtotal:', '₹${order.subtotal.toStringAsFixed(2)}', AppColors.textDark),
            _buildSummaryRow('Delivery Charge:', '₹${order.deliveryCharge.toStringAsFixed(2)}', AppColors.textDark),
            _buildSummaryRow('GST:', '₹${order.gst.toStringAsFixed(2)}', AppColors.textDark),
            const SizedBox(height: 12), // More space before total

            // Total Amount row - visually distinct
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.poppins(
                      fontSize: 18, // Larger total font size
                      fontWeight: FontWeight.w700, // Very bold
                      color: AppColors.textDark, // Keep label dark
                    ),
                  ),
                  Text(
                    '₹${order.orderAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20, // Even larger total value
                      fontWeight: FontWeight.w800, // Extra bold
                      color: AppColors.success, // Highlight total with success color
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Space before payment method
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple.withOpacity(0.3), // Subtle background for method using lightPurple
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightPurple.withOpacity(0.6), width: 0.8),
                ),
                child: Text(
                  'Payment: ${order.method?.capitalizeFirst ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600, // Slightly bolder method
                    color: AppColors.darkPurple, // Use darkPurple for payment method text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for summary rows
  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Slightly more vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.textLight, // Summary labels are light gray
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor, // Use the provided color for the value
            ),
          ),
        ],
      ),
    );
  }
}