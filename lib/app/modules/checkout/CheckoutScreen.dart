import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobiking/app/modules/address/AddressPage.dart';
import 'package:mobiking/app/modules/checkout/widget/bill_section.dart';
import 'package:mobiking/app/modules/checkout/widget/cart_item_tile.dart';
import 'package:mobiking/app/modules/checkout/widget/suggested_product_card.dart';

import '../../controllers/address_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../data/AddressModel.dart';
import '../../data/product_model.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({Key? key}) : super(key: key);

  final cartController = Get.find<CartController>();
  final addressController = Get.find<AddressController>();
  final orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final neutralBackground = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: neutralBackground,
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Obx(() {
        final cartItems = cartController.cartItems;


        final cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant = cartItems.map((item) {
          final productData = item['productId'];
          final product = productData is Map<String, dynamic>
              ? ProductModel.fromJson(productData as Map<String, dynamic>)
              : ProductModel(
            id: '',
            name: 'Fallback Product',
            fullName: 'Fallback Product Full Name',
            slug: 'fallback-product',
            description: 'This is a fallback product.',
            active: false,
            newArrival: false,
            liked: false,
            bestSeller: false,
            recommended: false,
            sellingPrice: [],
            categoryId: '',
            stockIds: [],
            orderIds: [],
            groupIds: [],
            totalStock: 0,
            variants: {},
            images: [],
          );
          final quantity = item['quantity'] as int? ?? 1;
          final variantName = item['variantName'] as String? ?? 'Default';
          return {
            'product': product,
            'quantity': quantity,
            'variantName': variantName
          };
        }).toList();

        double itemTotal = cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant.fold(0.0, (sum, entry) {
          final ProductModel product = entry['product'] as ProductModel;
          final int quantity = entry['quantity'] as int;
          double itemPrice = 0.0;
          if (product.sellingPrice.isNotEmpty && product.sellingPrice[0].price != null) {
            itemPrice = product.sellingPrice[0].price.toDouble();
          }
          return sum + itemPrice * quantity;
        });

        double deliveryCharge = itemTotal > 0 ? 40.0 : 0.0;
        double gstCharge = (itemTotal * 0.18);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cart Items (${cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant.length})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant.map((entry) {
                final product = entry['product'] as ProductModel;
                final quantity = entry['quantity'] as int;
                final variantName = entry['variantName'].toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CartItemTile(
                    product: product,
                    quantity: quantity,
                    variantName: variantName,
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              BillSection(
                itemTotal: itemTotal.toInt(),
                deliveryCharge: deliveryCharge.toInt(),
                gstCharge: gstCharge.toInt(),
              ),
              const SizedBox(height: 32),
              Text(
                "You might also like",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: SuggestedProductCard(
                          product: cartProductsWithQuantityAndVariantAndVariantAndVariantAndVariant[index]['product'] as ProductModel),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildDynamicBottomAppBar(),
    );
  }

  Widget buildPaymentOption({
    required String title,
    String? description,
    required IconData icon,
    required VoidCallback? onTap,
    bool isLoading = false,
    bool isSelected = false,
  }) {
    final bool isDisabled = onTap == null || isLoading;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: isSelected
            ? BorderSide(color: Theme.of(Get.context!).primaryColor, width: 2.5)
            : BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      color: isDisabled ? Colors.grey.shade100 : (isSelected ? Theme.of(Get.context!).primaryColor.withOpacity(0.1) : Colors.white),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16.0),
        splashColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
        highlightColor: Theme.of(Get.context!).primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(Get.context!).primaryColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? Colors.grey.shade500 : Colors.black87,
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              isLoading
                  ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Get.context!).primaryColor),
                ),
              )
                  : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicBottomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 220,
      width: double.infinity,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Obx(() {
              final selected = addressController.selectedAddress.value;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_pin, color: selected != null ? Colors.green.shade600 : Colors.grey, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.label ?? 'No Address Selected',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: selected != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        if (selected != null) ...[
                          Text(
                            "${selected.street}, ${selected.city},",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${selected.state} - ${selected.pinCode}",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ] else
                          Text(
                            "Please add or select an address for delivery.",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => AddressPage());
                    },
                    child: Text(
                      selected != null ? "Change" : "Add/Select",
                      style: GoogleFonts.poppins(color: Theme.of(Get.context!).primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.grey),

            const SizedBox(height: 12),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Flexible(
                  flex: 2,
                  child: Obx(() {
                    return InkWell(
                      onTap: orderController.isLoading.value
                          ? null
                          : () => _showPaymentMethodSelectionDialog(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: orderController.isLoading.value
                              ? const Color(0xFF00B59C).withOpacity(0.6)
                              : const Color(0xFF00B59C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            orderController.isLoading.value
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              orderController.isLoading.value ? "Processing..." : "Pay Using",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 12),


                Flexible(
                  flex: 3,
                  child: Obx(() {
                    double subTotal = cartController.cartItems.fold(0.0, (sum, item) {
                      final productData = item['productId'];
                      final product = productData is Map<String, dynamic>
                          ? ProductModel.fromJson(productData)
                          : ProductModel(id: '', name: '', fullName: '', slug: '', description: '', images: [],
                          sellingPrice: [], variants: {}, active: false, newArrival: false, liked: false,
                          bestSeller: false, recommended: false, categoryId: '', stockIds: [], orderIds: [],
                          groupIds: [], totalStock: 0);
                      final quantity = item['quantity'] ?? 1;
                      double itemPrice = 0.0;
                      if (product.sellingPrice.isNotEmpty && product.sellingPrice[0].price != null) {
                        itemPrice = product.sellingPrice[0].price.toDouble();
                      }
                      return sum + itemPrice * quantity;
                    });

                    final deliveryCharge = subTotal > 0 ? 40.0 : 0.0;
                    final gstCharge = subTotal * 0.18;
                    final displayTotal = subTotal + deliveryCharge + gstCharge;

                    final isAddressSelected = addressController.selectedAddress.value != null;

                    return InkWell(
                      onTap: (orderController.isLoading.value || !isAddressSelected || cartController.cartItems.isEmpty)
                          ? null
                          : () {
                        _showPaymentMethodSelectionDialog();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: (orderController.isLoading.value || !isAddressSelected || cartController.cartItems.isEmpty)
                              ? const Color(0xFF6200EE).withOpacity(0.6)
                              : const Color(0xFF6200EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("₹${displayTotal.toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text("Total", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                              Row(
                                children: [
                                  if (orderController.isLoading.value)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  else
                                    Text("Place Order",
                                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  if (!orderController.isLoading.value)
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodSelectionDialog() {
    final RxString selectedPaymentMethod = ''.obs;

    Get.defaultDialog(
      title: "Select Payment Method",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
      radius: 20.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      backgroundColor: Colors.white,
      barrierDismissible: false,
      content: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPaymentOption(
              title: "Cash on Delivery (COD)",
              description: "Pay with cash upon delivery.",
              icon: Icons.money_rounded,
              onTap: orderController.isLoading.value
                  ? null
                  : () {
                selectedPaymentMethod.value = 'COD';
              },
              isLoading: orderController.isLoading.value && selectedPaymentMethod.value == 'COD',
              isSelected: selectedPaymentMethod.value == 'COD',
            ),
            const SizedBox(height: 8),
            buildPaymentOption(
              title: "Online Payment",
              description: "Pay securely online with cards or UPI.",
              icon: Icons.payment_rounded,
              onTap: orderController.isLoading.value
                  ? null
                  : () {
                selectedPaymentMethod.value = 'Online';
              },
              isLoading: orderController.isLoading.value && selectedPaymentMethod.value == 'Online',
              isSelected: selectedPaymentMethod.value == 'Online',
            ),
            const SizedBox(height: 20),
            Obx(() => Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                    ),
                    child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (selectedPaymentMethod.value.isEmpty || orderController.isLoading.value)
                        ? null // Disable button if no method selected or loading
                        : () async {
                      // First, show loading state immediately if an action is going to be taken
                      orderController.isLoading.value = true; // Indicate loading for the button

                      if (selectedPaymentMethod.value == 'COD') {
                        // Call placeOrder directly for COD
                        await orderController.placeOrder(method: 'COD');
                      } else if (selectedPaymentMethod.value == 'Online') {
                        // For Online payment, you want to inform the user and then proceed.

                        // 1. Give immediate visual feedback (snackbar)
                        Get.snackbar(
                          'Online Payment',
                          'Initiating secure payment...', // More active message
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.8),
                          colorText: Colors.white,
                          icon: const Icon(Icons.credit_card_outlined, color: Colors.white),
                          margin: const EdgeInsets.all(10),
                          borderRadius: 10,
                          animationDuration: const Duration(milliseconds: 300),
                          duration: const Duration(seconds: 2), // Short duration, as action follows
                        );

                        // 2. Dismiss the current bottom sheet or dialog (if this button is in one)
                        //    Consider if you want to dismiss immediately or after the API call.
                        //    Dismissing here gives a cleaner transition.
                        Get.back(); // Dismisses the current screen (e.g., payment method selection)

                        // 3. IMPORTANT: Now, actually call the online order placement logic
                        //    This call should typically handle the backend interaction
                        //    and then potentially redirect to a payment gateway.
                        await orderController.placeOrder(method: 'Online');

                        // The `orderController.placeOrder` method itself will
                        // handle `isLoading` state (setting it to false in its `finally` block),
                        // success/error snackbars, and navigation (e.g., to HomeScreen).
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                      elevation: 4,
                    ),
                    child: orderController.isLoading.value
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : Text('Proceed', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )),
          ],
        );
      }),
    );
  }
}