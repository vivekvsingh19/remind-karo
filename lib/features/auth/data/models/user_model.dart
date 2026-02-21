import 'package:equatable/equatable.dart';

/// User model representing a registered user
class UserModel extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Backend uses 'user_id' (PostgreSQL column), fallback to 'id'
      id: (json['user_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['mobile_number'] ?? '',
      email: json['email'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert UserModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Empty user for initial state
  static final empty = UserModel(
    id: '',
    name: '',
    phoneNumber: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Check if user is empty
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    email,
    photoUrl,
    createdAt,
    updatedAt,
  ];
}
