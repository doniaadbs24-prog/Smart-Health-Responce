import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../buttons/primary_button.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const SuccessDialog({
    super.key,
    this.title = 'Success',
    required this.message,
    this.buttonLabel = AppStrings.done,
  });

  static Future<void> show(BuildContext context,
      {String title = 'Success', required String message, String buttonLabel = AppStrings.done}) {
    return showDialog(
      context: context,
      builder: (_) => SuccessDialog(title: title, message: message, buttonLabel: buttonLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 56),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimensions.paddingS),
            Text(message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(
              label: buttonLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
