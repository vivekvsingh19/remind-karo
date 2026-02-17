import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Reminder model representing a scheduled reminder
class ReminderModel extends Equatable {
  final String id;
  final String userId;
  final ReminderCategory category;
  final String customerName;
  final String customerPhone;
  final String? notes;
  final String description;
  final String message;
  final DateTime scheduledTime;
  final ReminderStatus status;
  final bool hasAlarm;
  final DateTime? alarmTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.customerName,
    required this.customerPhone,
    this.notes,
    required this.description,
    required this.message,
    required this.scheduledTime,
    required this.status,
    this.hasAlarm = false,
    this.alarmTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ReminderModel from JSON map
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      category: ReminderCategory.fromString(json['category'] ?? 'payment'),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      notes: json['notes'],
      description: json['description'] ?? '',
      message: json['message'] ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : DateTime.now(),
      status: ReminderStatus.fromString(json['status'] ?? 'pending'),
      hasAlarm: json['hasAlarm'] ?? false,
      alarmTime: json['alarmTime'] != null
          ? DateTime.parse(json['alarmTime'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert ReminderModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category.value,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
      'description': description,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.value,
      'hasAlarm': hasAlarm,
      'alarmTime': alarmTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert ReminderModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category.value,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
      'description': description,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.value,
      'hasAlarm': hasAlarm,
      'alarmTime': alarmTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  ReminderModel copyWith({
    String? id,
    String? userId,
    ReminderCategory? category,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? description,
    String? message,
    DateTime? scheduledTime,
    ReminderStatus? status,
    bool? hasAlarm,
    DateTime? alarmTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      alarmTime: alarmTime ?? this.alarmTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get category-specific color
  int get categoryColor => category.color;

  /// Get category emoji
  String get categoryEmoji => category.emoji;

  /// Check if reminder is due soon (within 24 hours)
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    return difference.inHours <= 24 && difference.isNegative == false;
  }

  /// Check if reminder is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(scheduledTime) &&
        status == ReminderStatus.pending;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    category,
    customerName,
    customerPhone,
    notes,
    description,
    message,
    scheduledTime,
    status,
    hasAlarm,
    alarmTime,
    createdAt,
    updatedAt,
  ];
}
