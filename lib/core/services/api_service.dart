import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API service for backend communication
class ApiService {
  // For physical device: Use your computer's local IP address
  // For emulator: Use 10.0.2.2
  static const String baseUrl = 'http://192.168.1.8:5000';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptor for token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Signup user
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'mobile_number': mobileNumber,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Save token if present
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout - clear token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Handle Dio errors
  String _handleError(DioException e) {
    print('=== DIO ERROR DEBUG ===');
    print('Error Type: ${e.type}');
    print('Message: ${e.message}');
    print('Response Code: ${e.response?.statusCode}');
    print('Request URL: ${e.requestOptions.uri}');
    print('========================');

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${e.response?.statusCode}';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout (30s). Make sure:\n'
            '1. Your phone is on the same WiFi network as your computer\n'
            '2. Backend is running on port 5000\n'
            '3. Firewall is not blocking the connection';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Backend may be slow.';
      case DioExceptionType.sendTimeout:
        return 'Request send timeout. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server.\n'
            'Backend: http://192.168.1.8:5000\n'
            'Check if backend is running and accessible.';
      default:
        return 'Error: ${e.message ?? "Unknown error"}';
    }
  }
}
