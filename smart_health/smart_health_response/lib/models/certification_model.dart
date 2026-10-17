import '../core/constants/enums.dart';

class Certification {
  final String certificationId;
  final CertificationType certificationType;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String? certificateDocument;
  final bool isVerified;

  const Certification({
    required this.certificationId,
    required this.certificationType,
    required this.issueDate,
    required this.expiryDate,
    this.certificateDocument,
    this.isVerified = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        certificationId: json['certificationId'] as String? ?? '',
        certificationType: enumFromString(
          CertificationType.values,
          json['certificationType'] as String?,
          CertificationType.firstAid,
        ),
        issueDate: DateTime.tryParse(json['issueDate'] as String? ?? '') ?? DateTime.now(),
        expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? '') ?? DateTime.now(),
        certificateDocument: json['certificateDocument'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'certificationId': certificationId,
        'certificationType': enumToString(certificationType),
        'issueDate': issueDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'certificateDocument': certificateDocument,
        'isVerified': isVerified,
      };

  Certification copyWith({
    String? certificationId,
    CertificationType? certificationType,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? certificateDocument,
    bool? isVerified,
  }) =>
      Certification(
        certificationId: certificationId ?? this.certificationId,
        certificationType: certificationType ?? this.certificationType,
        issueDate: issueDate ?? this.issueDate,
        expiryDate: expiryDate ?? this.expiryDate,
        certificateDocument: certificateDocument ?? this.certificateDocument,
        isVerified: isVerified ?? this.isVerified,
      );

  @override
  String toString() => 'Certification($certificationType, expires: $expiryDate)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Certification && other.certificationId == certificationId);

  @override
  int get hashCode => certificationId.hashCode;
}
