import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';

class ProductTitleAndPrice extends StatelessWidget {
  final String title;
  final double originalPrice;
  final double discountedPrice;

  const ProductTitleAndPrice({
    super.key,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final headingStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.neutralBackground,
          ),
          child: Text(
            title,
            style: headingStyle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${originalPrice.toStringAsFixed(0)}',
          style: headingStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.lightPurple,
          ),
        ),
        Text(
          '₹${discountedPrice.toStringAsFixed(0)}',
          style: headingStyle.copyWith(color: Colors.deepPurple),
        ),
      ],
    );
  }
}
