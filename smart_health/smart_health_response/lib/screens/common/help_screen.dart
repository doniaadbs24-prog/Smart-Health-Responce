import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      ('How do I send an SOS?', 'Tap the red SOS button on your dashboard.'),
      ('Who responds to my alert?',
          'Approved responders within 5 km receive your alert and can accept it.'),
      ('Is my location shared?',
          'Yes, only with the assigned responder, hospital, and admin during the case.'),
      ('Can I cancel an SOS?',
          'Yes, contact your responder via chat or call to cancel.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          ...faqs.map((f) => Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$1, style: AppTextStyles.titleSmall),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(f.$2,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
