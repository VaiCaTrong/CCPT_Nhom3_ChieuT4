import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ApiClient {
  // Get base URL from environment variable
  static String get baseUrl {
    // Priority 1: Use full URL if provided
    final fullUrl = dotenv.env['API_BASE_URL'];
    if (fullUrl != null && fullUrl.isNotEmpty) {
      return fullUrl;
    }

    // Priority 2: Build URL from host and port
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '3000';
    return 'http://$host:$port/api';
  }

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token expiration
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          if (await _refreshAccessToken()) {
            // Retry the request
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));

    // Load tokens from storage
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> _refreshAccessToken() async {
    try {
      if (_refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': _refreshToken,
      });

      if (response.data['success'] == true) {
        await _saveTokens(
          response.data['data']['accessToken'],
          response.data['data']['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // HTTP Methods
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // Auth methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.data['success'] == true) {
      await _saveTokens(
        response.data['data']['accessToken'],
        response.data['data']['refreshToken'],
      );
    }

    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.data['success'] == true) {
      await _saveTokens(
        response.data['data']['accessToken'],
        response.data['data']['refreshToken'],
      );
    }

    return response.data;
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout');
    } finally {
      await clearTokens();
    }
  }

  bool get isAuthenticated => _accessToken != null;

  /// Upload images to server
  /// Returns list of public URLs
  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String roomId,
  }) async {
    final formData = FormData();

    // Add roomId
    formData.fields.add(MapEntry('roomId', roomId));

    // Add images
    for (var image in images) {
      final bytes = await image.readAsBytes();
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(bytes, filename: image.name),
      ));
    }

    final response = await _dio.post(
      '/upload/images',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.data['success'] == true) {
      return List<String>.from(response.data['data']['urls']);
    }
    throw Exception(response.data['error'] ?? 'Upload failed');
  }
}
