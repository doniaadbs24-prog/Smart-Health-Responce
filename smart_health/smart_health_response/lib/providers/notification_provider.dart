import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/service_locator.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];
  bool _isLoading = false;
  StreamSubscription<List<AppNotification>>? _notifSub;

  List<AppNotification> get items => _items;
  bool get isLoading => _isLoading;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void watchForUser(String userId) {
    _isLoading = true;
    notifyListeners();
    _notifSub?.cancel();
    _notifSub = sl.notifications.watchForUser(userId).listen((items) {
      _items = items;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markRead(String notificationId) async {
    await sl.notifications.markAsRead(notificationId);
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }
}
