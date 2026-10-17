import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/cards/feature_card.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.howItWorks)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Text(
            'Smart Health Response works in three simple steps:',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          FeatureCard(
            icon: Icons.phone_in_talk_outlined,
            title: '1. ${AppStrings.quickAlertTitle}',
            description: AppStrings.quickAlertDesc,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          FeatureCard(
            icon: Icons.people_outline,
            title: '2. ${AppStrings.instantResponseTitle}',
            description: AppStrings.instantResponseDesc,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          FeatureCard(
            icon: Icons.local_hospital_outlined,
            title: '3. ${AppStrings.medicalFacilitiesTitle}',
            description: AppStrings.medicalFacilitiesDesc,
          ),
        ],
      ),
    );
  }
}
