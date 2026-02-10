import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/reminder_repository.dart';

part 'reminder_form_state.dart';

/// Cubit for managing reminder form state
class ReminderFormCubit extends Cubit<ReminderFormState> {
  final ReminderRepository _repository;
  final String userId;

  ReminderFormCubit({
    required ReminderRepository repository,
    required this.userId,
  }) : _repository = repository,
       super(const ReminderFormState());

  /// Set category
  void setCategory(ReminderCategory category) {
    emit(state.copyWith(category: category));
  }

  /// Update customer details
  void updateCustomerDetails({String? name, String? phone, String? notes}) {
    emit(
      state.copyWith(
        customerName: name ?? state.customerName,
        customerPhone: phone ?? state.customerPhone,
        notes: notes ?? state.notes,
      ),
    );
  }

  /// Update reminder details
  void updateReminderDetails({String? description, String? message}) {
    emit(
      state.copyWith(
        description: description ?? state.description,
        message: message ?? state.message,
      ),
    );
  }

  /// Update schedule
  void updateSchedule({DateTime? date, DateTime? time}) {
    emit(
      state.copyWith(
        scheduledDate: date ?? state.scheduledDate,
        scheduledTime: time ?? state.scheduledTime,
      ),
    );
  }

  /// Update alarm
  void updateAlarm({bool? hasAlarm, DateTime? date, DateTime? time}) {
    emit(
      state.copyWith(
        hasAlarm: hasAlarm ?? state.hasAlarm,
        alarmDate: date ?? state.alarmDate,
        alarmTime: time ?? state.alarmTime,
      ),
    );
  }

  /// Go to next step
  void nextStep() {
    if (state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      emit(state.copyWith(currentStep: step));
    }
  }

  /// Submit form
  Future<bool> submit() async {
    if (!state.canSubmit) return false;

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.createReminder(
      userId: userId,
      category: state.category!,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      description: state.description,
      customMessage: state.message,
      scheduledTime: state.combinedScheduledTime!,
      notes: state.notes.isNotEmpty ? state.notes : null,
      hasAlarm: state.hasAlarm,
      alarmTime: state.combinedAlarmTime,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
        return false;
      },
      (reminder) {
        emit(state.copyWith(isLoading: false));
        return true;
      },
    );
  }

  /// Reset form
  void reset() {
    emit(const ReminderFormState());
  }
}
