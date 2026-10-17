import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class AuditLog {
  final String logId;
  final String userId;
  final AuditActionType actionType;
  final String resourceType;
  final String resourceId;
  final String changeDetails;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final AuditStatus status;
  final String? errorMessage;

  const AuditLog({
    required this.logId,
    required this.userId,
    required this.actionType,
    required this.resourceType,
    required this.resourceId,
    this.changeDetails = '',
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.status = AuditStatus.success,
    this.errorMessage,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        logId: json['logId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        actionType: enumFromString(
          AuditActionType.values,
          json['actionType'] as String?,
          AuditActionType.systemAction,
        ),
        resourceType: json['resourceType'] as String? ?? '',
        resourceId: json['resourceId'] as String? ?? '',
        changeDetails: json['changeDetails'] as String? ?? '',
        timestamp: _parseTimestamp(json['timestamp']),
        ipAddress: json['ipAddress'] as String?,
        userAgent: json['userAgent'] as String?,
        status: enumFromString(AuditStatus.values, json['status'] as String?, AuditStatus.success),
        errorMessage: json['errorMessage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'logId': logId,
        'userId': userId,
        'actionType': enumToString(actionType),
        'resourceType': resourceType,
        'resourceId': resourceId,
        'changeDetails': changeDetails,
        'timestamp': timestamp.toIso8601String(),
        'ipAddress': ipAddress,
        'userAgent': userAgent,
        'status': enumToString(status),
        'errorMessage': errorMessage,
      };

  AuditLog copyWith({
    String? logId,
    String? userId,
    AuditActionType? actionType,
    String? resourceType,
    String? resourceId,
    String? changeDetails,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    AuditStatus? status,
    String? errorMessage,
  }) =>
      AuditLog(
        logId: logId ?? this.logId,
        userId: userId ?? this.userId,
        actionType: actionType ?? this.actionType,
        resourceType: resourceType ?? this.resourceType,
        resourceId: resourceId ?? this.resourceId,
        changeDetails: changeDetails ?? this.changeDetails,
        timestamp: timestamp ?? this.timestamp,
        ipAddress: ipAddress ?? this.ipAddress,
        userAgent: userAgent ?? this.userAgent,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  String toString() => 'AuditLog($logId, $actionType, $resourceType:$resourceId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AuditLog && other.logId == logId);

  @override
  int get hashCode => logId.hashCode;
}

/// Parse a timestamp that may be a Firestore Timestamp, an ISO-8601 String,
/// or null.
DateTime _parseTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
