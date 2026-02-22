import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_service.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Check if user is logged in and has a valid token
  Future<bool> isLoggedIn() async {
    try {
      // Try to fetch profile to verify token validity
      final result = await getProfileFromApi();
      return result.fold((failure) => false, (success) => true);
    } catch (e) {
      return false;
    }
  }

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
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Verify Email OTP with Backend API
  Future<Either<Failure, Map<String, dynamic>>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.verifyOtp(email: email, otp: otp);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Resend OTP with Backend API
  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await _apiService.resendOtp(email: email);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete account from Backend API
  Future<Either<Failure, void>> deleteAccountFromApi() async {
    try {
      await _apiService.deleteAccount();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get user profile from Backend API
  Future<Either<Failure, Map<String, dynamic>>> getProfileFromApi() async {
    try {
      final response = await _apiService.getProfile();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Change password using Backend API
  Future<Either<Failure, Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(response);
    } catch (e) {
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

  /// Forgot password — send OTP to registered email
  Future<Either<Failure, Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.forgotPassword(email: email);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Forgot password — verify OTP and receive reset token
  Future<Either<Failure, Map<String, dynamic>>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.verifyForgotPasswordOtp(
        email: email,
        otp: otp,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Forgot password — reset password using the reset token
  Future<Either<Failure, Map<String, dynamic>>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
