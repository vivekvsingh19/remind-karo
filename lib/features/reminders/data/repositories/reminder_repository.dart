import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../models/reminder_model.dart';

/// Repository for reminder operations
class ReminderRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;
  final WhatsAppService _whatsAppService;
  final Uuid _uuid;

  ReminderRepository({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
    WhatsAppService? whatsAppService,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _notificationService = notificationService ?? NotificationService(),
       _whatsAppService = whatsAppService ?? WhatsAppService(),
       _uuid = uuid ?? const Uuid();

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _remindersRef =>
      _firestore.collection(AppConstants.remindersCollection);

  /// Create a new reminder
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

      await _remindersRef.doc(id).set(reminder.toFirestore());

      // Schedule alarm notification if enabled
      if (hasAlarm && alarmTime != null) {
        await _scheduleAlarmNotification(reminder);
      }

      return Right(reminder);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Update an existing reminder
  Future<Either<Failure, ReminderModel>> updateReminder(
    ReminderModel reminder,
  ) async {
    try {
      final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());

      await _remindersRef
          .doc(reminder.id)
          .update(updatedReminder.toFirestore());

      // Update alarm notification if needed
      if (updatedReminder.hasAlarm && updatedReminder.alarmTime != null) {
        await _notificationService.cancelNotification(reminder.id.hashCode);
        await _scheduleAlarmNotification(updatedReminder);
      } else {
        await _notificationService.cancelNotification(reminder.id.hashCode);
      }

      return Right(updatedReminder);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete a reminder
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    try {
      await _remindersRef.doc(reminderId).delete();
      await _notificationService.cancelNotification(reminderId.hashCode);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get a single reminder by ID
  Future<Either<Failure, ReminderModel?>> getReminder(String reminderId) async {
    try {
      final docSnapshot = await _remindersRef.doc(reminderId).get();

      if (!docSnapshot.exists) {
        return const Right(null);
      }

      return Right(ReminderModel.fromFirestore(docSnapshot));
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get all reminders for a user
  Stream<List<ReminderModel>> getRemindersStream(String userId) {
    return _remindersRef
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get reminders filtered by category
  Stream<List<ReminderModel>> getRemindersByCategoryStream(
    String userId,
    ReminderCategory category,
  ) {
    return _remindersRef
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category.value)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get reminders filtered by status
  Stream<List<ReminderModel>> getRemindersByStatusStream(
    String userId,
    ReminderStatus status,
  ) {
    return _remindersRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.value)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get reminder stats for dashboard
  Future<Either<Failure, ReminderStats>> getReminderStats(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _remindersRef
          .where('userId', isEqualTo: userId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .get();

      final reminders = querySnapshot.docs
          .map((doc) => ReminderModel.fromFirestore(doc))
          .toList();

      final pending = reminders
          .where((r) => r.status == ReminderStatus.pending)
          .length;
      final sent = reminders
          .where((r) => r.status == ReminderStatus.sent)
          .length;
      final completed = reminders
          .where((r) => r.status == ReminderStatus.completed)
          .length;

      return Right(
        ReminderStats(
          total: reminders.length,
          pending: pending,
          sent: sent,
          completed: completed,
        ),
      );
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark reminder as sent (after WhatsApp message is sent)
  Future<Either<Failure, ReminderModel>> markAsSent(String reminderId) async {
    try {
      final docSnapshot = await _remindersRef.doc(reminderId).get();

      if (!docSnapshot.exists) {
        return const Left(FirestoreFailure(message: 'Reminder not found'));
      }

      final reminder = ReminderModel.fromFirestore(docSnapshot);
      final updatedReminder = reminder.copyWith(
        status: ReminderStatus.sent,
        updatedAt: DateTime.now(),
      );

      await _remindersRef.doc(reminderId).update(updatedReminder.toFirestore());

      return Right(updatedReminder);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark reminder as completed
  Future<Either<Failure, ReminderModel>> markAsCompleted(
    String reminderId,
  ) async {
    try {
      final docSnapshot = await _remindersRef.doc(reminderId).get();

      if (!docSnapshot.exists) {
        return const Left(FirestoreFailure(message: 'Reminder not found'));
      }

      final reminder = ReminderModel.fromFirestore(docSnapshot);
      final updatedReminder = reminder.copyWith(
        status: ReminderStatus.completed,
        updatedAt: DateTime.now(),
      );

      await _remindersRef.doc(reminderId).update(updatedReminder.toFirestore());

      return Right(updatedReminder);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Send WhatsApp reminder (mock implementation)
  /// TODO: Replace with actual WhatsApp Business API integration
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

  const ReminderStats({
    required this.total,
    required this.pending,
    required this.sent,
    required this.completed,
  });

  static const empty = ReminderStats(
    total: 0,
    pending: 0,
    sent: 0,
    completed: 0,
  );
}
