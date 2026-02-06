import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  // Get base URL from environment variable
  static String get baseUrl {
    // Priority 1: Use full URL if provided
    final fullUrl = dotenv.env['API_BASE_URL'];
    if (fullUrl != null && fullUrl.isNotEmpty) {
      return '$fullUrl/config';
    }

    // Priority 2: Build URL from host and port
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '3000';
    return 'http://$host:$port/api/config';
  }

  final Dio _dio = Dio();

  // Cache for configs
  Map<String, dynamic>? _firebaseConfig;
  Map<String, dynamic>? _zegoConfig;

  /// Get Firebase configuration from backend
  Future<Map<String, dynamic>> getFirebaseConfig() async {
    if (_firebaseConfig != null) {
      return _firebaseConfig!;
    }

    try {
      final response = await _dio.get('$baseUrl/firebase');
      if (response.data['success'] == true) {
        _firebaseConfig = response.data['data'];
        return _firebaseConfig!;
      }
      throw Exception('Failed to get Firebase config');
    } catch (e) {
      throw Exception('Error fetching Firebase config: $e');
    }
  }

  /// Get Zego configuration from backend
  Future<Map<String, dynamic>> getZegoConfig() async {
    if (_zegoConfig != null) {
      return _zegoConfig!;
    }

    try {
      final response = await _dio.get('$baseUrl/zego');
      if (response.data['success'] == true) {
        _zegoConfig = response.data['data'];
        return _zegoConfig!;
      }
      throw Exception('Failed to get Zego config');
    } catch (e) {
      throw Exception('Error fetching Zego config: $e');
    }
  }

  /// Generate Zego token for user (requires authentication)
  Future<String> generateZegoToken(String token, String roomId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/zego/token',
        data: {'roomId': roomId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']['token'];
      }
      throw Exception('Failed to generate Zego token');
    } catch (e) {
      throw Exception('Error generating Zego token: $e');
    }
  }

  /// Clear cached configs
  void clearCache() {
    _firebaseConfig = null;
    _zegoConfig = null;
  }
}
