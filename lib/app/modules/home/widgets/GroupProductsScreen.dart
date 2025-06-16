import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Corrected import: Make sure this path points to your ProductCard.dart file
import 'package:mobiking/app/modules/home/widgets/ProductCard.dart';

import '../../../data/group_model.dart';
import '../../../themes/app_theme.dart'; // Ensure this path is correct
import '../../Product_page/product_page.dart';
import '_ProductCart.dart'; // Ensure this path is correct

class GroupProductsScreen extends StatelessWidget {
  final GroupModel group;

  const GroupProductsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          group.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: group.products.isEmpty
          ? Center(
        child: Text(
          'No products available for ${group.name}.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textLight,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.70,
        ),
        itemCount: group.products.length,
        itemBuilder: (context, index) {
          final product = group.products[index];
          return Product_Card( // <--- CHANGE THIS LINE FROM _ProductCard TO ProductCard
            product: product,
            onTap: (tappedProduct) {
              Get.to(() => ProductPage(product: tappedProduct));
              print('Navigating to product page for: ${tappedProduct.name}');
            },
          );
        },
      ),
    );
  }
}