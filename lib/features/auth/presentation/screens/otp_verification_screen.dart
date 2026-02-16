import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../presentation/widgets/curved_container.dart';
import '../bloc/auth_bloc.dart';

/// OTP Verification Screen
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String mobileNumber;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.mobileNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final FocusNode focusNode;
  final otpController = TextEditingController();
  bool _isSubmitting = false; // Flag to prevent double submission

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
          // Reset submission flag when request completes
          if (!state.isLoading && _isSubmitting) {
            setState(() => _isSubmitting = false);
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
          child: const Icon(Iconsax.verify, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to your email',
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
          'OTP Verification',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 08),
        Text(
          'Check your email for the verification code',
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
            // Auto-submit when all digits entered
            _verifyOtp(context);
          },
        ),
        const SizedBox(height: 32),

        // Verify Button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PrimaryButton(
              text: 'Verify OTP',
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
                      text: 'Resend OTP',
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
          content: Text('Please enter valid 6-digit OTP'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Prevent double submission
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Trigger OTP verification event
    context.read<AuthBloc>().add(
      AuthVerifyEmailOtpRequested(
        email: widget.email,
        otp: otp,
        name: widget.name,
        password: widget.password,
        mobileNumber: widget.mobileNumber,
      ),
    );
  }

  void _resendOtp(BuildContext context) {
    // Trigger resend OTP event
    context.read<AuthBloc>().add(AuthResendOtpRequested(email: widget.email));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent to your email'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
