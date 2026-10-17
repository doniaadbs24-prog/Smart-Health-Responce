class AppNotification {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String? caseId;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    this.caseId,
    this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        notificationId: json['notificationId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        caseId: json['caseId'] as String?,
        type: json['type'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'title': title,
        'body': body,
        'caseId': caseId,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  AppNotification copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    String? caseId,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) =>
      AppNotification(
        notificationId: notificationId ?? this.notificationId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
        caseId: caseId ?? this.caseId,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'AppNotification($notificationId, $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNotification && other.notificationId == notificationId);

  @override
  int get hashCode => notificationId.hashCode;
}
