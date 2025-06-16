import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/modules/Product_page/product_page.dart';
import 'package:mobiking/app/modules/Product_page/widgets/VariantSelectorBottomSheet.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import '../data/cart_model.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String originalPrice;
  final String discount;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.originalPrice = '5999',
    this.discount = '90% off',
  });


  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    return Container(
      width: 140,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main column content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neutralBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
                ),
              ),

              const SizedBox(height: 24), // space for ADD button

              // Product Name
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // Discount Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  discount,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$price',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '₹$originalPrice',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Floating ADD button (half on image, half below)
          Positioned(
            top: 90, // Adjust this based on your image height
            right: 2,
            child: GestureDetector(
                onTap: () {
                  // Define your dummy product list
                  List<pro> dummyProducts = [
                    pro(name: "Rockwear 45C", price: 1499.0, variants: ["Black", "Gray"]),
                    pro(name: "Airbuds 14T", price: 1099.0), // No variant
                    pro(name: "Gaming Headset", price: 1999.0, variants: ["Red", "Blue", "Green"]),
                  ];

                  // Pick a specific product (for example: index 0)
                  pro product = dummyProducts[0]; // <-- You can dynamically pick which product here

                  if (product.hasVariants) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) {
                        final height = MediaQuery.of(context).size.height * 0.5;
                        return SizedBox(
                          height: height,
                          width: double.maxFinite,
                          child: Material(
                            child: VariantSelectorBottomSheet(product: product),
                          ),
                        );
                      },
                    );
                  } else {
                    final box = GetStorage();
                    final userData = box.read('userData') ?? {};

                    // Assuming userData contains cartId (adjust based on your actual data structure)
                    final cartId = userData['cartId'] ?? '';

                    cartController.addToCart(
                      productId: '683e8aa4352ed33496cc8193',
                      variantName: 'Raging Black',

                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.name} added to cart")),
                    );
                  }
                },
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  "ADD",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
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
