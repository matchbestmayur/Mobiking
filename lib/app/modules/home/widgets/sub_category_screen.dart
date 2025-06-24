// lib/views/all_products_list_view.dart (or wherever AllProductsListView is located)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mobiking/app/modules/home/widgets/ProductCard.dart';
import '../../../data/product_model.dart';
import '../../../data/sub_category_model.dart';
import '../../../widgets/ProductCardWidget.dart';
import '../../Product_page/product_page.dart';


class AllProductsListView extends StatelessWidget {
  final List<SubCategory> subCategories;
  final Function(ProductModel)? onProductTap;

  const AllProductsListView({
    Key? key,
    required this.subCategories,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> allProducts = subCategories
        .expand((sub) => sub.products)
        .where((product) => product.sellingPrice.isNotEmpty)
        .toList();

    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: allProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = allProducts[index];
          // Use the reusable ProductCard widget
          return ProductCards(product: product,onTap: (p0) => Get.to(ProductPage(product: p0)) ,);
        },
      ),
    );
  }
}