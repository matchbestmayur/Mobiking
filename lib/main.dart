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
import 'app/modules/login/login_screen.dart'; // Assuming PhoneAuthScreen is here
import 'app/widgets/CategoryTab.dart'; // Assuming TabControllerGetX is here

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

  // Controllers (in order of dependency)
  Get.put(AddressController());
  Get.put(CartController());
  Get.put(HomeController());

  Get.put(CategoryController());
  Get.put(SubCategoryController());
  Get.put(WishlistController());
  Get.put(LoginController());
  // Ensure TabControllerGetX is indeed a GetxController and is initialized
  Get.put(TabControllerGetX());


  // OrderController (depends on OrderService, CartController, AddressController)
  Get.put(OrderController());
  Get.put(BottomNavController());

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mobiking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PhoneAuthScreen(), // Your starting screen
    );
  }
}