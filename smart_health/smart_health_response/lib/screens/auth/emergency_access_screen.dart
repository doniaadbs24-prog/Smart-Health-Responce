import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../widgets/buttons/sos_button.dart';

class EmergencyAccessScreen extends StatelessWidget {
  const EmergencyAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Emergency Mode')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tap to send emergency alert',
                    style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.paddingHuge),
                SosButton(onPressed: () => context.go(AppRoutes.sosAlert)),
                const SizedBox(height: AppDimensions.paddingHuge),
                Text(
                  'Your location will be shared automatically.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
