class VitalSigns {
  final int? heartRate;
  final String? bloodPressure;
  final int? respiratoryRate;
  final double? temperature;
  final double? oxygenSaturation;

  const VitalSigns({
    this.heartRate,
    this.bloodPressure,
    this.respiratoryRate,
    this.temperature,
    this.oxygenSaturation,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) => VitalSigns(
        heartRate: json['heartRate'] as int?,
        bloodPressure: json['bloodPressure'] as String?,
        respiratoryRate: json['respiratoryRate'] as int?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'heartRate': heartRate,
        'bloodPressure': bloodPressure,
        'respiratoryRate': respiratoryRate,
        'temperature': temperature,
        'oxygenSaturation': oxygenSaturation,
      };

  VitalSigns copyWith({
    int? heartRate,
    String? bloodPressure,
    int? respiratoryRate,
    double? temperature,
    double? oxygenSaturation,
  }) =>
      VitalSigns(
        heartRate: heartRate ?? this.heartRate,
        bloodPressure: bloodPressure ?? this.bloodPressure,
        respiratoryRate: respiratoryRate ?? this.respiratoryRate,
        temperature: temperature ?? this.temperature,
        oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      );

  @override
  String toString() => 'VitalSigns(HR: $heartRate, BP: $bloodPressure, SpO2: $oxygenSaturation)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalSigns &&
          other.heartRate == heartRate &&
          other.bloodPressure == bloodPressure &&
          other.respiratoryRate == respiratoryRate &&
          other.temperature == temperature &&
          other.oxygenSaturation == oxygenSaturation);

  @override
  int get hashCode =>
      Object.hash(heartRate, bloodPressure, respiratoryRate, temperature, oxygenSaturation);
}
