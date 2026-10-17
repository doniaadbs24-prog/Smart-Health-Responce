import 'emergency_contact_model.dart';
import 'medical_profile_model.dart';

class ReporterModel {
  final String reporterId;
  final String userId;
  final List<EmergencyContact> emergencyContacts;
  final MedicalProfile medicalProfile;
  final String address;
  final int emergencyAlertsSent;
  final double averageRating;

  const ReporterModel({
    required this.reporterId,
    required this.userId,
    this.emergencyContacts = const [],
    this.medicalProfile = const MedicalProfile(),
    this.address = '',
    this.emergencyAlertsSent = 0,
    this.averageRating = 0.0,
  });

  factory ReporterModel.fromJson(Map<String, dynamic> json) => ReporterModel(
        reporterId: json['reporterId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        emergencyContacts: (json['emergencyContacts'] as List? ?? [])
            .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
            .toList(),
        medicalProfile: json['medicalProfile'] == null
            ? const MedicalProfile()
            : MedicalProfile.fromJson(json['medicalProfile'] as Map<String, dynamic>),
        address: json['address'] as String? ?? '',
        emergencyAlertsSent: json['emergencyAlertsSent'] as int? ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'reporterId': reporterId,
        'userId': userId,
        'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
        'medicalProfile': medicalProfile.toJson(),
        'address': address,
        'emergencyAlertsSent': emergencyAlertsSent,
        'averageRating': averageRating,
      };

  ReporterModel copyWith({
    String? reporterId,
    String? userId,
    List<EmergencyContact>? emergencyContacts,
    MedicalProfile? medicalProfile,
    String? address,
    int? emergencyAlertsSent,
    double? averageRating,
  }) =>
      ReporterModel(
        reporterId: reporterId ?? this.reporterId,
        userId: userId ?? this.userId,
        emergencyContacts: emergencyContacts ?? this.emergencyContacts,
        medicalProfile: medicalProfile ?? this.medicalProfile,
        address: address ?? this.address,
        emergencyAlertsSent: emergencyAlertsSent ?? this.emergencyAlertsSent,
        averageRating: averageRating ?? this.averageRating,
      );

  @override
  String toString() => 'ReporterModel($reporterId, alerts: $emergencyAlertsSent)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReporterModel && other.reporterId == reporterId);

  @override
  int get hashCode => reporterId.hashCode;
}
