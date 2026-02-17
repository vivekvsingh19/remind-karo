import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_service.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiService _apiService;

  AuthRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService();

  /// Check if user is logged in
  bool get isLoggedIn => false; // Determined by API service token presence

  /// Signup with Backend API
  Future<Either<Failure, Map<String, dynamic>>> signupWithApi({
    required String name,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        mobileNumber: mobileNumber,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Login with Backend API
  Future<Either<Failure, Map<String, dynamic>>> loginWithApi({
    required String email,
    required String password,
  }) async {
    try {
      print('📄 Repository: Login attempt for $email');
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      print('✅ Repository: Login successful for $email');
      return Right(response);
    } catch (e) {
      print('❌ Repository: Login error for $email: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Verify Email OTP with Backend API
  Future<Either<Failure, Map<String, dynamic>>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('📄 Repository: Verifying OTP for $email');
      final response = await _apiService.verifyOtp(
        email: email,
        otp: otp,
      );
      print('✅ Repository: OTP verified for $email');
      return Right(response);
    } catch (e) {
      print('❌ Repository: OTP verification error for $email: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Resend OTP with Backend API
  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    try {
      print('📄 Repository: Resending OTP for $email');
      final response = await _apiService.resendOtp(email: email);
      print('✅ Repository: OTP resent for $email');
      return Right(response);
    } catch (e) {
      print('❌ Repository: OTP resend error for $email: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete account from Backend API
  Future<Either<Failure, void>> deleteAccountFromApi() async {
    try {
      print('📄 Repository: Deleting account');
      await _apiService.deleteAccount();
      print('✅ Repository: Account deleted');
      return const Right(null);
    } catch (e) {
      print('❌ Repository: Account deletion error: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get user profile from Backend API
  Future<Either<Failure, Map<String, dynamic>>> getProfileFromApi() async {
    try {
      print('📄 Repository: Fetching profile');
      final response = await _apiService.getProfile();
      print('✅ Repository: Profile fetched');
      return Right(response);
    } catch (e) {
      print('❌ Repository: Profile fetch error: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Sign out (clear local token)
  Future<Either<Failure, void>> signOut() async {
    try {
      // Logout from API
      await _apiService.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
