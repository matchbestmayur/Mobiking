// lib/app/modules/home/widgets/ProductCard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/data/product_model.dart';

import 'ProductQuantitySelector.dart'; // Make sure this path is correct

class Product_Card extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel)? onTap;

  const Product_Card({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = product.images.isNotEmpty && product.images[0].isNotEmpty;
    final hasSellingPrice = product.sellingPrice.isNotEmpty;
    // Assuming originalPrice is part of ProductModel, or derived correctly.
    // If sellingPrice[0].price is null, originalPrice defaults to 5999.0
    final num originalPrice = product.sellingPrice.isNotEmpty && product.sellingPrice[0].price != null
        ? product.sellingPrice[0].price!
        : 5999.0;

    // Use sellingPrice[0].price if available, otherwise fallback to originalPrice
    final num sellingPrice = hasSellingPrice && product.sellingPrice[0].price != null
        ? product.sellingPrice[0].price!
        : originalPrice; // If no selling price, assume it's the original price


    int discountPercent = 0;
    if (hasSellingPrice && originalPrice > sellingPrice) {
      discountPercent = (((originalPrice - sellingPrice) / originalPrice) * 100).round();
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap?.call(product),
        child: Container(
          width: 140, // Max width of the card
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 108, // Fixed image height
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: hasImage
                      ? Image.network(
                    product.images[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  )
                      : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
              Padding(
                // Reduced vertical padding here from all(8.0)
                padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    if (discountPercent > 0)
                      Container(
                        // Reduced vertical padding for discount tag
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$discountPercent% OFF",
                          style: GoogleFonts.poppins(
                            fontSize: 9, // Slightly reduced font size
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4), // Reduced from 6
                    Row(
                      children: [
                        Text(
                          "₹${sellingPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4), // Reduced from 6
                        if (discountPercent > 0)
                          Text(
                            "₹${originalPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              fontSize: 10, // Slightly reduced font size
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    SizedBox(
                      width: double.infinity,
                      child: ProductQuantitySelector(product: product),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}