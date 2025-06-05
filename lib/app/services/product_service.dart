import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/product_model.dart';


class ProductService {
  static const String baseUrl = "https://mobiking-e-commerce-backend.vercel.app/api/v1";

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/products');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data'];

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products: ${response.reasonPhrase}");
    }
  }

  /// Create a new product
  Future<ProductModel> createProduct(ProductModel product) async {
    final url = Uri.parse('$baseUrl/products/create');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData['data']);
    } else {
      throw Exception("Failed to create product: ${response.reasonPhrase}");
    }
  }

  /// Fetch single product by slug (optional)
  Future<ProductModel> fetchProductBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/products/details/$slug');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData['data']);
    } else {
      throw Exception("Product not found");
    }
  }
}
