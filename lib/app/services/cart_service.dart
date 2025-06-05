import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CartService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'https://mobiking-e-commerce-backend.vercel.app/api/v1'));
  final box = GetStorage();

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required String cartId,
    required String variantName,
  }) async {
    try {
      String? accessToken = box.read('userData')?['data']?['accessToken'];
      if (accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.post('/cart/add', data: {
        'productId': productId,
        'cartId': cartId,
        'variantName': variantName,
      });

      return response.data;
    } catch (e) {
      print('Add to cart error: $e');
      rethrow;
    }
  }
}
