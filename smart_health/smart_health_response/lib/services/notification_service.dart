import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/firestore_collections.dart';
import '../models/notification_model.dart';
import '../utils/helpers.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  void Function(String? payload)? _onTap;

  Future<void> init({void Function(String? payload)? onTap}) async {
    _onTap = onTap;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _onTap?.call(response.payload);
      },
    );
  }

  Future<List<AppNotification>> getForUser(String userId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  }

  Stream<List<AppNotification>> watchForUser(String userId) {
    return _db
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> push({
    required String userId,
    required String title,
    required String body,
    String? caseId,
    String? type,
  }) async {
    final notification = AppNotification(
      notificationId: Helpers.generateId(),
      userId: userId,
      title: title,
      body: body,
      caseId: caseId,
      type: type,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(FirestoreCollections.notifications)
        .doc(notification.notificationId)
        .set(notification.toJson());
    showLocalNotification(title: title, body: body, payload: caseId);
  }

  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<int> unreadCount(String userId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  void showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    const androidDetails = AndroidNotificationDetails(
      'shr_alerts',
      'Emergency alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    _local.show(0, title, body, details, payload: payload);
  }
}
