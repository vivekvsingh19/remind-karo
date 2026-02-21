import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for handling authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthState.initial()) {
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthVerifyEmailOtpRequested>(_onVerifyEmailOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGuestLoginRequested>(_onGuestLoginRequested);
  }

  /// Check authentication status
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Check if user has a saved token by fetching profile
      final result = await _authRepository.getProfileFromApi();

      result.fold(
        (failure) {
          emit(AuthState.initial());
        },
        (profileData) {
          final userProfile = UserModel.fromJson(
            profileData['user'] ?? profileData,
          );
          emit(
            AuthState.authenticated(
              userProfile: userProfile,
            ).copyWith(isLoading: false),
          );
        },
      );
    } catch (e) {
      emit(AuthState.initial());
    }
  }

  /// Sign out
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _authRepository.signOut();
    emit(AuthState.initial());
  }

  /// Backend API Signup
  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.signupWithApi(
      name: event.name,
      email: event.email,
      password: event.password,
      mobileNumber: event.mobileNumber,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // Signup successful, show OTP verification screen
        emit(
          state.copyWith(
            isLoading: false,
            step: AuthStep.emailOtpVerification,
            error: null,
          ),
        );
      },
    );
  }

  /// Verify Email OTP
  Future<void> _onVerifyEmailOtpRequested(
    AuthVerifyEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.verifyEmailOtp(
      email: event.email,
      otp: event.otp,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // OTP verified successfully, auto-login
        add(AuthLoginRequested(email: event.email, password: event.password));
      },
    );
  }

  /// Resend OTP
  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.resendOtp(email: event.email);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        emit(state.copyWith(isLoading: false, error: null));
      },
    );
  }

  /// Backend API Login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.loginWithApi(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        final userProfile = UserModel(
          id: response['id'] ?? response['userId'] ?? '',
          name: response['name'] ?? '',
          phoneNumber:
              response['mobile_number'] ?? response['phoneNumber'] ?? '',
          email: response['email'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        emit(AuthState.authenticated(userProfile: userProfile));
      },
    );
  }

  /// Guest login
  Future<void> _onGuestLoginRequested(
    AuthGuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(step: AuthStep.guest, isLoading: false, clearError: true));
  }

  /// Delete account
  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.deleteAccountFromApi();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // Account deleted successfully
        print('✅ Account deleted successfully');
        emit(AuthState.initial());
      },
    );
  }
}
