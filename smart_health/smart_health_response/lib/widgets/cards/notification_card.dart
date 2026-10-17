import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/notification_model.dart';
import '../../utils/formatters.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? AppColors.surface
          : AppColors.secondary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notifications_outlined,
                  color: AppColors.primary, size: AppDimensions.iconM),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(notification.body, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(Formatters.relative(notification.createdAt),
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (!notification.isRead)
                const CircleAvatar(radius: 4, backgroundColor: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }
}
