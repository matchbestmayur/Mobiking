import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/login_service.dart';
import 'package:dio/dio.dart' as dio;

class LoginController extends GetxController {
  final LoginService loginService = Get.find<LoginService>();
  final TextEditingController phoneController = TextEditingController();
  RxBool isLoading = false.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  // Helper method to get user data from Get Storage
  dynamic getUserData(String key) {
    var userData = box.read('userData');
    if (userData != null && userData['data'] != null && userData['data']['user'] != null) {
      return userData['data']['user'][key];
    }
    return null;
  }

  Future<void> login() async {
    String phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      isLoading.value = true;
      try {
        dio.Response response = await loginService.login(phone);
        isLoading.value = false;
        if (response.statusCode == 200) {
          // Login successful
          Get.snackbar('Success', response.data['message'], backgroundColor: Colors.green);
           print('User data: ${box.read('userData')}');
          // Example of how to use the getUserData method
          String? userId = getUserData('_id');
          print('User ID: $userId');
        } else {
          // Login failed
          Get.snackbar('Error', response.data['message'], backgroundColor: Colors.red);
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'An error occurred', backgroundColor: Colors.red);
      }
    } else {
      Get.snackbar('Error', 'Please enter your phone number', backgroundColor: Colors.red);
    }
  }
}
