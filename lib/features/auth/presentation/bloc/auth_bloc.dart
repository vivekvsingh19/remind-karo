import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for handling authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthCreateProfileRequested>(_onCreateProfileRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<AuthRegisterWithEmailRequested>(_onRegisterWithEmailRequested);
    on<AuthGuestLoginRequested>(_onGuestLoginRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthResetRequested>(_onResetRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthVerifyEmailOtpRequested>(_onVerifyEmailOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthCheckRequested());
      }
    });
  }

  /// Check authentication state
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;

    if (user == null) {
      emit(AuthState.initial());
      return;
    }

    emit(state.copyWith(isLoading: true, firebaseUser: user));

    final result = await _authRepository.getUserProfile(user.uid);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            step: AuthStep.profileSetup,
            firebaseUser: user,
          ),
        );
      },
      (profile) {
        if (profile == null || profile.name.isEmpty) {
          emit(
            state.copyWith(
              isLoading: false,
              step: AuthStep.profileSetup,
              firebaseUser: user,
            ),
          );
        } else {
          emit(
            AuthState.authenticated(firebaseUser: user, userProfile: profile),
          );
        }
      },
    );
  }

  /// Send OTP
  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final completer = Completer<void>();

    await _authRepository.sendOtp(
      phoneNumber: event.phoneNumber,
      codeSent: (verificationId, _) {
        emit(
          state.copyWith(
            isLoading: false,
            step: AuthStep.otp,
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ),
        );
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (e) {
        emit(
          state.copyWith(
            isLoading: false,
            error: e.message ?? 'Verification failed',
          ),
        );
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  /// Verify OTP
  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.verificationId == null) {
      emit(state.copyWith(error: 'Verification ID not found'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.verifyOtp(
      verificationId: state.verificationId!,
      otp: event.otp,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (credential) async {
        final user = credential.user;
        if (user != null) {
          // Check if profile exists
          final profileResult = await _authRepository.getUserProfile(user.uid);
          profileResult.fold(
            (_) {
              emit(
                state.copyWith(
                  isLoading: false,
                  step: AuthStep.profileSetup,
                  firebaseUser: user,
                ),
              );
            },
            (profile) {
              if (profile == null || profile.name.isEmpty) {
                emit(
                  state.copyWith(
                    isLoading: false,
                    step: AuthStep.profileSetup,
                    firebaseUser: user,
                  ),
                );
              } else {
                emit(
                  AuthState.authenticated(
                    firebaseUser: user,
                    userProfile: profile,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  /// Create profile
  Future<void> _onCreateProfileRequested(
    AuthCreateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = state.firebaseUser ?? _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(error: 'User not found'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.createUserProfile(
      userId: user.uid,
      name: event.name,
      phoneNumber: event.phoneNumber,
      email: event.email,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (profile) {
        emit(AuthState.authenticated(firebaseUser: user, userProfile: profile));
      },
    );
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

  /// Sign in with Google
  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (credential) async {
        final user = credential.user;
        if (user != null) {
          add(const AuthCheckRequested());
        }
      },
    );
  }

  /// Sign in with email
  Future<void> _onSignInWithEmailRequested(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (credential) async {
        final user = credential.user;
        if (user != null) {
          add(const AuthCheckRequested());
        }
      },
    );
  }

  /// Register with email
  Future<void> _onRegisterWithEmailRequested(
    AuthRegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.registerWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (credential) async {
        final user = credential.user;
        if (user != null) {
          emit(
            state.copyWith(
              isLoading: false,
              step: AuthStep.profileSetup,
              firebaseUser: user,
            ),
          );
        }
      },
    );
  }

  /// Reset to phone input
  Future<void> _onResetRequested(
    AuthResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.initial());
  }

  /// Guest login
  Future<void> _onGuestLoginRequested(
    AuthGuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Reset state and set step to guest
    emit(AuthState(step: AuthStep.guest));
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
    print('🔐 OTP Verification: Starting for email ${event.email}');
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.verifyEmailOtp(
      email: event.email,
      otp: event.otp,
    );

    result.fold(
      (failure) {
        print('❌ OTP Verification failed: ${failure.message}');
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // OTP verified successfully, auto-login
        print('✅ OTP Verification successful, proceeding to login');
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
    print('🔑 Login: Starting for email ${event.email}');
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.loginWithApi(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        print('❌ Login failed: ${failure.message}');
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // Login successful - token is already saved in API service
        print('✅ Login successful, setting authenticated state');
        emit(
          state.copyWith(
            isLoading: false,
            step: AuthStep.authenticated,
            error: null,
          ),
        );
      },
    );
  }

  /// Delete account
  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🗑️  Starting account deletion...');
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.deleteAccountFromApi();

    result.fold(
      (failure) {
        print('❌ Delete account failed: ${failure.message}');
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (response) {
        // Account deleted successfully
        print('✅ Account deleted successfully');
        emit(AuthState.initial());
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
