import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://picsum.photos/v2/list?page=1&limit=30';

  static Future<List<Map<String, dynamic>>> fetchImages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>(); // Trả về đúng kiểu dữ liệu
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}
