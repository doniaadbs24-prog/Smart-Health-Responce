import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingHuge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.paddingL),
            Text(title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.paddingS),
              Text(subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
