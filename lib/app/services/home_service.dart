import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/Home_model.dart';


class HomeService {
  Future<HomeLayoutModel> getHomeLayout() async {
    final url = Uri.parse('https://mobiking-e-commerce-backend.vercel.app/api/v1/home/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print("Home Service Response StatusCode: ${response.statusCode}");
      print("Home Service Raw Response: ${responseBody}");
      final jsonBody = json.decode(responseBody);

      print("Home Service Response Data: ${jsonBody['data']}");
      return HomeLayoutModel.fromJson(jsonBody['data']);
    } else {
      throw Exception('Failed to load home layout');
    }
  }
}
