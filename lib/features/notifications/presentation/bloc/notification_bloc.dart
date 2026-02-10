import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// BLoC for handling notifications
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  NotificationBloc({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(NotificationState.initial()) {
    on<NotificationsSubscriptionRequested>(_onSubscriptionRequested);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
    on<NotificationDeleteRequested>(_onDeleteRequested);
    on<NotificationClearAllRequested>(_onClearAllRequested);
  }

  /// Subscribe to notifications stream
  Future<void> _onSubscriptionRequested(
    NotificationsSubscriptionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _notificationsSubscription?.cancel();

    _notificationsSubscription = _notificationRepository
        .getNotificationsStream(event.userId)
        .listen(
          (notifications) =>
              add(NotificationsUpdated(notifications: notifications)),
        );
  }

  /// Handle notifications update from stream
  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(notifications: event.notifications, isLoading: false));
  }

  /// Mark as read
  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.markAsRead(
      event.notificationId,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {},
    );
  }

  /// Mark all as read
  Future<void> _onMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.markAllAsRead(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(successMessage: 'All marked as read')),
    );
  }

  /// Delete notification
  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.deleteNotification(
      event.notificationId,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {},
    );
  }

  /// Clear all notifications
  Future<void> _onClearAllRequested(
    NotificationClearAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.clearAllNotifications(
      event.userId,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(successMessage: 'All notifications cleared')),
    );
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
