import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import 'certification_model.dart';

class ResponderModel {
  final String responderId;
  final String userId;
  final List<Certification> certifications;
  final bool isApproved;
  final DateTime? approvalDate;
  final QualificationLevel qualificationLevel;
  final GeoPoint? currentLocation;
  final bool isAvailable;
  final double averageRating;
  final int totalCasesResponded;
  final double successRate;
  final double responseTime;
  final List<String> specializations;

  const ResponderModel({
    required this.responderId,
    required this.userId,
    this.certifications = const [],
    this.isApproved = false,
    this.approvalDate,
    this.qualificationLevel = QualificationLevel.basic,
    this.currentLocation,
    this.isAvailable = false,
    this.averageRating = 0.0,
    this.totalCasesResponded = 0,
    this.successRate = 0.0,
    this.responseTime = 0.0,
    this.specializations = const [],
  });

  factory ResponderModel.fromJson(Map<String, dynamic> json) => ResponderModel(
    responderId: json['responderId'] as String? ?? '',
    userId: json['userId'] as String? ?? '',
    certifications: (json['certifications'] as List? ?? [])
        .map((e) => Certification.fromJson(e as Map<String, dynamic>))
        .toList(),
    isApproved: json['isApproved'] as bool? ?? false,
    approvalDate: json['approvalDate'] == null
        ? null
        : DateTime.tryParse(json['approvalDate'] as String),
    qualificationLevel: enumFromString(
      QualificationLevel.values,
      json['qualificationLevel'] as String?,
      QualificationLevel.basic,
    ),
    currentLocation: json['currentLocation'] == null
        ? null
        : json['currentLocation'] is GeoPoint
        ? json['currentLocation'] as GeoPoint
        : GeoPoint(
            (json['currentLocation']['latitude'] as num?)?.toDouble() ?? 0,
            (json['currentLocation']['longitude'] as num?)?.toDouble() ?? 0,
          ),
    isAvailable: json['isAvailable'] as bool? ?? false,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    totalCasesResponded: json['totalCasesResponded'] as int? ?? 0,
    successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
    responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
    specializations: List<String>.from(json['specializations'] as List? ?? []),
  );

  Map<String, dynamic> toJson() => {
    'responderId': responderId,
    'userId': userId,
    'certifications': certifications.map((e) => e.toJson()).toList(),
    'isApproved': isApproved,
    'approvalDate': approvalDate?.toIso8601String(),
    'qualificationLevel': enumToString(qualificationLevel),
    'currentLocation': currentLocation,
    'isAvailable': isAvailable,
    'averageRating': averageRating,
    'totalCasesResponded': totalCasesResponded,
    'successRate': successRate,
    'responseTime': responseTime,
    'specializations': specializations,
  };

  ResponderModel copyWith({
    String? responderId,
    String? userId,
    List<Certification>? certifications,
    bool? isApproved,
    DateTime? approvalDate,
    QualificationLevel? qualificationLevel,
    GeoPoint? currentLocation,
    bool? isAvailable,
    double? averageRating,
    int? totalCasesResponded,
    double? successRate,
    double? responseTime,
    List<String>? specializations,
  }) => ResponderModel(
    responderId: responderId ?? this.responderId,
    userId: userId ?? this.userId,
    certifications: certifications ?? this.certifications,
    isApproved: isApproved ?? this.isApproved,
    approvalDate: approvalDate ?? this.approvalDate,
    qualificationLevel: qualificationLevel ?? this.qualificationLevel,
    currentLocation: currentLocation ?? this.currentLocation,
    isAvailable: isAvailable ?? this.isAvailable,
    averageRating: averageRating ?? this.averageRating,
    totalCasesResponded: totalCasesResponded ?? this.totalCasesResponded,
    successRate: successRate ?? this.successRate,
    responseTime: responseTime ?? this.responseTime,
    specializations: specializations ?? this.specializations,
  );

  @override
  String toString() =>
      'ResponderModel($responderId, approved: $isApproved, available: $isAvailable)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponderModel && other.responderId == responderId);

  @override
  int get hashCode => responderId.hashCode;
}
