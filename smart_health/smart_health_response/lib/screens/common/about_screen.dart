import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: const Icon(Icons.favorite, color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(AppStrings.appShortName, style: AppTextStyles.headlineMedium),
            Text(AppStrings.appName, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: AppTextStyles.caption),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(
              'Smart Health Response connects witnesses, trained responders, hospitals and administrators in a unified emergency-response ecosystem.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
