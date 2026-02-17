import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../models/reminder_model.dart';

/// Repository for reminder operations
class ReminderRepository {
  final NotificationService _notificationService;
  final WhatsAppService _whatsAppService;
  final Uuid _uuid;

  ReminderRepository({
    NotificationService? notificationService,
    WhatsAppService? whatsAppService,
    Uuid? uuid,
  }) : _notificationService = notificationService ?? NotificationService(),
       _whatsAppService = whatsAppService ?? WhatsAppService(),
       _uuid = uuid ?? const Uuid();

  /// Create a new reminder via API
  Future<Either<Failure, ReminderModel>> createReminder({
    required String userId,
    required ReminderCategory category,
    required String customerName,
    required String customerPhone,
    String? notes,
    required String description,
    String? customMessage,
    required DateTime scheduledTime,
    bool hasAlarm = false,
    DateTime? alarmTime,
  }) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();

      // Generate message if not provided
      final message =
          customMessage ??
          _whatsAppService.generateReminderMessage(
            category: category.value,
            customerName: customerName,
            description: description,
          );

      final reminder = ReminderModel(
        id: id,
        userId: userId,
        category: category,
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        description: description,
        message: message,
        scheduledTime: scheduledTime,
        status: ReminderStatus.pending,
        hasAlarm: hasAlarm,
        alarmTime: alarmTime,
        createdAt: now,
        updatedAt: now,
      );

      // TODO: Call backend API to create reminder
      // await _apiService.createReminder(reminder.toJson());

      // Schedule alarm notification if enabled
      if (hasAlarm && alarmTime != null) {
        await _scheduleAlarmNotification(reminder);
      }

      return Right(reminder);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Update an existing reminder via API
  Future<Either<Failure, ReminderModel>> updateReminder(
    ReminderModel reminder,
  ) async {
    try {
      final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());

      // TODO: Call backend API to update reminder
      // await _apiService.updateReminder(updatedReminder.toJson());

      // Update alarm notification if needed
      if (updatedReminder.hasAlarm && updatedReminder.alarmTime != null) {
        await _notificationService.cancelNotification(reminder.id.hashCode);
        await _scheduleAlarmNotification(updatedReminder);
      } else {
        await _notificationService.cancelNotification(reminder.id.hashCode);
      }

      return Right(updatedReminder);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete a reminder via API
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    try {
      // TODO: Call backend API to delete reminder
      // await _apiService.deleteReminder(reminderId);

      await _notificationService.cancelNotification(reminderId.hashCode);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get a single reminder by ID from API
  Future<Either<Failure, ReminderModel?>> getReminder(String reminderId) async {
    try {
      // TODO: Call backend API to get reminder
      // final response = await _apiService.getReminder(reminderId);
      // return Right(ReminderModel.fromJson(response));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get all reminders for a user from API
  Stream<List<ReminderModel>> getRemindersStream(String userId) {
    // TODO: Implement streaming from API or use local cache
    // For now, return empty stream
    return Stream.value([]);
  }

  /// Get reminders filtered by category from API
  Stream<List<ReminderModel>> getRemindersByCategoryStream(
    String userId,
    ReminderCategory category,
  ) {
    // TODO: Implement streaming from API or use local cache
    // For now, return empty stream
    return Stream.value([]);
  }

  /// Get reminders filtered by status from API
  Stream<List<ReminderModel>> getRemindersByStatusStream(
    String userId,
    ReminderStatus status,
  ) {
    // TODO: Implement streaming from API or use local cache
    // For now, return empty stream
    return Stream.value([]);
  }

  /// Get reminder stats for dashboard from API
  Future<Either<Failure, ReminderStats>> getReminderStats(String userId) async {
    try {
      // TODO: Call backend API to get stats
      // final response = await _apiService.getReminderStats(userId);
      // final reminders = (response as List)
      //     .map((r) => ReminderModel.fromJson(r))
      //     .toList();

      return const Right(
        ReminderStats.empty,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark reminder as sent via API
  Future<Either<Failure, ReminderModel>> markAsSent(String reminderId) async {
    try {
      // TODO: Call backend API to mark as sent
      // await _apiService.markReminderAsSent(reminderId);

      return Left(ServerFailure(message: 'Not implemented'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark reminder as completed via API
  Future<Either<Failure, ReminderModel>> markAsCompleted(
    String reminderId,
  ) async {
    try {
      // TODO: Call backend API to mark as completed
      // await _apiService.markReminderAsCompleted(reminderId);

      return Left(ServerFailure(message: 'Not implemented'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Send WhatsApp reminder
  Future<Either<Failure, void>> sendWhatsAppReminder(
    ReminderModel reminder,
  ) async {
    try {
      final result = await _whatsAppService.sendReminder(
        phoneNumber: reminder.customerPhone,
        customerName: reminder.customerName,
        message: reminder.message,
      );

      if (result.success) {
        await markAsSent(reminder.id);

        // Show notification that message was sent
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: '✅ Reminder Sent',
          body: 'WhatsApp reminder sent to ${reminder.customerName}',
          payload: reminder.id,
        );

        return const Right(null);
      } else {
        return Left(
          ServerFailure(message: result.error ?? 'Failed to send reminder'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Open WhatsApp with pre-filled message
  Future<Either<Failure, void>> openWhatsApp(ReminderModel reminder) async {
    try {
      final success = await _whatsAppService.sendMessage(
        phoneNumber: reminder.customerPhone,
        message: reminder.message,
      );

      if (success) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(message: 'Could not open WhatsApp'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Schedule alarm notification
  Future<void> _scheduleAlarmNotification(ReminderModel reminder) async {
    if (reminder.alarmTime != null &&
        reminder.alarmTime!.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: '⏰ Reminder Alert: ${reminder.category.label}',
        body: '${reminder.customerName}: ${reminder.description}',
        scheduledTime: reminder.alarmTime!,
        payload: reminder.id,
        isAlarm: true,
      );
    }
  }
}

/// Stats model for dashboard
class ReminderStats {
  final int total;
  final int pending;
  final int sent;
  final int completed;
  final int overdue;

  const ReminderStats({
    required this.total,
    required this.pending,
    required this.sent,
    required this.completed,
    this.overdue = 0,
  });

  static const empty = ReminderStats(
    total: 0,
    pending: 0,
    sent: 0,
    completed: 0,
    overdue: 0,
  );
}
