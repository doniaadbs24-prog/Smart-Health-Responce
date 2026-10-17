import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../buttons/primary_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const ErrorDialog({super.key, this.title = 'Error', required this.message});

  static Future<void> show(BuildContext context, String message,
          {String title = 'Error'}) =>
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(title: title, message: message),
      );

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
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 56),
            const SizedBox(height: AppDimensions.paddingL),
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimensions.paddingS),
            Text(message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(label: 'OK', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
