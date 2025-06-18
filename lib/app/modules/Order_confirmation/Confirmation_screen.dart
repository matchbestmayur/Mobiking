import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/order_controller.dart';
import '../../data/AddressModel.dart';
import '../../data/order_model.dart';
import '../../themes/app_theme.dart';
import '../bottombar/Bottom_bar.dart';
import '../home/home_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  OrderConfirmationScreen({Key? key}) : super(key: key);

  final OrderController orderController = Get.find<OrderController>();
  final AddressController addressController = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (orderController.isLoadingOrderHistory.value) {
          return _buildLoading(context);
        } else if (orderController.orderHistoryErrorMessage.isNotEmpty) {
          return _buildError(context);
        } else if (orderController.orderHistory.isEmpty || addressController.addresses.isEmpty) {
          return _buildNoOrders(context);
        } else {
          return _buildOrderDetails(context);
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(MainContainerScreen());
            Get.snackbar("Success", "Order confirmed. Happy Shopping!",
                backgroundColor: AppColors.primaryPurple,
                colorText: Colors.white);
          },
          icon: Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
          label: Text("Continue Shopping", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentNeon,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryPurple),
          const SizedBox(height: 16),
          Text('Fetching your latest order...', style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: AppColors.danger),
            const SizedBox(height: 24),
            Text(
              'Failed to load order: ${orderController.orderHistoryErrorMessage.value}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: orderController.fetchOrderHistory,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Try Again', style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.accentNeon),
            const SizedBox(height: 24),
            Text('No recent orders found!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Why not start shopping?', textAlign: TextAlign.center, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    final order = orderController.orderHistory.first;
    final address = addressController.addresses.first;
    final orderTime = order.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!.toLocal())
        : 'N/A';

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildSuccessCard(order.id, order.email, orderTime),
                const SizedBox(height: 20),
                _sectionTitle('Shipping Address'),
                SizedBox(width: 350, child: _buildAddressCard(address)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _sectionTitle('Order Items'),
                ...order.items.map((item) => _buildOrderItemCard(item)).toList(),
                const SizedBox(height: 16),
                _sectionTitle('Order Summary'),
                _buildOrderSummary(order),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(String orderId, String email, String time) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          Text("Thank you!", style: GoogleFonts.poppins(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("Your order #$orderId has been placed.", style: GoogleFonts.poppins(color: Colors.white)),
          const SizedBox(height: 8),
          Text("We sent an email to $email with your order confirmation.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("Time placed: $time", style: GoogleFonts.poppins(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Card(
      color: AppColors.neutralBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.location_on_rounded, color: AppColors.primaryPurple),
        title: Text(address.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text("${address.street}, ${address.city}, ${address.state}", style: GoogleFonts.poppins()),
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemModel item) {
    final imageUrl = item.productId.images.isNotEmpty
        ? item.productId.images.first
        : 'https://via.placeholder.com/60';

    return Card(
      color: AppColors.neutralBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, height: 60, width: 60, fit: BoxFit.cover),
        ),
        title: Text(item.variantName, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text("Qty: ${item.quantity}", style: GoogleFonts.poppins()),
        trailing: Text(
          NumberFormat.simpleCurrency().format(item.price * item.quantity),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    return Card(
      color: AppColors.neutralBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow("Subtotal", order.discount),
            _buildSummaryRow("Shipping", order.deliveryCharge),
            const Divider(),
            _buildSummaryRow("Total", order.orderAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double value, {bool isTotal = false}) {
    final style = GoogleFonts.poppins(
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
      fontSize: isTotal ? 16 : 14,
      color: AppColors.textDark,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(
              title == "Subtotal"
                  ? Icons.calculate
                  : title == "Shipping"
                  ? Icons.local_shipping
                  : Icons.payment,
              size: 18,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(title, style: style),
          ]),
          Text(NumberFormat.simpleCurrency().format(value), style: style),
        ],
      ),
    );
  }
}
