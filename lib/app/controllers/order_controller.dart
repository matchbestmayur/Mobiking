import 'package:get/get.dart';
import '../data/order_model.dart';
import '../services/order_service.dart';

class OrderController extends GetxController {
  final OrderService _service = OrderService();
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  Future<void> getOrders() async {
    try {
      isLoading.value = true;
      final data = await _service.fetchOrders();
      orders.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      final newOrder = await _service.placeOrder(order);
      orders.add(newOrder);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
