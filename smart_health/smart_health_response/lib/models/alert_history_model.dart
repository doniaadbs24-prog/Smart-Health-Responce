import '../core/constants/enums.dart';

class AlertHistory {
  final String alertId;
  final String caseId;
  final String? responderId;
  final DateTime alertSentAt;
  final DateTime? alertReceivedAt;
  final DateTime? alertAcceptedAt;
  final DateTime? alertRejectedAt;
  final String? rejectionReason;
  final double distance;
  final AlertStatus acceptanceStatus;
  final AlertType alertType;

  const AlertHistory({
    required this.alertId,
    required this.caseId,
    this.responderId,
    required this.alertSentAt,
    this.alertReceivedAt,
    this.alertAcceptedAt,
    this.alertRejectedAt,
    this.rejectionReason,
    this.distance = 0.0,
    this.acceptanceStatus = AlertStatus.pending,
    this.alertType = AlertType.pushNotification,
  });

  factory AlertHistory.fromJson(Map<String, dynamic> json) => AlertHistory(
        alertId: json['alertId'] as String? ?? '',
        caseId: json['caseId'] as String? ?? '',
        responderId: json['responderId'] as String?,
        alertSentAt: DateTime.tryParse(json['alertSentAt'] as String? ?? '') ?? DateTime.now(),
        alertReceivedAt: json['alertReceivedAt'] == null
            ? null
            : DateTime.tryParse(json['alertReceivedAt'] as String),
        alertAcceptedAt: json['alertAcceptedAt'] == null
            ? null
            : DateTime.tryParse(json['alertAcceptedAt'] as String),
        alertRejectedAt: json['alertRejectedAt'] == null
            ? null
            : DateTime.tryParse(json['alertRejectedAt'] as String),
        rejectionReason: json['rejectionReason'] as String?,
        distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
        acceptanceStatus: enumFromString(
          AlertStatus.values,
          json['acceptanceStatus'] as String?,
          AlertStatus.pending,
        ),
        alertType: enumFromString(
          AlertType.values,
          json['alertType'] as String?,
          AlertType.pushNotification,
        ),
      );

  Map<String, dynamic> toJson() => {
        'alertId': alertId,
        'caseId': caseId,
        'responderId': responderId,
        'alertSentAt': alertSentAt.toIso8601String(),
        'alertReceivedAt': alertReceivedAt?.toIso8601String(),
        'alertAcceptedAt': alertAcceptedAt?.toIso8601String(),
        'alertRejectedAt': alertRejectedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'distance': distance,
        'acceptanceStatus': enumToString(acceptanceStatus),
        'alertType': enumToString(alertType),
      };

  AlertHistory copyWith({
    String? alertId,
    String? caseId,
    String? responderId,
    DateTime? alertSentAt,
    DateTime? alertReceivedAt,
    DateTime? alertAcceptedAt,
    DateTime? alertRejectedAt,
    String? rejectionReason,
    double? distance,
    AlertStatus? acceptanceStatus,
    AlertType? alertType,
  }) =>
      AlertHistory(
        alertId: alertId ?? this.alertId,
        caseId: caseId ?? this.caseId,
        responderId: responderId ?? this.responderId,
        alertSentAt: alertSentAt ?? this.alertSentAt,
        alertReceivedAt: alertReceivedAt ?? this.alertReceivedAt,
        alertAcceptedAt: alertAcceptedAt ?? this.alertAcceptedAt,
        alertRejectedAt: alertRejectedAt ?? this.alertRejectedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        distance: distance ?? this.distance,
        acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
        alertType: alertType ?? this.alertType,
      );

  @override
  String toString() => 'AlertHistory($alertId, $acceptanceStatus, distance: $distance)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AlertHistory && other.alertId == alertId);

  @override
  int get hashCode => alertId.hashCode;
}
