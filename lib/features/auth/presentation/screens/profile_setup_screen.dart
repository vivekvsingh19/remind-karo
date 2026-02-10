import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

/// Profile setup screen for new users
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill email from auth state
    final authState = context.read<AuthBloc>().state;
    if (authState.firebaseUser?.email != null) {
      // Email is already available from Firebase user
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
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
        appBar: AppBar(
          title: const Text('Complete Profile'),
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildProfileForm(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Let\'s Set Up Your Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Just a few details to personalize your experience',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        CustomTextField(
          controller: _nameController,
          labelText: 'Your Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),

        // Phone field (optional for WhatsApp reminders)
        PhoneTextField(
          controller: _phoneController,
          validator: (value) {
            // Optional - only validate if provided
            if (value != null && value.isNotEmpty && value.length != 10) {
              return 'Enter valid 10-digit number';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Optional - Your WhatsApp number for sending reminders',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryLight),
        ),
        const SizedBox(height: 20),

        // Business name field (optional)
        CustomTextField(
          controller: _businessController,
          labelText: 'Business Name (Optional)',
          hintText: 'Your business or company name',
          prefixIcon: Icons.business_outlined,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return PrimaryButton(
          text: 'Continue',
          isLoading: state.isLoading,
          onPressed: _submitProfile,
        );
      },
    );
  }

  void _submitProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    final email = authState.firebaseUser?.email;

    context.read<AuthBloc>().add(
      AuthCreateProfileRequested(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : '0000000000', // Default if not provided
        email: email,
      ),
    );
  }
}
