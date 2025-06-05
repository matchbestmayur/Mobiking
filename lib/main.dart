import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobiking/app/controllers/Home_controller.dart';
import 'package:mobiking/app/controllers/address_controller.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/controllers/category_controller.dart';
import 'package:mobiking/app/controllers/wishlist_controller.dart';
import 'package:mobiking/app/modules/Product_page/product_page.dart';
import 'package:mobiking/app/modules/address/AddressPage.dart';
import 'package:mobiking/app/modules/cart/cart_bottom_dialoge.dart';
import 'package:mobiking/app/modules/home/home_screen.dart';
import 'package:mobiking/app/modules/login/login_screen.dart';
import 'package:mobiking/app/modules/profile/profile_screen.dart';
import 'package:mobiking/app/widgets/CategoryTab.dart';
import 'package:mobiking/trial_screen/category_detail_screen.dart';
import 'app/controllers/login_controller.dart';
import 'app/services/login_service.dart';

Future<void> main() async {
  await GetStorage.init();
  Get.put(LoginService());
  Get.put(CartController());
  Get.put(HomeController());
   Get.put(TabControllerGetX());
   Get.put(AddressController());
  Get.put(CategoryController());
  Get.put(WishlistController());

  Get.put(LoginController());

  //  Get.find<CartController>().loadCartData(); // Load cart data here

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PhoneAuthScreen(), // Set PhoneAuthScreen as the initial screen
    );
  }
}
