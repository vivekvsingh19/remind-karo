part of 'notification_bloc.dart';

/// Notification state
class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  /// Initial state
  factory NotificationState.initial() => const NotificationState();

  /// Get unread count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Copy with modifications
  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, error, successMessage];
}
