import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';

class EmergencyAccessBeforeScreen extends StatelessWidget {
  const EmergencyAccessBeforeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Access')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingHuge),
              const Icon(Icons.shield_outlined, color: AppColors.error, size: 80),
              const SizedBox(height: AppDimensions.paddingL),
              Text('Emergency Access',
                  style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Use this only in a real emergency. Your location will be shared with the nearest responder.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Enter Emergency Mode',
                icon: Icons.warning_amber_rounded,
                onPressed: () async {
                  await context.read<AuthProvider>().emergencyAccess();
                  if (!context.mounted) return;
                  context.go(AppRoutes.emergencyAccess);
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              OutlinedAppButton(label: 'Cancel', onPressed: () => context.pop()),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }
}
