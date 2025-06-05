import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Product {
  final String name;
  final String imageUrl;
  final double price;
  final double? discountPrice;
  final double rating;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discountPrice,
    required this.rating,
  });
}
class WishlistCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const WishlistCard({
    super.key,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.discountPrice != null)
                      Text(
                        '₹${product.discountPrice}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '₹${product.price}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: product.discountPrice != null
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toString(),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

