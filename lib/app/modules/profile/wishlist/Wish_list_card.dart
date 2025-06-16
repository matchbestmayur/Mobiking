import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/data/product_model.dart'; // Ensure this path is correct
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppColors

class WishlistCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onRemove;
  final VoidCallback? onTap; // Optional: for making the card itself tappable

  const WishlistCard({
    super.key,
    required this.product,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the actual price to display.
    // Assuming product.sellingPrice.first is the regular price
    // and product.sellingPrice.length > 1 implies a discounted price at index 1.
    final regularPrice = product.sellingPrice.isNotEmpty ? product.sellingPrice.first.price : 0.0;
    final discountedPrice = product.sellingPrice.length > 1 ? product.sellingPrice[1].price : null;
    final bool hasDiscount = discountedPrice != null && discountedPrice < regularPrice;

    final displayPrice = hasDiscount ? discountedPrice! : regularPrice;

    return Card(
      color: AppColors.neutralBackground, // Use a white/neutral background for the card
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6, // Slightly higher elevation for a richer feel
      shadowColor: Colors.black.withOpacity(0.1), // More subtle and diffused shadow
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Product Image ---
              Container(
                width: 90, // Slightly larger image for impact
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightPurple.withOpacity(0.5), width: 1), // Themed subtle border
                  color: AppColors.neutralBackground, // Background for image container
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textLight.withOpacity(0.1), // Themed subtle shadow for the image
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images[0]
                        : "https://via.placeholder.com/90x90?text=No+Image", // Professional placeholder URL
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.neutralBackground,
                      child: Icon(Icons.broken_image_rounded, color: AppColors.textLight, size: 40), // Themed broken image icon
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // --- Product Details: Name, Price, Discount ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 17, // Adjusted font size for name
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark, // Consistent dark text color
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Display original price if there's a discount
                        if (hasDiscount) ...[
                          Text(
                            '₹${regularPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // Regular weight for strike-through
                              color: AppColors.textLight, // Lighter grey for strike-through price
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textLight,
                              decorationThickness: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8), // Space between original and discounted
                        ],
                        // Display the actual selling price (discounted or regular)
                        Text(
                          '₹${displayPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: hasDiscount ? 18 : 16, // Larger if discounted, standard if not
                            fontWeight: FontWeight.w700,
                            color: hasDiscount ? AppColors.danger : AppColors.textDark, // Red for discounted, dark for regular
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Remove Button ---
              IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.danger, size: 28), // Themed delete icon
                onPressed: onRemove,
                tooltip: 'Remove from Wishlist',
                splashRadius: 24, // Control splash effect radius
              ),
            ],
          ),
        ),
      ),
    );
  }
}