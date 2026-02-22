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

/// Sign in with Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Reset to phone input
class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}

/// Guest login
class AuthGuestLoginRequested extends AuthEvent {
  const AuthGuestLoginRequested();
}

/// Backend API Signup
class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String mobileNumber;

  const AuthSignupRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber,
  });

  @override
  List<Object?> get props => [name, email, password, mobileNumber];
}

/// Backend API Login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Verify Email OTP (Email verification flow)
class AuthVerifyEmailOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  final String name;
  final String password;
  final String mobileNumber;

  const AuthVerifyEmailOtpRequested({
    required this.email,
    required this.otp,
    required this.name,
    required this.password,
    required this.mobileNumber,
  });

  @override
  List<Object?> get props => [email, otp, name, password, mobileNumber];
}

/// Resend OTP
class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Delete account
class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

/// Change password
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
