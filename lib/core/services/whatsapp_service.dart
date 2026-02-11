import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Service for WhatsApp integration
/// TODO: Replace mock implementation with actual WhatsApp Business API
class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  /// Send a WhatsApp message
  /// Currently opens WhatsApp with pre-filled message
  /// TODO: Integrate WhatsApp Business API for automated sending
  Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Format phone number (add country code if not present)
      final formattedNumber = _formatPhoneNumber(phoneNumber);

      // Encode message for URL
      final encodedMessage = Uri.encodeComponent(message);

      // Create WhatsApp URL
      final whatsappUrl = Uri.parse(
        '${AppConstants.whatsappBaseUrl}$formattedNumber?text=$encodedMessage',
      );

      // Check if WhatsApp is installed and can open
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        debugPrint('WhatsApp is not installed');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending WhatsApp message: $e');
      return false;
    }
  }

  /// Mock sending a reminder via WhatsApp
  /// TODO: Replace with actual API call when WhatsApp Business API is integrated
  Future<SendResult> sendReminder({
    required String phoneNumber,
    required String customerName,
    required String message,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock success (100% success rate for demo)
      debugPrint(
        '✅ Mock WhatsApp message sent to $customerName ($phoneNumber)',
      );
      return SendResult(
        success: true,
        messageId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SendResult(success: false, error: e.toString());
    }
  }

  /// Format phone number with country code
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If number doesn't start with +, assume it's Indian number
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('91')) {
        cleaned = '+$cleaned';
      } else if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      }
    }

    return cleaned;
  }

  /// Generate reminder message from template
  String generateReminderMessage({
    required String category,
    required String customerName,
    required String description,
    String? customMessage,
  }) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    switch (category) {
      case AppConstants.categoryPayment:
        return 'Hi $customerName! 👋\n\n'
            'This is a friendly reminder regarding your payment: $description.\n\n'
            'Please let us know if you have any questions.\n\n'
            'Thank you! 🙏';

      case AppConstants.categoryProduct:
        return 'Hi $customerName! 👋\n\n'
            'This is a reminder about: $description.\n\n'
            'Please feel free to reach out if you need any assistance.\n\n'
            'Thank you! 🙏';

      case AppConstants.categoryMeeting:
        return 'Hi $customerName! 👋\n\n'
            'Just a reminder about our upcoming meeting: $description.\n\n'
            'Looking forward to connecting with you!\n\n'
            'Best regards 🙏';

      default:
        return 'Hi $customerName! 👋\n\n'
            'This is a reminder: $description.\n\n'
            'Thank you! 🙏';
    }
  }
}

/// Result of sending a WhatsApp message
class SendResult {
  final bool success;
  final String? messageId;
  final DateTime? timestamp;
  final String? error;

  SendResult({
    required this.success,
    this.messageId,
    this.timestamp,
    this.error,
  });
}
