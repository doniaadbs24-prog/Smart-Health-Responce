import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/status/status_chip.dart';

class CaseDetailsScreen extends StatelessWidget {
  final EmergencyCase? emergencyCase;
  const CaseDetailsScreen({super.key, this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case Details')),
      body: emergencyCase == null
          ? const Center(child: Text('No case selected'))
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(emergencyCase!.incidentType.label,
                          style: AppTextStyles.headlineSmall),
                    ),
                    StatusChip(label: emergencyCase!.caseStatus.label),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text('Created ${Formatters.relative(emergencyCase!.createdAt)}',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: AppDimensions.paddingXL),
                _Field(label: 'Patient', value: emergencyCase!.patientName ?? 'Unknown'),
                _Field(
                    label: 'Location',
                    value:
                        '${emergencyCase!.incidentLocation.latitude.toStringAsFixed(4)}, ${emergencyCase!.incidentLocation.longitude.toStringAsFixed(4)}'),
                _Field(label: 'Description', value: emergencyCase!.description),
                if (emergencyCase!.emergencyContactPhone != null)
                  _Field(
                      label: 'Emergency Contact',
                      value: emergencyCase!.emergencyContactPhone!),
                // ── Attachments ──────────────────────────────
                if (emergencyCase!.attachments.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  Text('Attachments', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimensions.paddingS),
                  ...emergencyCase!.attachments.map((a) {
                    if (a.attachmentType == AttachmentType.photo) {
                      final url =
                          '${AppConfig.apiBaseUrl}${a.attachmentURL}';
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingM),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM),
                          child: Image.network(
                            url,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 100,
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.textTertiary),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.paddingM),
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.audiotrack_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Voice recording',
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      );
                    }
                  }),
                ],
                const SizedBox(height: AppDimensions.paddingXL),
                PrimaryButton(
                  label: 'Open Navigation',
                  icon: Icons.navigation_outlined,
                  onPressed: () =>
                      context.push(AppRoutes.navigationToCase, extra: emergencyCase),
                ),
              ],
            ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
