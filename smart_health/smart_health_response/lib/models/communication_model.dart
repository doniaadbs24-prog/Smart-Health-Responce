import '../core/constants/enums.dart';

class CommunicationRecord {
  final String communicationId;
  final String caseId;
  final String senderId;
  final SenderType senderType;
  final String recipientId;
  final MessageType messageType;
  final String messageContent;
  final List<String> attachments;
  final DateTime sentAt;
  final DateTime? readAt;

  const CommunicationRecord({
    required this.communicationId,
    required this.caseId,
    required this.senderId,
    required this.senderType,
    required this.recipientId,
    this.messageType = MessageType.chat,
    required this.messageContent,
    this.attachments = const [],
    required this.sentAt,
    this.readAt,
  });

  factory CommunicationRecord.fromJson(Map<String, dynamic> json) => CommunicationRecord(
        communicationId: json['communicationId'] as String? ?? '',
        caseId: json['caseId'] as String? ?? '',
        senderId: json['senderId'] as String? ?? '',
        senderType: enumFromString(
          SenderType.values,
          json['senderType'] as String?,
          SenderType.reporter,
        ),
        recipientId: json['recipientId'] as String? ?? '',
        messageType: enumFromString(
          MessageType.values,
          json['messageType'] as String?,
          MessageType.chat,
        ),
        messageContent: json['messageContent'] as String? ?? '',
        attachments: List<String>.from(json['attachments'] as List? ?? []),
        sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
        readAt: json['readAt'] == null ? null : DateTime.tryParse(json['readAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'communicationId': communicationId,
        'caseId': caseId,
        'senderId': senderId,
        'senderType': enumToString(senderType),
        'recipientId': recipientId,
        'messageType': enumToString(messageType),
        'messageContent': messageContent,
        'attachments': attachments,
        'sentAt': sentAt.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
      };

  CommunicationRecord copyWith({
    String? communicationId,
    String? caseId,
    String? senderId,
    SenderType? senderType,
    String? recipientId,
    MessageType? messageType,
    String? messageContent,
    List<String>? attachments,
    DateTime? sentAt,
    DateTime? readAt,
  }) =>
      CommunicationRecord(
        communicationId: communicationId ?? this.communicationId,
        caseId: caseId ?? this.caseId,
        senderId: senderId ?? this.senderId,
        senderType: senderType ?? this.senderType,
        recipientId: recipientId ?? this.recipientId,
        messageType: messageType ?? this.messageType,
        messageContent: messageContent ?? this.messageContent,
        attachments: attachments ?? this.attachments,
        sentAt: sentAt ?? this.sentAt,
        readAt: readAt ?? this.readAt,
      );

  @override
  String toString() => 'CommunicationRecord($communicationId, $senderType -> $recipientId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommunicationRecord && other.communicationId == communicationId);

  @override
  int get hashCode => communicationId.hashCode;
}
