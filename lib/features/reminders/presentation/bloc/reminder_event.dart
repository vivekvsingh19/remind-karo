part of 'reminder_bloc.dart';

/// Base class for reminder events
abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

/// Load reminders
class RemindersLoadRequested extends ReminderEvent {
  final String userId;

  const RemindersLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Subscribe to reminders stream
class RemindersSubscriptionRequested extends ReminderEvent {
  final String userId;

  const RemindersSubscriptionRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Reminders updated from stream
class RemindersUpdated extends ReminderEvent {
  final List<ReminderModel> reminders;

  const RemindersUpdated({required this.reminders});

  @override
  List<Object?> get props => [reminders];
}

/// Load reminder stats
class ReminderStatsLoadRequested extends ReminderEvent {
  final String userId;

  const ReminderStatsLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Create reminder
class ReminderCreateRequested extends ReminderEvent {
  final String userId;
  final ReminderCategory category;
  final String customerName;
  final String customerPhone;
  final String description;
  final String message;
  final DateTime scheduledTime;
  final String? notes;
  final bool hasAlarm;
  final DateTime? alarmTime;

  const ReminderCreateRequested({
    required this.userId,
    required this.category,
    required this.customerName,
    required this.customerPhone,
    required this.description,
    required this.message,
    required this.scheduledTime,
    this.notes,
    this.hasAlarm = false,
    this.alarmTime,
  });

  @override
  List<Object?> get props => [
    userId,
    category,
    customerName,
    customerPhone,
    description,
    message,
    scheduledTime,
    notes,
    hasAlarm,
    alarmTime,
  ];
}

/// Send reminder via WhatsApp
class ReminderSendRequested extends ReminderEvent {
  final ReminderModel reminder;

  const ReminderSendRequested({required this.reminder});

  @override
  List<Object?> get props => [reminder];
}

/// Mark reminder as completed
class ReminderCompleteRequested extends ReminderEvent {
  final String reminderId;

  const ReminderCompleteRequested({required this.reminderId});

  @override
  List<Object?> get props => [reminderId];
}

/// Delete reminder
class ReminderDeleteRequested extends ReminderEvent {
  final String reminderId;

  const ReminderDeleteRequested({required this.reminderId});

  @override
  List<Object?> get props => [reminderId];
}

/// Update filter
class ReminderFilterUpdated extends ReminderEvent {
  final ReminderCategory? category;
  final ReminderStatus? status;
  final String? searchQuery;

  const ReminderFilterUpdated({this.category, this.status, this.searchQuery});

  @override
  List<Object?> get props => [category, status, searchQuery];
}

/// Clear filters
class ReminderFilterCleared extends ReminderEvent {
  const ReminderFilterCleared();
}
