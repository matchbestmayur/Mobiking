import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/Home_model.dart';

class HomeService {
  Future<HomeLayoutModel?> getHomeLayout() async {
    final url = Uri.parse('https://mobiking-e-commerce-backend.vercel.app/api/v1/home/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print("Raw JSON: $jsonData"); // debug print


      if (jsonData is Map<String, dynamic>) {
        final data = jsonData['data'];
        if (data is Map<String, dynamic>) {
          // Debug prints for groups and banners inside data
          print("groups field raw: ${data['groups']}");
          print("banners field raw: ${data['banners']}");

          return HomeLayoutModel.fromJson(data);
        } else {
          print("Data field is not a Map");
          return null;
        }
      } else {
        print("Unexpected JSON format, expected Map<String, dynamic>");
        return null;
      }
    } else {
      print("Failed to fetch home layout: ${response.statusCode}");
      return null;
    }
  }


}
