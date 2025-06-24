import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome and DeviceOrientation
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobiking/app/controllers/BottomNavController.dart';



import 'package:mobiking/app/controllers/address_controller.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/controllers/category_controller.dart';
import 'package:mobiking/app/controllers/order_controller.dart';
import 'package:mobiking/app/controllers/query_getx_controller.dart';
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/controllers/wishlist_controller.dart';
import 'package:mobiking/app/controllers/login_controller.dart';
import 'package:mobiking/app/services/AddressService.dart';
import 'package:mobiking/app/services/login_service.dart';
import 'package:mobiking/app/services/order_service.dart';
import 'package:mobiking/app/services/query_service.dart';

import 'app/controllers/Home_controller.dart';
// Correct import paths for new screens/controllers/services
import 'app/controllers/system_ui_controller.dart';
import 'app/controllers/tab_controller_getx.dart';
import 'app/modules/login/login_screen.dart'; // Assuming PhoneAuthScreen is here
import 'app/services/Sound_Service.dart';
import 'app/themes/app_theme.dart';
import 'app/widgets/CategoryTab.dart'; // Assuming TabControllerGetX is here
import 'app/services/connectivity_service.dart'; // NEW
import 'app/controllers/connectivity_controller.dart'; // NEW
import 'app/modules/no_network/no_network_screen.dart'; // NEW


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
  Get.put(SoundService());
  Get.put(QueryService());

  // Controllers (in order of dependency)
  Get.put(AddressController());
  Get.put(CartController());
  Get.put(HomeController());

  Get.put(CategoryController());
  Get.put(SubCategoryController());
  Get.put(WishlistController());
  Get.put(LoginController());
  Get.put(TabControllerGetX()); // Make sure this class is defined
  Get.put(ConnectivityController()); // NEW: Initialize ConnectivityController
  Get.put(SystemUiController());
  Get.put(QueryGetXController());

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

    // Define your desired global padding/margin
    const EdgeInsets globalPadding = EdgeInsets.symmetric(vertical: 8); // Example: 16px horizontal padding

    return GetMaterialApp(
      title: 'Mobiking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Obx(() {
        Widget content;
        if (connectivityController.isConnected.value) {
          content = PhoneAuthScreen(); // Your normal starting screen
        } else {
          content = NoNetworkScreen(
            onRetry: () {
              // When RETRY is pressed, attempt to recheck connectivity
              connectivityController.retryConnection();
            },
          );
        }

        // Apply global padding here
        return Padding(
          padding: globalPadding,
          child: content,
        );
      }),
    );
  }
}

