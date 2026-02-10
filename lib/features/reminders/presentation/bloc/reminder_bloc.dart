import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

/// BLoC for handling reminders
class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _reminderRepository;
  StreamSubscription<List<ReminderModel>>? _remindersSubscription;

  ReminderBloc({required ReminderRepository reminderRepository})
    : _reminderRepository = reminderRepository,
      super(ReminderState.initial()) {
    on<RemindersSubscriptionRequested>(_onSubscriptionRequested);
    on<RemindersUpdated>(_onRemindersUpdated);
    on<ReminderStatsLoadRequested>(_onStatsLoadRequested);
    on<ReminderCreateRequested>(_onCreateRequested);
    on<ReminderSendRequested>(_onSendRequested);
    on<ReminderCompleteRequested>(_onCompleteRequested);
    on<ReminderDeleteRequested>(_onDeleteRequested);
    on<ReminderFilterUpdated>(_onFilterUpdated);
    on<ReminderFilterCleared>(_onFilterCleared);
  }

  /// Subscribe to reminders stream
  Future<void> _onSubscriptionRequested(
    RemindersSubscriptionRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _remindersSubscription?.cancel();

    _remindersSubscription = _reminderRepository
        .getRemindersStream(event.userId)
        .listen((reminders) => add(RemindersUpdated(reminders: reminders)));
  }

  /// Handle reminders update from stream
  void _onRemindersUpdated(
    RemindersUpdated event,
    Emitter<ReminderState> emit,
  ) {
    emit(state.copyWith(reminders: event.reminders, isLoading: false));
  }

  /// Load reminder stats
  Future<void> _onStatsLoadRequested(
    ReminderStatsLoadRequested event,
    Emitter<ReminderState> emit,
  ) async {
    final result = await _reminderRepository.getReminderStats(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (stats) => emit(state.copyWith(stats: stats)),
    );
  }

  /// Create reminder
  Future<void> _onCreateRequested(
    ReminderCreateRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(
      state.copyWith(isCreating: true, clearError: true, clearSuccess: true),
    );

    final result = await _reminderRepository.createReminder(
      userId: event.userId,
      category: event.category,
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      description: event.description,
      customMessage: event.message,
      scheduledTime: event.scheduledTime,
      notes: event.notes,
      hasAlarm: event.hasAlarm,
      alarmTime: event.alarmTime,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isCreating: false, error: failure.message)),
      (reminder) => emit(
        state.copyWith(
          isCreating: false,
          successMessage: 'Reminder created successfully! 🎉',
        ),
      ),
    );
  }

  /// Send reminder via WhatsApp
  Future<void> _onSendRequested(
    ReminderSendRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(isSending: true, clearError: true, clearSuccess: true));

    final result = await _reminderRepository.sendWhatsAppReminder(
      event.reminder,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isSending: false, error: failure.message)),
      (_) => emit(
        state.copyWith(isSending: false, successMessage: 'Reminder sent! ✅'),
      ),
    );
  }

  /// Mark as completed
  Future<void> _onCompleteRequested(
    ReminderCompleteRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    final result = await _reminderRepository.markAsCompleted(event.reminderId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(successMessage: 'Marked as complete! ✓')),
    );
  }

  /// Delete reminder
  Future<void> _onDeleteRequested(
    ReminderDeleteRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    final result = await _reminderRepository.deleteReminder(event.reminderId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(successMessage: 'Reminder deleted')),
    );
  }

  /// Update filter
  void _onFilterUpdated(
    ReminderFilterUpdated event,
    Emitter<ReminderState> emit,
  ) {
    emit(
      state.copyWith(
        filterCategory: event.category,
        filterStatus: event.status,
        searchQuery: event.searchQuery ?? state.searchQuery,
        clearCategoryFilter:
            event.category == null && state.filterCategory != null,
        clearStatusFilter: event.status == null && state.filterStatus != null,
      ),
    );
  }

  /// Clear all filters
  void _onFilterCleared(
    ReminderFilterCleared event,
    Emitter<ReminderState> emit,
  ) {
    emit(
      state.copyWith(
        clearCategoryFilter: true,
        clearStatusFilter: true,
        searchQuery: '',
      ),
    );
  }

  @override
  Future<void> close() {
    _remindersSubscription?.cancel();
    return super.close();
  }
}
