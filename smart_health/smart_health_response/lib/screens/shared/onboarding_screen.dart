import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/feature_card.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.paddingL),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 12),
                  ],
                ),
                child: const Icon(Icons.favorite, color: AppColors.primary, size: 64),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(AppStrings.appShortName, style: AppTextStyles.displayMedium),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                AppStrings.tagline,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: AppStrings.createAccount,
                      onPressed: () => context.push(AppRoutes.createAccount),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: SecondaryButton(
                      label: AppStrings.signIn,
                      onPressed: () => context.push(AppRoutes.login),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              SizedBox(
                width: 240,
                child: OutlinedAppButton(
                  label: AppStrings.emergencyAccess,
                  onPressed: () => context.push(AppRoutes.emergencyAccessBefore),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Text(AppStrings.howItWorks, style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppDimensions.paddingL),
              FeatureCard(
                icon: Icons.phone_in_talk_outlined,
                title: AppStrings.quickAlertTitle,
                description: AppStrings.quickAlertDesc,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              FeatureCard(
                icon: Icons.people_outline,
                title: AppStrings.instantResponseTitle,
                description: AppStrings.instantResponseDesc,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              FeatureCard(
                icon: Icons.local_hospital_outlined,
                title: AppStrings.medicalFacilitiesTitle,
                description: AppStrings.medicalFacilitiesDesc,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.needHelp, style: AppTextStyles.titleSmall),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.firstAidList),
                    child: Text(
                      AppStrings.viewFirstAidGuide,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppStrings.contactUs, style: AppTextStyles.titleSmall),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              const _ContactRow(icon: Icons.phone_outlined, text: '+966 50 123 4567'),
              const _ContactRow(icon: Icons.mail_outline, text: 'support@SHR.com'),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconM, color: AppColors.primary),
          const SizedBox(width: AppDimensions.paddingM),
          Text(text, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
