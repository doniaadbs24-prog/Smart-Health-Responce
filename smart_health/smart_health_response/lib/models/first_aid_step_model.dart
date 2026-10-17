class FirstAidStep {
  final int stepNumber;
  final String stepTitle;
  final String stepDescription;
  final String? stepImage;
  final String? stepVideo;
  final String? stepAudio;
  final int duration;

  const FirstAidStep({
    required this.stepNumber,
    required this.stepTitle,
    required this.stepDescription,
    this.stepImage,
    this.stepVideo,
    this.stepAudio,
    this.duration = 0,
  });

  factory FirstAidStep.fromJson(Map<String, dynamic> json) => FirstAidStep(
        stepNumber: json['stepNumber'] as int? ?? 0,
        stepTitle: json['stepTitle'] as String? ?? '',
        stepDescription: json['stepDescription'] as String? ?? '',
        stepImage: json['stepImage'] as String?,
        stepVideo: json['stepVideo'] as String?,
        stepAudio: json['stepAudio'] as String?,
        duration: json['duration'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'stepTitle': stepTitle,
        'stepDescription': stepDescription,
        'stepImage': stepImage,
        'stepVideo': stepVideo,
        'stepAudio': stepAudio,
        'duration': duration,
      };

  FirstAidStep copyWith({
    int? stepNumber,
    String? stepTitle,
    String? stepDescription,
    String? stepImage,
    String? stepVideo,
    String? stepAudio,
    int? duration,
  }) =>
      FirstAidStep(
        stepNumber: stepNumber ?? this.stepNumber,
        stepTitle: stepTitle ?? this.stepTitle,
        stepDescription: stepDescription ?? this.stepDescription,
        stepImage: stepImage ?? this.stepImage,
        stepVideo: stepVideo ?? this.stepVideo,
        stepAudio: stepAudio ?? this.stepAudio,
        duration: duration ?? this.duration,
      );

  @override
  String toString() => 'FirstAidStep($stepNumber: $stepTitle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FirstAidStep &&
          other.stepNumber == stepNumber &&
          other.stepTitle == stepTitle);

  @override
  int get hashCode => Object.hash(stepNumber, stepTitle);
}
