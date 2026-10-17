import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/cards/notification_card.dart';
import '../../widgets/layout/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<NotificationProvider>().watchForUser(user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No notifications',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: p.items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) => NotificationCard(
                notification: p.items[i],
                onTap: () => context.read<NotificationProvider>().markRead(
                  p.items[i].notificationId,
                ),
              ),
            ),
    );
  }
}
