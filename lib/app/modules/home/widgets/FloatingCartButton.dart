import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    double stackWidth = productImageUrls.length > 1
        ? imageSize + (productImageUrls.length - 1) * imageOverlap
        : imageSize;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ FIX: Wrap Stack in SizedBox with calculated width
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
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(url),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              "$itemCount items | $label",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),

            const SizedBox(width: 10),

            const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
