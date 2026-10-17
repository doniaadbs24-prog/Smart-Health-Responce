import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const StatusChip({super.key, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconXS, color: c),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: c)),
        ],
      ),
    );
  }
}
