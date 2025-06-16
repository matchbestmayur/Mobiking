
import 'package:get/get.dart';


import '../data/Home_model.dart';

import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _service = HomeService();
  var isLoading = false.obs;
  var homeData = Rxn<HomeLayoutModel>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeLayout();
  }

  Future<void> fetchHomeLayout() async {
    try {
      isLoading.value = true;
      final result = await _service.getHomeLayout();
      print("Fetched result from service: $result");  
      homeData.value = result;
      print("homeData set to: ${homeData.value}");
    } catch (e) {
      print("\n \n \n Error fetching home layout: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
