import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

class LoginService extends GetxService {
  final dio.Dio _dio = dio.Dio();
  final box = GetStorage();

  Future<dio.Response> login(String phone) async {
    try {
      final response = await _dio.post(
        'https://mobiking-e-commerce-backend.vercel.app/api/v1/users/login',
        data: {
          'phoneNo': phone,
          'role': 'user',
        },
      );
      if (response.statusCode == 200) {
        // Store user data in Get Storage
        await box.write('userData', response.data);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      // Handle errors here
      print(e);
      throw e;
    }
  }
}
