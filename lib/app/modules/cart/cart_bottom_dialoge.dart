import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/modules/cart/widget/CartItemCard.dart';
import 'package:mobiking/app/modules/checkout/CheckoutScreen.dart';




class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      cartController.loadCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),










      ),
      body: SafeArea(
        child: Obx(() {
          if (cartController.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some delicious items to get started!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Start Shopping',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical:12),
                  itemCount: cartController.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 1),
                  itemBuilder: (context, index) {
                    final cartItem = cartController.cartItems[index];


                    final productId = cartItem['productId']?['_id'] ?? '';
                    final variantName = cartItem['variantName'] ?? '';

                    return CartItemCard(
                      cartItem: cartItem,
                      onIncrement: cartController.isLoading.value
                          ? null
                          : () => cartController.addToCart(
                        productId: productId,
                        variantName: variantName,
                      ),
                      onDecrement: cartController.isLoading.value
                          ? null
                          : () => cartController.removeFromCart(
                        productId: productId,
                        variantName: variantName,
                      ),
                    );
                  },
                ),
              ),

              _buildCartSummary(),
            ],
          );
        }),
      ),


      floatingActionButton: Obx(() {
        return cartController.isLoading.value
            ? Container(

          color: Colors.black.withOpacity(0.25),
          width: Get.width,
          height: Get.height,
          child: const Center(child: CircularProgressIndicator()),
        )
            : const SizedBox.shrink();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCartSummary() {
    return Obx(() {
      final total = cartController.totalCartValue;
      final totalItems = cartController.totalCartItemsCount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal ($totalItems ${totalItems == 1 ? 'item' : 'items'}):',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: cartController.isLoading.value
                    ? null
                    : () {
                  Get.to(() => CheckoutScreen());
                  print("Cart Products for Checkout: ${cartController.cartItems.length}");

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Proceed to Checkout",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}