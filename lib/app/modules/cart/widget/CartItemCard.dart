import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../themes/app_theme.dart';
import 'QuantitySelector.dart';
//import '../../../data/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final dynamic cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = cartItem['productId'];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📸 Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: AppColors.neutralBackground,
              child: Image.network(
                product['images'][0],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 📝 Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Product Name',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem['price'].toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 🔢 Quantity Selector
          SizedBox(
            width: 110,
            child: QuantitySelector(
              quantity: cartItem['quantity'],
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ),
        ],
      ),
    );
  }
}