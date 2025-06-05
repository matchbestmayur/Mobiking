import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import 'Wish_list_card.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  // Dummy wishlist data - moved here outside WishlistCard
  final List<Product> wishlist = [
    Product(
      name: 'Sport Bluetooth Earbuds',
      imageUrl:
      'https://m.media-amazon.com/images/I/318URyFXyFL._SX300_SY300_QL70_FMwebp_.jpg', // earbuds
      price: 79.99,
      discountPrice: null,
      rating: 4.2,
    ),
    Product(
      name: 'Studio Monitoring Headphones',
      imageUrl:
      'https://m.media-amazon.com/images/I/41x390ObJ+L._SY300_SX300_.jpg', // headphone
      price: 150.00,
      discountPrice: 130.00,
      rating: 4.8,
    ),
    Product(
      name: 'Compact Earbuds with Mic',
      imageUrl:
      'https://m.media-amazon.com/images/I/61IUz4cSa7L._SX522_.jpg', // earbuds
      price: 49.99,
      discountPrice: 39.99,
      rating: 4.3,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // light grey
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Text(
          'My Wishlist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WishlistCard(
              product: wishlist[index],
              onRemove: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${wishlist[index].name} removed from wishlist'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

}
