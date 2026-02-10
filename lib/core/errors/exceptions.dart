/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server-related exception
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Cache/Local storage exception
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'network-error',
  });
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

/// Firestore exception
class FirestoreException extends AppException {
  const FirestoreException({required super.message, super.code});
}

/// Notification exception
class NotificationException extends AppException {
  const NotificationException({required super.message, super.code});
}
