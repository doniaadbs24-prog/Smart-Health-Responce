import '../core/constants/enums.dart';

class CaseClosureReport {
  final String reportId;
  final String caseId;
  final String responderId;
  final DateTime closedAt;
  final CaseOutcome caseOutcome;
  final String finalNotes;
  final int caseDuration;
  final double distanceTraveled;
  final double? responderRating;
  final String? reporterFeedback;

  const CaseClosureReport({
    required this.reportId,
    required this.caseId,
    required this.responderId,
    required this.closedAt,
    this.caseOutcome = CaseOutcome.patientStable,
    this.finalNotes = '',
    this.caseDuration = 0,
    this.distanceTraveled = 0.0,
    this.responderRating,
    this.reporterFeedback,
  });

  factory CaseClosureReport.fromJson(Map<String, dynamic> json) => CaseClosureReport(
        reportId: json['reportId'] as String? ?? '',
        caseId: json['caseId'] as String? ?? '',
        responderId: json['responderId'] as String? ?? '',
        closedAt: DateTime.tryParse(json['closedAt'] as String? ?? '') ?? DateTime.now(),
        caseOutcome: enumFromString(
          CaseOutcome.values,
          json['caseOutcome'] as String?,
          CaseOutcome.patientStable,
        ),
        finalNotes: json['finalNotes'] as String? ?? '',
        caseDuration: json['caseDuration'] as int? ?? 0,
        distanceTraveled: (json['distanceTraveled'] as num?)?.toDouble() ?? 0.0,
        responderRating: (json['responderRating'] as num?)?.toDouble(),
        reporterFeedback: json['reporterFeedback'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'caseId': caseId,
        'responderId': responderId,
        'closedAt': closedAt.toIso8601String(),
        'caseOutcome': enumToString(caseOutcome),
        'finalNotes': finalNotes,
        'caseDuration': caseDuration,
        'distanceTraveled': distanceTraveled,
        'responderRating': responderRating,
        'reporterFeedback': reporterFeedback,
      };

  CaseClosureReport copyWith({
    String? reportId,
    String? caseId,
    String? responderId,
    DateTime? closedAt,
    CaseOutcome? caseOutcome,
    String? finalNotes,
    int? caseDuration,
    double? distanceTraveled,
    double? responderRating,
    String? reporterFeedback,
  }) =>
      CaseClosureReport(
        reportId: reportId ?? this.reportId,
        caseId: caseId ?? this.caseId,
        responderId: responderId ?? this.responderId,
        closedAt: closedAt ?? this.closedAt,
        caseOutcome: caseOutcome ?? this.caseOutcome,
        finalNotes: finalNotes ?? this.finalNotes,
        caseDuration: caseDuration ?? this.caseDuration,
        distanceTraveled: distanceTraveled ?? this.distanceTraveled,
        responderRating: responderRating ?? this.responderRating,
        reporterFeedback: reporterFeedback ?? this.reporterFeedback,
      );

  @override
  String toString() => 'CaseClosureReport($reportId, $caseOutcome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseClosureReport && other.reportId == reportId);

  @override
  int get hashCode => reportId.hashCode;
}
