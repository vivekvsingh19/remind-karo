import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for date and time operations
class AppDateUtils {
  AppDateUtils._();

  /// Format date to display format
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format time to display format
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }

  /// Format date and time together
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Get relative time string (e.g., "2 hours ago", "Tomorrow")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past dates
      final absDiff = difference.abs();
      if (absDiff.inMinutes < 1) {
        return 'Just now';
      } else if (absDiff.inMinutes < 60) {
        return '${absDiff.inMinutes} min ago';
      } else if (absDiff.inHours < 24) {
        return '${absDiff.inHours} hr ago';
      } else if (absDiff.inDays < 7) {
        return '${absDiff.inDays} days ago';
      } else {
        return formatDate(dateTime);
      }
    } else {
      // Future dates
      if (difference.inMinutes < 60) {
        return 'In ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'In ${difference.inHours} hr';
      } else if (difference.inDays == 0) {
        return 'Today, ${formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow, ${formatTime(dateTime)}';
      } else if (difference.inDays < 7) {
        return 'In ${difference.inDays} days';
      } else {
        return formatDate(dateTime);
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Combine date and time
  static DateTime combineDateTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Get current month and year formatted
  static String getCurrentMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  /// Format relative date (alias for getRelativeTime for convenience)
  static String formatRelativeDate(DateTime dateTime) {
    return getRelativeTime(dateTime);
  }
}
