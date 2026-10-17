import '../core/constants/enums.dart';
import 'first_aid_step_model.dart';

class FirstAidGuide {
  final String guideId;
  final FirstAidType guidanceType;
  final String title;
  final String description;
  final List<FirstAidStep> steps;
  final List<String> prerequisites;
  final List<String> warnings;
  final String emergencyHotline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const FirstAidGuide({
    required this.guideId,
    required this.guidanceType,
    required this.title,
    this.description = '',
    this.steps = const [],
    this.prerequisites = const [],
    this.warnings = const [],
    this.emergencyHotline = '',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory FirstAidGuide.fromJson(Map<String, dynamic> json) => FirstAidGuide(
        guideId: json['guideId'] as String? ?? '',
        guidanceType: enumFromString(
          FirstAidType.values,
          json['guidanceType'] as String?,
          FirstAidType.cpr,
        ),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        steps: (json['steps'] as List? ?? [])
            .map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
        warnings: List<String>.from(json['warnings'] as List? ?? []),
        emergencyHotline: json['emergencyHotline'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'guideId': guideId,
        'guidanceType': enumToString(guidanceType),
        'title': title,
        'description': description,
        'steps': steps.map((e) => e.toJson()).toList(),
        'prerequisites': prerequisites,
        'warnings': warnings,
        'emergencyHotline': emergencyHotline,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isActive': isActive,
      };

  FirstAidGuide copyWith({
    String? guideId,
    FirstAidType? guidanceType,
    String? title,
    String? description,
    List<FirstAidStep>? steps,
    List<String>? prerequisites,
    List<String>? warnings,
    String? emergencyHotline,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) =>
      FirstAidGuide(
        guideId: guideId ?? this.guideId,
        guidanceType: guidanceType ?? this.guidanceType,
        title: title ?? this.title,
        description: description ?? this.description,
        steps: steps ?? this.steps,
        prerequisites: prerequisites ?? this.prerequisites,
        warnings: warnings ?? this.warnings,
        emergencyHotline: emergencyHotline ?? this.emergencyHotline,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  @override
  String toString() => 'FirstAidGuide($guideId, $title, ${steps.length} steps)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FirstAidGuide && other.guideId == guideId);

  @override
  int get hashCode => guideId.hashCode;
}
