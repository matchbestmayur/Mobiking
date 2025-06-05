
import 'package:http/http.dart' as http;
import 'dart:convert';

class WishlistService {
  static const String baseUrl = 'https://mobiking-e-commerce-backend.vercel.app/api/v1/users/whishlist';

  Future<bool> addToWishlist(String productId) async {
    final url = Uri.parse('$baseUrl/add');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId}),
      );

      if (response.statusCode == 200) {
        return true; // Or parse the response if it contains data
      } else {
        print('Failed to add to wishlist. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding to wishlist: \$e');
      return false;
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    final url = Uri.parse('$baseUrl/remove');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId}),
      );

      if (response.statusCode == 200) {
        return true; // Or parse the response if it contains data
      } else {
        print('Failed to remove from wishlist. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing from wishlist: \$e');
      return false;
    }
  }
}
