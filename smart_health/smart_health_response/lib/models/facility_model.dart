import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class FacilityModel {
  final String facilityId;
  final String facilityName;
  final FacilityType facilityType;
  final String address;
  final GeoPoint location;
  final String contactNumber;
  final String email;
  final String emergencyContactNumber;
  final int capacity;
  final int currentPatientCount;
  final bool isActive;
  final List<String> specialties;
  final List<String> equipmentList;
  final double averageResponseTime;
  final int casesReceived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FacilityModel({
    required this.facilityId,
    required this.facilityName,
    this.facilityType = FacilityType.hospital,
    required this.address,
    required this.location,
    required this.contactNumber,
    this.email = '',
    this.emergencyContactNumber = '',
    this.capacity = 0,
    this.currentPatientCount = 0,
    this.isActive = true,
    this.specialties = const [],
    this.equipmentList = const [],
    this.averageResponseTime = 0.0,
    this.casesReceived = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  int get availableBeds => (capacity - currentPatientCount).clamp(0, capacity);

  factory FacilityModel.fromJson(Map<String, dynamic> json) => FacilityModel(
    facilityId: json['facilityId'] as String? ?? '',
    facilityName: json['facilityName'] as String? ?? '',
    facilityType: enumFromString(
      FacilityType.values,
      json['facilityType'] as String?,
      FacilityType.hospital,
    ),
    address: json['address'] as String? ?? '',
    location: json['location'] is GeoPoint
        ? json['location'] as GeoPoint
        : GeoPoint(
            (json['location']['latitude'] as num?)?.toDouble() ?? 0,
            (json['location']['longitude'] as num?)?.toDouble() ?? 0,
          ),
    contactNumber: json['contactNumber'] as String? ?? '',
    email: json['email'] as String? ?? '',
    emergencyContactNumber: json['emergencyContactNumber'] as String? ?? '',
    capacity: json['capacity'] as int? ?? 0,
    currentPatientCount: json['currentPatientCount'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    specialties: List<String>.from(json['specialties'] as List? ?? []),
    equipmentList: List<String>.from(json['equipmentList'] as List? ?? []),
    averageResponseTime:
        (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    casesReceived: json['casesReceived'] as int? ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'facilityId': facilityId,
    'facilityName': facilityName,
    'facilityType': enumToString(facilityType),
    'address': address,
    'location': location,
    'contactNumber': contactNumber,
    'email': email,
    'emergencyContactNumber': emergencyContactNumber,
    'capacity': capacity,
    'currentPatientCount': currentPatientCount,
    'isActive': isActive,
    'specialties': specialties,
    'equipmentList': equipmentList,
    'averageResponseTime': averageResponseTime,
    'casesReceived': casesReceived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  FacilityModel copyWith({
    String? facilityId,
    String? facilityName,
    FacilityType? facilityType,
    String? address,
    GeoPoint? location,
    String? contactNumber,
    String? email,
    String? emergencyContactNumber,
    int? capacity,
    int? currentPatientCount,
    bool? isActive,
    List<String>? specialties,
    List<String>? equipmentList,
    double? averageResponseTime,
    int? casesReceived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FacilityModel(
    facilityId: facilityId ?? this.facilityId,
    facilityName: facilityName ?? this.facilityName,
    facilityType: facilityType ?? this.facilityType,
    address: address ?? this.address,
    location: location ?? this.location,
    contactNumber: contactNumber ?? this.contactNumber,
    email: email ?? this.email,
    emergencyContactNumber:
        emergencyContactNumber ?? this.emergencyContactNumber,
    capacity: capacity ?? this.capacity,
    currentPatientCount: currentPatientCount ?? this.currentPatientCount,
    isActive: isActive ?? this.isActive,
    specialties: specialties ?? this.specialties,
    equipmentList: equipmentList ?? this.equipmentList,
    averageResponseTime: averageResponseTime ?? this.averageResponseTime,
    casesReceived: casesReceived ?? this.casesReceived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'FacilityModel($facilityName, beds: $availableBeds/$capacity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FacilityModel && other.facilityId == facilityId);

  @override
  int get hashCode => facilityId.hashCode;
}
