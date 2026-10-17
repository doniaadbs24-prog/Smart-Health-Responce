import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';

class CurrentCaseCard extends StatelessWidget {
  final String patientName;
  final String status;
  final VoidCallback? onTap;

  const CurrentCaseCard({
    super.key,
    required this.patientName,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Text(
                  AppStrings.theOffer,
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(patientName, style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(status, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
