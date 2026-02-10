part of 'auth_bloc.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check initial authentication state
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Send OTP to phone number
class AuthSendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP
class AuthVerifyOtpRequested extends AuthEvent {
  final String otp;

  const AuthVerifyOtpRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// Create user profile
class AuthCreateProfileRequested extends AuthEvent {
  final String name;
  final String phoneNumber;
  final String? email;

  const AuthCreateProfileRequested({
    required this.name,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [name, phoneNumber, email];
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Sign in with email
class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register with email
class AuthRegisterWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Reset to phone input
class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}

/// Guest login
class AuthGuestLoginRequested extends AuthEvent {
  const AuthGuestLoginRequested();
}
