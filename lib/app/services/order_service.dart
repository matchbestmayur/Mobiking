import 'package:dio/dio.dart';
import '../data/order_model.dart';

class OrderService {

  Dio _dio = Dio(BaseOptions(baseUrl: 'http://your-api-url.com'));


  void overrideDio(Dio dio) {
    _dio = dio;
  }

  Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await _dio.get('/orders');
      return (response.data as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final response = await _dio.post('/orders', data: order.toJson());
      return OrderModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error placing order: $e');
    }
  }
}
