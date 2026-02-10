import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures (Firebase, API, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return const AuthFailure(
          message: 'The phone number is invalid. Please enter a valid number.',
          code: 'invalid-phone-number',
        );
      case 'invalid-verification-code':
        return const AuthFailure(
          message: 'The verification code is incorrect. Please try again.',
          code: 'invalid-verification-code',
        );
      case 'session-expired':
        return const AuthFailure(
          message: 'Verification session expired. Please request a new OTP.',
          code: 'session-expired',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled.',
          code: 'user-disabled',
        );
      case 'user-not-found':
        return const AuthFailure(
          message: 'No account found with these credentials.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'This email is already registered.',
          code: 'email-already-in-use',
        );
      default:
        return AuthFailure(
          message: 'Authentication failed. Please try again.',
          code: code,
        );
    }
  }
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network-error',
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// Firestore operation failures
class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message, super.code});

  factory FirestoreFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const FirestoreFailure(
          message: 'You don\'t have permission to perform this action.',
          code: 'permission-denied',
        );
      case 'not-found':
        return const FirestoreFailure(
          message: 'The requested data was not found.',
          code: 'not-found',
        );
      case 'already-exists':
        return const FirestoreFailure(
          message: 'This record already exists.',
          code: 'already-exists',
        );
      default:
        return FirestoreFailure(
          message: 'Database operation failed. Please try again.',
          code: code,
        );
    }
  }
}

/// Notification-related failures
class NotificationFailure extends Failure {
  const NotificationFailure({required super.message, super.code});
}
