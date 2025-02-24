import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://picsum.photos/v2/list';

  static Future<List<Map<String, dynamic>>> fetchImages(
      int page, int limit) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl?page=$page&limit=$limit'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}
