import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Ensure this path is correct for AppColors

// Assuming ProductModel is defined like this:
// class ProductModel {
//   final String id;
//   final String name;
//   final List<String> images;
//   final List<SellingPriceModel> sellingPrice; // Assuming this contains 'price'
//   // ... other fields
// }
//
// class SellingPriceModel {
//   final double? price;
//   // ... other fields
// }
import '../../../data/product_model.dart';

class SuggestedProductCard extends StatelessWidget {
  final ProductModel product;

  const SuggestedProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    // AppColors is custom, using it where appropriate
    // final ColorScheme colorScheme = theme.colorScheme; // Not used much directly here for custom colors

    final String imageUrl = product.images.isNotEmpty
        ? product.images[0]
        : 'https://via.placeholder.com/120x90';

    // Safely get price, handling potential empty list or null values
    final String displayPrice = (product.sellingPrice != null && product.sellingPrice.isNotEmpty && product.sellingPrice[0].price != null)
        ? "₹${product.sellingPrice[0].price!.toStringAsFixed(2)}" // Format to 2 decimal places
        : "N/A";

    return Container(
      width: 140, // Slightly reduced width for more items on screen horizontally
      margin: const EdgeInsets.only(right: 12.0, bottom: 8.0), // Spacing between cards
      clipBehavior: Clip.antiAlias, // Ensures content is clipped to borderRadius
      decoration: BoxDecoration(
        color: Colors.white, // Blinkit typically uses pure white cards
        borderRadius: BorderRadius.circular(8.0), // Slightly less rounded, more sharp look
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100, // Very subtle shadow
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Product Image ---
          // Image now gets a slight top/bottom padding for separation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0), // Slightly rounded image corners
              child: Image.network(
                imageUrl,
                width: double.infinity, // Fills available width
                height: 90, // Compact height
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 90,
                    color: Colors.grey.shade100, // Lighter placeholder
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.grey.shade300, // Lighter icon
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.success), // Use AppColors
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6.0), // Consistent spacing after image

          // --- Product Name and Price ---
          Expanded( // Allows content to take remaining space, useful if names are long
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Horizontal padding for text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Unnamed Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13, // Slightly smaller, more compact
                      fontWeight: FontWeight.w500, // Medium weight for readability
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(), // Pushes price and button to bottom
                  // The price is usually a distinct, larger element in Blinkit
                  Text(
                    displayPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 16, // Prominent price
                      fontWeight: FontWeight.w700, // Bold price
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6.0), // Space before button
                ],
              ),
            ),
          ),


          // --- Add to Cart Button (Bottom-aligned, often green) ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0), // Right and bottom padding
              child: Material(
                color: AppColors.success, // Use your success color (Blinkit green)
                borderRadius: BorderRadius.circular(6.0), // Match button corner radius to a subtle level
                child: InkWell(
                  onTap: () {
                    // TODO: Implement add to cart logic (e.g., call CartController.addToCart)
                    print('Add "${product.name}" to cart');
                  },
                  borderRadius: BorderRadius.circular(6.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Compact button padding
                    child: Text(
                      'ADD',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600, // Semibold text
                        fontSize: 12, // Small, crisp text
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}