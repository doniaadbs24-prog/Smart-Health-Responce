import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';

class ReceivingCaseScreen extends StatelessWidget {
  const ReceivingCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receiving Case')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, color: AppColors.primary, size: 96),
              const SizedBox(height: AppDimensions.paddingL),
              Text('Receiving the Case', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'You are receiving a new emergency case. Review details and accept to begin response.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.caseDetails),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Case Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
