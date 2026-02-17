import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/profile_setup_screen.dart';
import 'features/dashboard/presentation/screens/main_screen.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/reminders/data/repositories/reminder_repository.dart';
import 'features/reminders/presentation/bloc/reminder_bloc.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const RemindKaroApp());
}

/// Main application widget
class RemindKaroApp extends StatelessWidget {
  const RemindKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<ReminderRepository>(
          create: (_) => ReminderRepository(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(const AuthCheckRequested()),
          ),
          BlocProvider<ReminderBloc>(
            create: (context) => ReminderBloc(
              reminderRepository: context.read<ReminderRepository>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationRepository: context.read<NotificationRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'RemindKaro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: SplashScreenWrapper(child: const AuthWrapper()),
        ),
      ),
    );
  }
}

/// Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Subscribe to reminders and notifications when authenticated
        // Only if using Firebase auth (firebaseUser is not null)
        if (state.isAuthenticated && state.firebaseUser != null) {
          final userId = state.firebaseUser!.uid;
          context.read<ReminderBloc>().add(
            RemindersSubscriptionRequested(userId: userId),
          );
          context.read<ReminderBloc>().add(
            ReminderStatsLoadRequested(userId: userId),
          );
          context.read<NotificationBloc>().add(
            NotificationsSubscriptionRequested(userId: userId),
          );
        }
        // For backend API auth (without Firebase), we'll add subscriptions later when needed
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null && !state.isAuthenticated) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthCheckRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        switch (state.step) {
          case AuthStep.authenticated:
          case AuthStep.guest:
            return const MainScreen();
          case AuthStep.profileSetup:
            return const ProfileSetupScreen();
          case AuthStep.phone:
          case AuthStep.otp:
          case AuthStep.emailOtpVerification:
            return const LoginScreen();
        }
      },
    );
  }
}
