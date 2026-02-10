part of 'reminder_form_cubit.dart';

/// State for reminder form
class ReminderFormState extends Equatable {
  final int currentStep;
  final bool isLoading;
  final String? error;

  // Step 1: Category
  final ReminderCategory? category;

  // Step 2: Customer details
  final String customerName;
  final String customerPhone;
  final String notes;

  // Step 3: Reminder details
  final String description;
  final String message;

  // Step 4: Schedule
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;

  // Step 5: Alarm
  final bool hasAlarm;
  final DateTime? alarmDate;
  final DateTime? alarmTime;

  const ReminderFormState({
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.category,
    this.customerName = '',
    this.customerPhone = '',
    this.notes = '',
    this.description = '',
    this.message = '',
    this.scheduledDate,
    this.scheduledTime,
    this.hasAlarm = false,
    this.alarmDate,
    this.alarmTime,
  });

  ReminderFormState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    ReminderCategory? category,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? description,
    String? message,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    bool? hasAlarm,
    DateTime? alarmDate,
    DateTime? alarmTime,
  }) {
    return ReminderFormState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      category: category ?? this.category,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      message: message ?? this.message,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      alarmDate: alarmDate ?? this.alarmDate,
      alarmTime: alarmTime ?? this.alarmTime,
    );
  }

  bool get canProceedStep1 => category != null;

  bool get canProceedStep2 =>
      customerName.isNotEmpty && customerPhone.length == 10;

  bool get canProceedStep3 => description.isNotEmpty && message.isNotEmpty;

  bool get canProceedStep4 => scheduledDate != null && scheduledTime != null;

  bool get canSubmit =>
      canProceedStep1 && canProceedStep2 && canProceedStep3 && canProceedStep4;

  DateTime? get combinedScheduledTime {
    if (scheduledDate == null || scheduledTime == null) return null;
    return DateTime(
      scheduledDate!.year,
      scheduledDate!.month,
      scheduledDate!.day,
      scheduledTime!.hour,
      scheduledTime!.minute,
    );
  }

  DateTime? get combinedAlarmTime {
    if (!hasAlarm || alarmDate == null || alarmTime == null) return null;
    return DateTime(
      alarmDate!.year,
      alarmDate!.month,
      alarmDate!.day,
      alarmTime!.hour,
      alarmTime!.minute,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    error,
    category,
    customerName,
    customerPhone,
    notes,
    description,
    message,
    scheduledDate,
    scheduledTime,
    hasAlarm,
    alarmDate,
    alarmTime,
  ];
}
