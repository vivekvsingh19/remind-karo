part of 'auth_bloc.dart';

/// Authentication steps
enum AuthStep { phone, otp, profileSetup, authenticated, guest }

/// Auth state
class AuthState extends Equatable {
  final AuthStep step;
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final String? phoneNumber;
  final User? firebaseUser;
  final UserModel? userProfile;

  const AuthState({
    this.step = AuthStep.phone,
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.phoneNumber,
    this.firebaseUser,
    this.userProfile,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Authenticated state
  factory AuthState.authenticated({
    required User firebaseUser,
    required UserModel userProfile,
  }) {
    return AuthState(
      step: AuthStep.authenticated,
      firebaseUser: firebaseUser,
      userProfile: userProfile,
    );
  }

  /// Loading state
  AuthState copyWithLoading() {
    return AuthState(
      step: step,
      isLoading: true,
      error: null,
      verificationId: verificationId,
      phoneNumber: phoneNumber,
      firebaseUser: firebaseUser,
      userProfile: userProfile,
    );
  }

  /// Copy with modifications
  AuthState copyWith({
    AuthStep? step,
    bool? isLoading,
    String? error,
    String? verificationId,
    String? phoneNumber,
    User? firebaseUser,
    UserModel? userProfile,
    bool clearError = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userProfile: userProfile ?? this.userProfile,
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
    firebaseUser?.uid,
    userProfile,
  ];
}
