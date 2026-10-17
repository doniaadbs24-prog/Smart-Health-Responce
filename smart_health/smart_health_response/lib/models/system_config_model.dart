class SystemConfig {
  final String configId;
  final String configKey;
  final String configValue;
  final String description;
  final String dataType;
  final bool isActive;
  final DateTime updatedAt;
  final String? updatedBy;

  const SystemConfig({
    required this.configId,
    required this.configKey,
    required this.configValue,
    this.description = '',
    this.dataType = 'String',
    this.isActive = true,
    required this.updatedAt,
    this.updatedBy,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) => SystemConfig(
        configId: json['configId'] as String? ?? '',
        configKey: json['configKey'] as String? ?? '',
        configValue: json['configValue'] as String? ?? '',
        description: json['description'] as String? ?? '',
        dataType: json['dataType'] as String? ?? 'String',
        isActive: json['isActive'] as bool? ?? true,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        updatedBy: json['updatedBy'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'configId': configId,
        'configKey': configKey,
        'configValue': configValue,
        'description': description,
        'dataType': dataType,
        'isActive': isActive,
        'updatedAt': updatedAt.toIso8601String(),
        'updatedBy': updatedBy,
      };

  SystemConfig copyWith({
    String? configId,
    String? configKey,
    String? configValue,
    String? description,
    String? dataType,
    bool? isActive,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      SystemConfig(
        configId: configId ?? this.configId,
        configKey: configKey ?? this.configKey,
        configValue: configValue ?? this.configValue,
        description: description ?? this.description,
        dataType: dataType ?? this.dataType,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );

  @override
  String toString() => 'SystemConfig($configKey = $configValue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SystemConfig && other.configId == configId);

  @override
  int get hashCode => configId.hashCode;
}
