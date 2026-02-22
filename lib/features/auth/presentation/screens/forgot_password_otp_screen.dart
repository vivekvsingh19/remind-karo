import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../presentation/widgets/curved_container.dart';
import '../bloc/auth_bloc.dart';
import 'reset_password_screen.dart';

/// Forgot Password OTP Verification Screen
class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  late final FocusNode focusNode;
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleLarge,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.primaryColor, width: 2),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    );

    const errorPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.errorColor,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Show error if OTP verification fails
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }

          // If resetToken is received, move to ResetPasswordScreen
          if (state.resetToken != null && !state.isLoading) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  email: widget.email,
                  resetToken: state.resetToken!,
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              CurvedContainerRounded(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 50,
                  left: 24,
                  right: 24,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      _buildHeader(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildOtpForm(
                      context,
                      defaultPinTheme,
                      focusedPinTheme,
                      errorPinTheme,
                    ),
                  ],
                ),
              ),
            ],
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
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.password_check,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Reset Code',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to ${widget.email}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpForm(
    BuildContext context,
    PinTheme defaultPinTheme,
    PinTheme focusedPinTheme,
    PinTheme errorPinTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verification',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 08),
        Text(
          'Please enter the code to continue',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // OTP Input
        Pinput(
          length: 6,
          focusNode: focusNode,
          controller: otpController,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          errorPinTheme: errorPinTheme,
          showCursor: true,
          onCompleted: (pin) {
            _verifyOtp(context);
          },
        ),
        const SizedBox(height: 32),

        // Verify Button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PrimaryButton(
              text: 'Verify Code',
              isLoading: state.isLoading,
              onPressed: () => _verifyOtp(context),
            );
          },
        ),
        const SizedBox(height: 16),

        // Resend OTP
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Didn\'t receive code? ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'Resend',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: state.isLoading
                          ? null
                          : (TapGestureRecognizer()
                              ..onTap = () => _resendOtp(context)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _verifyOtp(BuildContext context) {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid 6-digit code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthVerifyForgotOtpRequested(email: widget.email, otp: otp),
    );
  }

  void _resendOtp(BuildContext context) {
    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(email: widget.email),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset code resent to your email'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
