part of 'auth_bloc.dart';

/// Authentication steps
enum AuthStep {
  phone,
  otp,
  profileSetup,
  authenticated,
  guest,
  emailOtpVerification,
  forgotPasswordOtpSent,
  passwordResetSuccess,
}

/// Auth state
class AuthState extends Equatable {
  final AuthStep step;
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final String? phoneNumber;
  final UserModel? userProfile;
  final String? resetToken;

  const AuthState({
    this.step = AuthStep.phone,
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.phoneNumber,
    this.userProfile,
    this.resetToken,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Authenticated state
  factory AuthState.authenticated({required UserModel userProfile}) {
    return AuthState(step: AuthStep.authenticated, userProfile: userProfile);
  }

  /// Loading state
  AuthState copyWithLoading() {
    return AuthState(
      step: step,
      isLoading: true,
      error: null,
      verificationId: verificationId,
      phoneNumber: phoneNumber,
      userProfile: userProfile,
      resetToken: resetToken,
    );
  }

  /// Copy with modifications
  AuthState copyWith({
    AuthStep? step,
    bool? isLoading,
    String? error,
    String? verificationId,
    String? phoneNumber,
    UserModel? userProfile,
    String? resetToken,
    bool clearError = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userProfile: userProfile ?? this.userProfile,
      resetToken: resetToken ?? this.resetToken,
    );
  }

  bool get isAuthenticated => step == AuthStep.authenticated;
  bool get needsProfileSetup => step == AuthStep.profileSetup;

  @override
  List<Object?> get props => [
    step,
    isLoading,
    error,
    verificationId,
    phoneNumber,
    userProfile,
    resetToken,
  ];
}
