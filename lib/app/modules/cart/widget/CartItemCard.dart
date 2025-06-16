import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import 'QuantitySelector.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> cartItem;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely extract product data and cast it
    final productData = cartItem['productId'] as Map<String, dynamic>? ?? {};

    // Extract product details
    final String productName = productData['name'] ?? 'Unknown Product';
    final String variantName = cartItem['variantName'] ?? 'Default'; // Get the variant name
    final double pricePerItem = (cartItem['pricePerItem'] as num?)?.toDouble() ?? 0.0; // Use pricePerItem
    final int quantity = (cartItem['quantity'] as int?) ?? 0;

    // Extract image URL safely
    String imageUrl = 'https://via.placeholder.com/100'; // Default placeholder
    final images = productData['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images[0];
      if (firstImage is Map && firstImage.containsKey('url')) {
        imageUrl = firstImage['url'] as String;
      } else if (firstImage is String) { // In case the image is just a URL string directly
        imageUrl = firstImage;
      }
    }

    // --- Stock Information (Assumption) ---
    // If your productData includes 'variants' and 'stock' for each variant,
    // you would access it like this. Adjust paths as per your actual data structure.
    int? variantStock;
    if (productData.containsKey('variants') && productData['variants'] is Map) {
      final variantsMap = productData['variants'] as Map<String, dynamic>;
      if (variantsMap.containsKey(variantName) && variantsMap[variantName] is Map) {
        final variantDetails = variantsMap[variantName] as Map<String, dynamic>;
        variantStock = variantDetails['stock'] as int?;
      }
    }


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
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.grey[200],
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details (Name, Variant, Price)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Display Variant Name
                Text(
                  'Variant: $variantName',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                // Display Stock (if available)
                if (variantStock != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Stock: $variantStock',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: variantStock! > 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Quantity Selector and Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 110,
                child: QuantitySelector(
                  quantity: quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}