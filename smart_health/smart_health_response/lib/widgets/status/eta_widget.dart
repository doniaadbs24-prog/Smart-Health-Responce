import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class EtaWidget extends StatelessWidget {
  final int minutes;
  final String label;

  const EtaWidget({super.key, required this.minutes, this.label = 'ETA'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.accent, size: AppDimensions.iconM),
          const SizedBox(width: AppDimensions.paddingS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text('$minutes min', style: AppTextStyles.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
