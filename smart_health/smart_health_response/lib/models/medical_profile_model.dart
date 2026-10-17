import '../core/constants/enums.dart';

class MedicalProfile {
  final BloodType? bloodType;
  final List<String> allergies;
  final List<String> medications;
  final List<String> chronicDiseases;
  final String emergencyNotes;

  const MedicalProfile({
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.chronicDiseases = const [],
    this.emergencyNotes = '',
  });

  factory MedicalProfile.fromJson(Map<String, dynamic> json) => MedicalProfile(
        bloodType: json['bloodType'] == null
            ? null
            : enumFromString(BloodType.values, json['bloodType'] as String?, BloodType.oPos),
        allergies: List<String>.from(json['allergies'] as List? ?? []),
        medications: List<String>.from(json['medications'] as List? ?? []),
        chronicDiseases: List<String>.from(json['chronicDiseases'] as List? ?? []),
        emergencyNotes: json['emergencyNotes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'bloodType': bloodType == null ? null : enumToString(bloodType!),
        'allergies': allergies,
        'medications': medications,
        'chronicDiseases': chronicDiseases,
        'emergencyNotes': emergencyNotes,
      };

  MedicalProfile copyWith({
    BloodType? bloodType,
    List<String>? allergies,
    List<String>? medications,
    List<String>? chronicDiseases,
    String? emergencyNotes,
  }) =>
      MedicalProfile(
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
        medications: medications ?? this.medications,
        chronicDiseases: chronicDiseases ?? this.chronicDiseases,
        emergencyNotes: emergencyNotes ?? this.emergencyNotes,
      );

  @override
  String toString() => 'MedicalProfile(bloodType: $bloodType, allergies: $allergies)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalProfile &&
          other.bloodType == bloodType &&
          other.emergencyNotes == emergencyNotes);

  @override
  int get hashCode => Object.hash(bloodType, emergencyNotes);
}
