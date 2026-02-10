part of 'notification_bloc.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to notifications
class NotificationsSubscriptionRequested extends NotificationEvent {
  final String userId;

  const NotificationsSubscriptionRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Notifications updated from stream
class NotificationsUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;

  const NotificationsUpdated({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

/// Mark notification as read
class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class NotificationMarkAllAsReadRequested extends NotificationEvent {
  final String userId;

  const NotificationMarkAllAsReadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Delete notification
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Clear all notifications
class NotificationClearAllRequested extends NotificationEvent {
  final String userId;

  const NotificationClearAllRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
