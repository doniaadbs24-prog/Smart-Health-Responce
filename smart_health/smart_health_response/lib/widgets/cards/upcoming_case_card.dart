import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../buttons/primary_button.dart';

class UpcomingCaseCard extends StatelessWidget {
  final String patientName;
  final int etaMinutes;
  final VoidCallback? onShow;

  const UpcomingCaseCard({
    super.key,
    required this.patientName,
    required this.etaMinutes,
    this.onShow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            color: AppColors.primary,
            child: Text(
              AppStrings.patientName,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.paddingS),
                Text('${AppStrings.eta} : After $etaMinutes minutes',
                    style: AppTextStyles.titleSmall),
                const SizedBox(height: AppDimensions.paddingL),
                Center(
                  child: SizedBox(
                    width: 240,
                    child: PrimaryButton(label: AppStrings.showCases, onPressed: onShow),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
