

import 'package:dio/dio.dart';

import '../data/login_model.dart';

class UserService {
  Dio _dio = Dio(BaseOptions(baseUrl: 'http://your-api-url.com'));

  void overrideDio(Dio dio) {
    _dio = dio;
  }


  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _dio.post('/users', data: user.toJson());
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
}
