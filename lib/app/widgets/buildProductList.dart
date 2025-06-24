/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/modules/Product_page/product_page.dart';
import 'package:mobiking/app/widgets/group_grid_section.dart';

import '../data/group_model.dart';
import '../data/product_model.dart';
import '../themes/app_theme.dart';
import 'ProductCardWidget.dart';

Widget buildProductList({
  required bool showBackground,
  required String title,
  List<GroupModel>? groups,
  required List<ProductModel> products,
}) {
  return Container(
    color: showBackground ? AppColors.darkPurple : Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        GroupWithProductsSection(groups: groups ?? []),
        // Title row with "View All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14, // Compact header font size
                  letterSpacing: -0.2,
                  color: showBackground ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                "View All",
                style: GoogleFonts.poppins(
                  fontSize: 12, // Smaller secondary label
                  fontWeight: FontWeight.w400,
                  color: showBackground ? Colors.white70 : Colors.black54,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal ListView
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageUrl = product.images.isNotEmpty
                  ? product.images.first
                  : 'https://via.placeholder.com/150';

              final price = product.sellingPrice.isNotEmpty
                  ? product.sellingPrice.last.price.toStringAsFixed(0)
                  : '0';

              return GestureDetector(
                onTap: () {
                  Get.to(ProductPage(product: product));
                },
                child: ProductCard(
                  imageUrl: imageUrl,
                  name: product.name,
                  price: price,
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
*/
