import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/notification_model.dart';

/// Repository for notification operations
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection(AppConstants.notificationsCollection);

  /// Get notifications stream for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create a notification
  Future<Either<Failure, NotificationModel>> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      final docRef = _notificationsRef.doc();
      final notification = NotificationModel(
        id: docRef.id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        relatedId: relatedId,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await docRef.set(notification.toFirestore());
      return Right(notification);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Clear all notifications for a user
  Future<Either<Failure, void>> clearAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return Right(querySnapshot.count ?? 0);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
