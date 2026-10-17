import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';
import 'attachment_model.dart';

class EmergencyCase {
  final String caseId;
  final String reporterId;
  final String? responderId;
  final String? facilityId;
  final GeoPoint incidentLocation;
  final IncidentType incidentType;
  final CaseStatus caseStatus;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String description;
  final List<Attachment> attachments;
  final bool emergencyContactNotified;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? patientName;

  const EmergencyCase({
    required this.caseId,
    required this.reporterId,
    this.responderId,
    this.facilityId,
    required this.incidentLocation,
    required this.incidentType,
    this.caseStatus = CaseStatus.created,
    required this.createdAt,
    this.assignedAt,
    this.completedAt,
    this.description = '',
    this.attachments = const [],
    this.emergencyContactNotified = false,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.patientName,
  });

  factory EmergencyCase.fromJson(Map<String, dynamic> json) => EmergencyCase(
    caseId: json['caseId'] as String? ?? '',
    reporterId: json['reporterId'] as String? ?? '',
    responderId: json['responderId'] as String?,
    facilityId: json['facilityId'] as String?,
    incidentLocation: json['incidentLocation'] is GeoPoint
        ? json['incidentLocation'] as GeoPoint
        : GeoPoint(
            (json['incidentLocation']['latitude'] as num?)?.toDouble() ?? 0,
            (json['incidentLocation']['longitude'] as num?)?.toDouble() ?? 0,
          ),
    incidentType: enumFromString(
      IncidentType.values,
      json['incidentType'] as String?,
      IncidentType.other,
    ),
    caseStatus: enumFromString(
      CaseStatus.values,
      json['caseStatus'] as String?,
      CaseStatus.created,
    ),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    assignedAt: json['assignedAt'] == null
        ? null
        : DateTime.tryParse(json['assignedAt'] as String),
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.tryParse(json['completedAt'] as String),
    description: json['description'] as String? ?? '',
    attachments: (json['attachments'] as List? ?? [])
        .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
        .toList(),
    emergencyContactNotified:
        json['emergencyContactNotified'] as bool? ?? false,
    emergencyContactName: json['emergencyContactName'] as String?,
    emergencyContactPhone: json['emergencyContactPhone'] as String?,
    patientName: json['patientName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'reporterId': reporterId,
    'responderId': responderId,
    'facilityId': facilityId,
    'incidentLocation': incidentLocation,
    'incidentType': enumToString(incidentType),
    'caseStatus': enumToString(caseStatus),
    'createdAt': createdAt.toIso8601String(),
    'assignedAt': assignedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'description': description,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'emergencyContactNotified': emergencyContactNotified,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'patientName': patientName,
  };

  EmergencyCase copyWith({
    String? caseId,
    String? reporterId,
    String? responderId,
    String? facilityId,
    GeoPoint? incidentLocation,
    IncidentType? incidentType,
    CaseStatus? caseStatus,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? description,
    List<Attachment>? attachments,
    bool? emergencyContactNotified,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? patientName,
  }) => EmergencyCase(
    caseId: caseId ?? this.caseId,
    reporterId: reporterId ?? this.reporterId,
    responderId: responderId ?? this.responderId,
    facilityId: facilityId ?? this.facilityId,
    incidentLocation: incidentLocation ?? this.incidentLocation,
    incidentType: incidentType ?? this.incidentType,
    caseStatus: caseStatus ?? this.caseStatus,
    createdAt: createdAt ?? this.createdAt,
    assignedAt: assignedAt ?? this.assignedAt,
    completedAt: completedAt ?? this.completedAt,
    description: description ?? this.description,
    attachments: attachments ?? this.attachments,
    emergencyContactNotified:
        emergencyContactNotified ?? this.emergencyContactNotified,
    emergencyContactName: emergencyContactName ?? this.emergencyContactName,
    emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    patientName: patientName ?? this.patientName,
  );

  @override
  String toString() => 'EmergencyCase($caseId, $incidentType, $caseStatus)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyCase && other.caseId == caseId);

  @override
  int get hashCode => caseId.hashCode;
}
