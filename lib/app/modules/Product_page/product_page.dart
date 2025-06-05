import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wishlist_controller.dart';
import '../../data/product_model.dart';
import '../../dummy/products_data.dart';
import '../../widgets/buildProductList.dart';
import '../../widgets/group_grid_section.dart' show GroupGridSection;
import 'widgets/product_image_banner.dart';
import 'widgets/product_title_price.dart';
import 'widgets/color_selector.dart';
import 'widgets/quantity_cart_row.dart';
import 'widgets/section_text.dart';
import 'widgets/similar_products_list.dart';
import 'widgets/featured_product_banner.dart';

class ProductPage extends StatefulWidget {
  final ProductModel product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedColorIndex = 0;

  void onColorSelected(int index, Map<String, dynamic> selectedColor) {
    setState(() {
      selectedColorIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Dynamic pricing
    final originalPrice = product.sellingPrice.isNotEmpty
        ? product.sellingPrice.first.price
        : 0;
    final discountedPrice = product.sellingPrice.length > 1
        ? product.sellingPrice[1].price
        : originalPrice;

    // Dynamic color options from variants map
    final colorOptions = product.variants.entries.map((entry) {
      return {
        'name': entry.key,
        'color': Colors.primaries[
        entry.key.hashCode % Colors.primaries.length], // auto color
      };
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image + Favorite Icon Button
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    ProductImageBanner(
                      imageUrls: product.images,
                      badgeText: "20% OFF",
                      onBack: () => Navigator.pop(context),
                      onFavorite: () {
                        // This will be called when favorite inside ProductImageBanner is tapped
                        final controller = Get.find<WishlistController>();
                        final isFavorite = controller.wishlist.contains(product.id);
                        if (isFavorite) {
                          controller.removeFromWishlist(product.id);
                        } else {
                          controller.addToWishlist(product.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product title & price
              ProductTitleAndPrice(
                title: product.fullName,
                originalPrice: originalPrice.toDouble(),
                discountedPrice: discountedPrice.toDouble(),
              ),
              const SizedBox(height: 12),

              // Color Selector (from variants)
              if (colorOptions.isNotEmpty)
                CustomColorSelector(
                  colorOptions: colorOptions,
                  onColorSelected: onColorSelected,
                ),
              const SizedBox(height: 16),

              // Quantity & Cart Button
              const QuantityAndCartRow(),
              const SizedBox(height: 20),

              // Description Section
              SectionText(
                title: 'Description',
                content: product.description.isNotEmpty
                    ? product.description
                    : 'No description available.',
              ),
              const SizedBox(height: 16),

              SectionText(
                title: 'Key Information',
                content: product.categoryId,
              ),
              const SizedBox(height: 20),

              // Similar Products (Dummy)
              Text(
                'Shop Latest Buds',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 320,
                child: buildProductList(
                  showBackground: false,
                  title: '',
                  products: dummyProducts,
                ),
              ),

              const SizedBox(height: 20),

              // Featured Product
              Text(
                'Checkout Featured Product',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FeaturedProductBanner(
                  imageUrl: product.images.length > 1
                      ? product.images[1]
                      : 'https://via.placeholder.com/300',
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Shop by Category',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // You can add more widgets here
            ],
          ),
        ),
      ),
    );
  }
}
