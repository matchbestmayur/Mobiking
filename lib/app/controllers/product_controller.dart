import 'package:get/get.dart';

import '../data/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();
  var productList = <ProductModel>[].obs;
  var isLoading = false.obs;
  var selectedProduct = Rxn<ProductModel>();

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final products = await _productService.getAllProducts();
      productList.assignAll(products);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      isLoading.value = true;
      final newProduct = await _productService.createProduct(product);
      productList.add(newProduct);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductBySlug(String slug) async {
    try {
      isLoading.value = true;
      final product = await _productService.fetchProductBySlug(slug);
      selectedProduct.value = product;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
