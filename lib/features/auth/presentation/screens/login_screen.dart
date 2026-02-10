import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

/// Login screen with email/password authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // Toggle between login and register
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthGuestLoginRequested(),
                        );
                      },
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildEmailForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.notification5,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to RemindKaro',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'WhatsApp Reminder Automation',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondaryLight),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isLogin ? 'Sign In' : 'Create Account',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Enter your credentials to continue'
              : 'Fill in the details to get started',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Email field
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 20),

        // Password field
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: _isLogin
              ? 'Enter your password'
              : 'Create a password (min 6 chars)',
          prefixIcon: Iconsax.lock,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
              color: AppTheme.textSecondaryLight,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),

        // Submit button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PrimaryButton(
              text: _isLogin ? 'Sign In' : 'Create Account',
              isLoading: state.isLoading,
              onPressed: _submit,
            );
          },
        ),
        const SizedBox(height: 24),

        // Toggle login/register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin
                  ? "Don't have an account? "
                  : "Already have an account? ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(
                _isLogin ? 'Sign Up' : 'Sign In',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailRequested(email: email, password: password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthRegisterWithEmailRequested(email: email, password: password),
      );
    }
  }
}
