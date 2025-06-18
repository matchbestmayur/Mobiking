import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome and DeviceOrientation
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobiking/app/controllers/BottomNavController.dart';


import 'package:mobiking/app/controllers/address_controller.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/controllers/category_controller.dart';
import 'package:mobiking/app/controllers/order_controller.dart';
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/controllers/wishlist_controller.dart';
import 'package:mobiking/app/controllers/login_controller.dart';
import 'package:mobiking/app/services/AddressService.dart';
import 'package:mobiking/app/services/login_service.dart';
import 'package:mobiking/app/services/order_service.dart';

import 'app/controllers/Home_controller.dart';
// Correct import paths for new screens/controllers/services
import 'app/modules/login/login_screen.dart';
import 'app/widgets/CategoryTab.dart';
import 'app/services/connectivity_service.dart'; // NEW
import 'app/controllers/connectivity_controller.dart'; // NEW
import 'app/modules/no_network/no_network_screen.dart'; // NEW

// Make sure TabControllerGetX is defined or imported correctly.
// For example, if it's in CategoryTab.dart, that import is fine.
// If it's a separate file, make sure to import it.
// Placeholder if needed:
// class TabControllerGetX extends GetxController {
//   final RxInt selectedIndex = 0.obs;
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  // Services
  Get.put(LoginService());
  Get.put(OrderService());
  Get.put(AddressService());
  Get.put(ConnectivityService()); // NEW: Initialize ConnectivityService

  // Controllers (in order of dependency)
  Get.put(AddressController());
  Get.put(CartController());
  Get.put(HomeController());

  Get.put(CategoryController());
  Get.put(SubCategoryController());
  Get.put(WishlistController());
  Get.put(LoginController());
  Get.put(TabControllerGetX());
  Get.put(ConnectivityController()); // NEW: Initialize ConnectivityController


  // OrderController (depends on OrderService, CartController, AddressController)
  Get.put(OrderController());
  Get.put(BottomNavController());

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the ConnectivityController instance
    final ConnectivityController connectivityController = Get.find<ConnectivityController>();

    return GetMaterialApp(
      title: 'Mobiking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Home now conditionally displays based on connectivity
      home: Obx(() {
        if (connectivityController.isConnected.value) {
          return PhoneAuthScreen(); // Your normal starting screen
        } else {
          return NoNetworkScreen(
            onRetry: () {
              // When RETRY is pressed, attempt to recheck connectivity
              connectivityController.retryConnection();
            },
          );
        }
      }),
    );
  }
}
