import '../core/constants/enums.dart';

class UserModel {
  final String userId;
  final String email;
  final String phoneNumber;
  final String fullName;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String? profilePhoto;
  final UserRole userType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool locationPermissionGranted;

  const UserModel({
    required this.userId,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.userType,
    this.dateOfBirth,
    this.gender = Gender.other,
    this.profilePhoto,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.locationPermissionGranted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] == null
            ? null
            : DateTime.tryParse(json['dateOfBirth'] as String),
        gender: enumFromString(Gender.values, json['gender'] as String?, Gender.other),
        profilePhoto: json['profilePhoto'] as String?,
        userType: enumFromString(UserRole.values, json['userType'] as String?, UserRole.reporter),
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        lastLoginAt: json['lastLoginAt'] == null
            ? null
            : DateTime.tryParse(json['lastLoginAt'] as String),
        locationPermissionGranted: json['locationPermissionGranted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': enumToString(gender),
        'profilePhoto': profilePhoto,
        'userType': enumToString(userType),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'locationPermissionGranted': locationPermissionGranted,
      };

  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    String? fullName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? profilePhoto,
    UserRole? userType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? locationPermissionGranted,
  }) =>
      UserModel(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        fullName: fullName ?? this.fullName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        userType: userType ?? this.userType,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      );

  @override
  String toString() =>
      'UserModel(userId: $userId, fullName: $fullName, userType: $userType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.userId == userId);

  @override
  int get hashCode => userId.hashCode;
}
