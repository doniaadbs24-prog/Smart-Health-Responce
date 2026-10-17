import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/emergency_case_model.dart';
import '../../widgets/buttons/primary_button.dart';

class MedicalProtocolScreen extends StatelessWidget {
  final EmergencyCase? emergencyCase;
  const MedicalProtocolScreen({super.key, this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      ('Ensure scene safety',
          'Confirm there are no immediate hazards before approaching the patient.'),
      ('Assess responsiveness',
          'Tap shoulder and shout. Check breathing for no more than 10 seconds.'),
      ('Begin compressions',
          'Place hands on chest center. Push hard, push fast at 100-120/min.'),
      ('Provide rescue breaths', 'Tilt head, lift chin, deliver 2 breaths after 30 compressions.'),
      ('Use AED if available', 'Follow AED prompts. Resume CPR immediately after shock.'),
      ('Continue until help arrives', 'Maintain CPR until EMS takes over or patient revives.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Protocol')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Row(
              children: [
                const Icon(Icons.priority_high_rounded, color: AppColors.error),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text('CPR Protocol — Cardiac Arrest',
                      style: AppTextStyles.titleMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${e.key + 1}',
                            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.$1, style: AppTextStyles.titleSmall),
                            const SizedBox(height: 4),
                            Text(e.value.$2,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppDimensions.paddingL),
          PrimaryButton(
            label: 'Start Handover',
            icon: Icons.handshake_outlined,
            onPressed: () => context.push(AppRoutes.handover, extra: emergencyCase),
          ),
        ],
      ),
    );
  }
}
