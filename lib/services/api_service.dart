import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/authentication-service/v1/photo/list';

  static Future<List<Map<String, dynamic>>> fetchImages(
      int page, int limit) async {
    try {
      final url = '$baseUrl?order=ASC&page=$page&take=$limit';
      print('📡 Fetching from: $url'); // Debug URL

      // Đọc access token từ biến môi trường
      final String? accessToken = dotenv.env['ACCESS_TOKEN'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token is missing in .env file');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('🔄 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> imageList = jsonResponse['data']['data'];

        return imageList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('❌ Error fetching images: $e');
      return [];
    }
  }
}
