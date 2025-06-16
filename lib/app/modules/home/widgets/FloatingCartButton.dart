import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Required for ImageFilter

class FloatingCartButton extends StatelessWidget {
  final VoidCallback onTap;
  final int itemCount;
  final String label;
  final List<String> productImageUrls;

  const FloatingCartButton({
    super.key,
    required this.onTap,
    this.itemCount = 0,
    this.label = "View Cart",
    this.productImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    double imageOverlap = 20.0;
    double imageSize = 32.0;
    // Calculate stack width to prevent overflow when images overlap
    double stackWidth = productImageUrls.isNotEmpty
        ? imageSize + (productImageUrls.length - 1) * imageOverlap
        : 0.0; // If no images, width is 0

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32), // Match ClipRRect's border radius
      child: ClipRRect( // Clip the blur effect to the button's shape
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter( // Apply the blur effect to content behind
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Semi-transparent dark background color for the button itself
              color: Colors.black.withOpacity(0.4), // Darker base with transparency
              borderRadius: BorderRadius.circular(32),
              // Optional: Add a subtle border for definition
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0), // Lighter border
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Images (only show if there are images)
                if (productImageUrls.isNotEmpty) ...[
                  SizedBox(
                    width: stackWidth,
                    height: imageSize,
                    child: Stack(
                      children: productImageUrls.asMap().entries.map((entry) {
                        int index = entry.key;
                        String url = entry.value;
                        return Positioned(
                          left: index * imageOverlap,
                          child: CircleAvatar(
                            radius: imageSize / 2,
                            backgroundColor: Colors.grey[800], // Darker background for avatar
                            backgroundImage: NetworkImage(url),
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading image: $url, $exception');
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Item Count and Label
                Text(
                  "$itemCount items | $label",
                  style: GoogleFonts.poppins(
                    color: Colors.white, // White text for strong contrast on dark background
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22), // Bright accent color
              ],
            ),
          ),
        ),
      ),
    );
  }
}