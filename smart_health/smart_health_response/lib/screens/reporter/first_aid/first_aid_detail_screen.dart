import 'package:flutter/material.dart';
import '../../../core/configuration/colors.dart';
import '../../../core/configuration/dimensions.dart';
import '../../../core/configuration/text_styles.dart';
import '../../../models/first_aid_guide_model.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final FirstAidGuide guide;
  const FirstAidDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Text(guide.description,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          if (guide.warnings.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingL),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text('Warnings', style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  ...guide.warnings.map((w) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('• $w', style: AppTextStyles.bodyMedium),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.paddingXL),
          Text('Steps', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppDimensions.paddingM),
          ...guide.steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text('${s.stepNumber}',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: AppDimensions.paddingL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.stepTitle, style: AppTextStyles.titleMedium),
                            const SizedBox(height: 4),
                            Text(s.stepDescription,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          if (guide.emergencyHotline.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingL),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk_outlined, color: AppColors.error),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Hotline', style: AppTextStyles.titleSmall),
                        Text(guide.emergencyHotline,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
