import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// API service for backend communication
class ApiService {
  // Configuration options for different environments:
  // 1. Same WiFi Network (192.168.1.x): Use 192.168.1.8:5000
  // 2. Android Emulator: Use 10.0.2.2:5000
  // 3. Different Network/Mobile Data: Use Tailscale IP or public IP
  // 4. Local testing: Use 127.0.0.1:5000 or localhost:5000

  static String get baseUrl {
    // ⚠️ IMPORTANT: Change this based on your device type:

    // For ANDROID EMULATOR: Use 10.0.2.2 (emulator's special alias for host)
    // return 'http://10.0.2.2:5000';

    // For PHYSICAL DEVICE on same WiFi: Use your computer's local IP
    return 'http://192.168.1.8:5000';

    // For DIFFERENT NETWORK or REMOTE: Use Tailscale VPN IP
    // return 'http://100.85.59.107:5000';
  }

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptor for token and error handling
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
      print('🔌 API: Sending login request for $email');
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      print('✅ API: Login response received: ${response.statusCode}');

      // Save token if present
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
        print('✅ API: Token saved to SharedPreferences');
      }

      return response.data;
    } on DioException catch (e) {
      print('❌ API: Login failed - ${e.type}: ${e.message}');
      print('❌ API: Response: ${e.response?.data}');
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

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔌 API: Sending OTP verification request for $email');
      final response = await _dio.post(
        '/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      print(
        '✅ API: OTP verification response received: ${response.statusCode}',
      );
      return response.data;
    } on DioException catch (e) {
      print('❌ API: OTP verification failed - ${e.type}: ${e.message}');
      print('❌ API: Response: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await _dio.post('/resend-otp', data: {'email': email});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      print('🗑️  Sending DELETE request to /delete-account');
      final response = await _dio.delete('/delete-account');
      print('✅ Delete response status: ${response.statusCode}');
      print('✅ Delete response data: ${response.data}');
      // Clear token after successful deletion
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('✅ Token cleared from SharedPreferences');
      return response.data;
    } on DioException catch (e) {
      print('❌ DIO Error: ${e.type} - ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
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
            'Backend: $baseUrl\n'
            'Check if backend is running and accessible.';
      default:
        return 'Error: ${e.message ?? "Unknown error"}';
    }
  }
}
