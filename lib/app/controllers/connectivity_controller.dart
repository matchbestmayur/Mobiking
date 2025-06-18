
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/services/connectivity_service.dart';

class ConnectivityController extends GetxController {
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final RxBool isConnected = true.obs; // Assume connected initially

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // Initial check
    _connectivityService.checkConnectivity().then((result) {
      _updateConnectionStatus(result);
    });

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      // Optionally show a snackbar or dialog if they're currently on a different screen
      // if (Get.currentRoute != '/NoNetworkScreen') {
      //   Get.snackbar('Offline', 'You are currently offline!',
      //       snackPosition: SnackPosition.BOTTOM,
      //       backgroundColor: Colors.red,
      //       colorText: Colors.white);
      // }
    } else {
      isConnected.value = true;
      // if (Get.currentRoute == '/NoNetworkScreen') {
      //   Get.back(); // Automatically pop the NoNetworkScreen if connectivity is restored
      // }
      // Get.snackbar('Online', 'You are back online!',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.green,
      //     colorText: Colors.white);
    }
  }

  // This method will be called when the user taps 'RETRY' on the NoNetworkScreen
  Future<void> retryConnection() async {
    final result = await _connectivityService.checkConnectivity();
    _updateConnectionStatus(result);
    // If connection is restored, the Obx in MyApp will handle the navigation back
  }
}
