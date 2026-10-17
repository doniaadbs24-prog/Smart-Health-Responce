import '../core/constants/enums.dart';

class Attachment {
  final String attachmentId;
  final AttachmentType attachmentType;
  final String attachmentURL;
  final DateTime uploadedAt;

  const Attachment({
    required this.attachmentId,
    required this.attachmentType,
    required this.attachmentURL,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        attachmentId: json['attachmentId'] as String? ?? '',
        attachmentType: enumFromString(
          AttachmentType.values,
          json['attachmentType'] as String?,
          AttachmentType.photo,
        ),
        attachmentURL: json['attachmentURL'] as String? ?? '',
        uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'attachmentId': attachmentId,
        'attachmentType': enumToString(attachmentType),
        'attachmentURL': attachmentURL,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  Attachment copyWith({
    String? attachmentId,
    AttachmentType? attachmentType,
    String? attachmentURL,
    DateTime? uploadedAt,
  }) =>
      Attachment(
        attachmentId: attachmentId ?? this.attachmentId,
        attachmentType: attachmentType ?? this.attachmentType,
        attachmentURL: attachmentURL ?? this.attachmentURL,
        uploadedAt: uploadedAt ?? this.uploadedAt,
      );

  @override
  String toString() => 'Attachment($attachmentType, $attachmentURL)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Attachment && other.attachmentId == attachmentId);

  @override
  int get hashCode => attachmentId.hashCode;
}
