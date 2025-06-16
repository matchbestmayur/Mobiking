/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/product_controller.dart';
import '../data/category_model.dart';
import '../data/product_model.dart';
import '../data/stock_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/Product_page/product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String slug;
  final ProductController controller = Get.put(ProductController());

  ProductDetailPage({super.key, required this.slug}) {
    // Fetch product by slug when page is created
    Future.delayed(Duration.zero, () {
      controller.fetchProductBySlug(slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.selectedProduct.value;
        if (product == null) {
          return const Center(child: Text("No product found"));
        }

        // Use your designed ProductPage
        return ProductPage(product: product);
      }),
    );
  }
}


final List<ProductModel> dummyProducts = [
  ProductModel(
    id: 'product-001',
    name: 'boAt Stone Uno',
    fullName: 'boAt Stone Uno 3 W Bluetooth Speaker (Raging Black, Mono Channel)',
    slug: 'boat-stone-uno-3-w-bluetooth-speaker',
    description:
    'Portable Bluetooth speaker with clear sound, mono channel, and 3W output.',
    active: true,
    newArrival: false,
    liked: false,
    bestSeller: false,
    recommended: false,
    sellingPrice: [
      SellingPrice(price: 2990),
    ],
    categoryId: 'cat-001',
    stockIds: ['stock-001', 'stock-002' ],


    orderIds: [],
    groupIds: [],
           images: [
      'https://res.cloudinary.com/dphu7yagk/image/upload/v1748929187/pdqmg0yxejhcwroucq7h.webp',
      'https://res.cloudinary.com/dphu7yagk/image/upload/v1748929187/pwljxcwkhddwyxijzoid.webp',
      'https://res.cloudinary.com/dphu7yagk/image/upload/v1748929187/tmz9iwgktd1g2upulbv0.webp',
    ],
    totalStock: 20,
    variants: {
      'Raging Black': 20,
    },
  ),
];
*/
