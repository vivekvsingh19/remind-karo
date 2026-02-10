/// App-wide constants for RemindKaro
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RemindKaro';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String remindersCollection = 'reminders';
  static const String notificationsCollection = 'notifications';

  // Reminder Categories
  static const String categoryPayment = 'payment';
  static const String categoryProduct = 'product';
  static const String categoryMeeting = 'meeting';

  // Reminder Status
  static const String statusPending = 'pending';
  static const String statusSent = 'sent';
  static const String statusCompleted = 'completed';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Notification Channels
  static const String reminderChannelId = 'reminder_channel';
  static const String reminderChannelName = 'Reminder Notifications';
  static const String alarmChannelId = 'alarm_channel';
  static const String alarmChannelName = 'Alarm Notifications';

  // WhatsApp
  static const String whatsappBaseUrl = 'https://wa.me/';

  // Validation
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;
}

/// Reminder category enum for type safety
enum ReminderCategory {
  payment('payment', 'Payment', '💰', 0xFF8B5CF6),
  product('product', 'Product', '📦', 0xFFF59E0B),
  meeting('meeting', 'Meeting', '🤝', 0xFF06B6D4);

  const ReminderCategory(this.value, this.label, this.emoji, this.color);

  final String value;
  final String label;
  final String emoji;
  final int color;

  static ReminderCategory fromString(String value) {
    return ReminderCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderCategory.payment,
    );
  }
}

/// Reminder status enum for type safety
enum ReminderStatus {
  pending('pending', 'Pending', 0xFFFFA726),
  sent('sent', 'Sent', 0xFF42A5F5),
  completed('completed', 'Completed', 0xFF66BB6A);

  const ReminderStatus(this.value, this.label, this.colorValue);

  final String value;
  final String label;
  final int colorValue;

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderStatus.pending,
    );
  }
}
