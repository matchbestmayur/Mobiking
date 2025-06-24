import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if AppTheme still relies on it
import 'package:mobiking/app/modules/home/widgets/ProductCard.dart'; // Corrected import
import '../../../data/group_model.dart';
import '../../../themes/app_theme.dart'; // Ensure this path is correct
import '../../Product_page/product_page.dart';
// import '_ProductCart.dart'; // This import seems to be for a different widget, removed if not directly used here

class GroupProductsScreen extends StatelessWidget {
  final GroupModel group;

  const GroupProductsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Light background for the screen
      appBar: AppBar(
        backgroundColor: AppColors.white, // Blinkit often has a white app bar
        foregroundColor: AppColors.textDark, // Dark text for app bar title
        elevation: 1, // Subtle shadow for AppBar
        centerTitle: true,
        title: Text(
          group.name,
          style: GoogleFonts.poppins( // Using Poppins as per your current setup
            fontSize: 20,
            fontWeight: FontWeight.w600, // Slightly less bold than w700
            color: AppColors.textDark, // Consistent dark text color
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark), // Dark back button
      ),
      body: group.products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textLight.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              'No products available for "${group.name}".',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check back later!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12.0), // Slightly adjusted padding
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0, // Increased spacing between columns
          mainAxisSpacing: 16.0, // Increased spacing between rows
          childAspectRatio: 0.61, // Adjusted aspect ratio to better fit content like Blinkit
        ),
        itemCount: group.products.length,
        itemBuilder: (context, index) {
          final product = group.products[index];
          return ProductCards(
            product: product,
            onTap: (tappedProduct) {
              Get.to(() => ProductPage(product: tappedProduct));
              debugPrint('Navigating to product page for: ${tappedProduct.name}');
            },
          );
        },
      ),
    );
  }
}