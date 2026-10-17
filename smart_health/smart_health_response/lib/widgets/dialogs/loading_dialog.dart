import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, this.message = 'Please wait...'});

  static Future<void> show(BuildContext context, {String message = 'Please wait...'}) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(message: message),
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
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppDimensions.paddingL),
            Text(message, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
