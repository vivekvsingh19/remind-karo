import '../constants/app_constants.dart';

/// Utility class for input validation
class Validators {
  Validators._();

  /// Validates a phone number (10 digits for Indian numbers)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-()]'), '');

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Phone number can only contain digits';
    }

    if (cleanNumber.length != AppConstants.phoneNumberLength) {
      return 'Phone number must be ${AppConstants.phoneNumberLength} digits';
    }

    return null;
  }

  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates OTP
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP can only contain digits';
    }

    return null;
  }

  /// Validates a name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  /// Validates a required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates WhatsApp message
  static String? validateWhatsAppMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message is required';
    }

    if (value.length > 1000) {
      return 'Message must be less than 1000 characters';
    }

    return null;
  }
}
