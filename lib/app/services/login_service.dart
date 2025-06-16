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
        // No need to store 'userData' here if LoginController handles individual keys.
        // If LoginController stores individual keys like 'accessToken', 'refreshToken', 'user',
        // then this line below is redundant or needs adjustment.
        // await box.write('userData', response.data); // Consider removing or adapting this line
        print(response.data); // Keep this for debugging response data
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

  Future<dio.Response> logout() async {
    try {
      // Read the accessToken directly from GetStorage
      final accessToken = box.read('accessToken'); // <--- CHANGE IS HERE

      if (accessToken == null) {
        throw Exception('Access token not found. User is not logged in.');
      }

      final response = await _dio.post(
        'https://mobiking-e-commerce-backend.vercel.app/api/v1/users/logout',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $accessToken', // Send the access token in the header
          },
        ),
      );

      if (response.statusCode == 200) {
        // Clear user data from Get Storage on successful logout
        // The LoginController's logout method already calls box.erase()
        // so this line might be redundant if you're consistent.
        // await box.remove('userData');
        print('User logged out successfully.');
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print('Error during logout: $e');
      throw e;
    }
  }
}