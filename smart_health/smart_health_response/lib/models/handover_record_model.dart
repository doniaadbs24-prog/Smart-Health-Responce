import 'vital_signs_model.dart';

class HandoverRecord {
  final String handoverId;
  final String caseId;
  final String responderId;
  final String facilityId;
  final DateTime handoverTime;
  final String patientCondition;
  final VitalSigns vitalSigns;
  final List<String> treatmentsProvided;
  final String treatmentNotes;
  final String receivingStaffName;
  final String? receivingStaffSignature;
  final String? patientId;
  final DateTime? confirmedAt;

  const HandoverRecord({
    required this.handoverId,
    required this.caseId,
    required this.responderId,
    required this.facilityId,
    required this.handoverTime,
    this.patientCondition = '',
    this.vitalSigns = const VitalSigns(),
    this.treatmentsProvided = const [],
    this.treatmentNotes = '',
    this.receivingStaffName = '',
    this.receivingStaffSignature,
    this.patientId,
    this.confirmedAt,
  });

  factory HandoverRecord.fromJson(Map<String, dynamic> json) => HandoverRecord(
        handoverId: json['handoverId'] as String? ?? '',
        caseId: json['caseId'] as String? ?? '',
        responderId: json['responderId'] as String? ?? '',
        facilityId: json['facilityId'] as String? ?? '',
        handoverTime: DateTime.tryParse(json['handoverTime'] as String? ?? '') ?? DateTime.now(),
        patientCondition: json['patientCondition'] as String? ?? '',
        vitalSigns: VitalSigns.fromJson(json['vitalSigns'] as Map<String, dynamic>? ?? {}),
        treatmentsProvided: List<String>.from(json['treatmentsProvided'] as List? ?? []),
        treatmentNotes: json['treatmentNotes'] as String? ?? '',
        receivingStaffName: json['receivingStaffName'] as String? ?? '',
        receivingStaffSignature: json['receivingStaffSignature'] as String?,
        patientId: json['patientId'] as String?,
        confirmedAt: json['confirmedAt'] == null
            ? null
            : DateTime.tryParse(json['confirmedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'handoverId': handoverId,
        'caseId': caseId,
        'responderId': responderId,
        'facilityId': facilityId,
        'handoverTime': handoverTime.toIso8601String(),
        'patientCondition': patientCondition,
        'vitalSigns': vitalSigns.toJson(),
        'treatmentsProvided': treatmentsProvided,
        'treatmentNotes': treatmentNotes,
        'receivingStaffName': receivingStaffName,
        'receivingStaffSignature': receivingStaffSignature,
        'patientId': patientId,
        'confirmedAt': confirmedAt?.toIso8601String(),
      };

  HandoverRecord copyWith({
    String? handoverId,
    String? caseId,
    String? responderId,
    String? facilityId,
    DateTime? handoverTime,
    String? patientCondition,
    VitalSigns? vitalSigns,
    List<String>? treatmentsProvided,
    String? treatmentNotes,
    String? receivingStaffName,
    String? receivingStaffSignature,
    String? patientId,
    DateTime? confirmedAt,
  }) =>
      HandoverRecord(
        handoverId: handoverId ?? this.handoverId,
        caseId: caseId ?? this.caseId,
        responderId: responderId ?? this.responderId,
        facilityId: facilityId ?? this.facilityId,
        handoverTime: handoverTime ?? this.handoverTime,
        patientCondition: patientCondition ?? this.patientCondition,
        vitalSigns: vitalSigns ?? this.vitalSigns,
        treatmentsProvided: treatmentsProvided ?? this.treatmentsProvided,
        treatmentNotes: treatmentNotes ?? this.treatmentNotes,
        receivingStaffName: receivingStaffName ?? this.receivingStaffName,
        receivingStaffSignature: receivingStaffSignature ?? this.receivingStaffSignature,
        patientId: patientId ?? this.patientId,
        confirmedAt: confirmedAt ?? this.confirmedAt,
      );

  @override
  String toString() => 'HandoverRecord($handoverId, case: $caseId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HandoverRecord && other.handoverId == handoverId);

  @override
  int get hashCode => handoverId.hashCode;
}
