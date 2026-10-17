import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../providers/responder_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';

class AlertNotificationScreen extends StatelessWidget {
  final EmergencyCase emergencyCase;
  const AlertNotificationScreen({super.key, required this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final loc = emergencyCase.incidentLocation.toLatLng();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Alert')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: OsmMapWidget(
                center: loc,
                markers: [MapMarkers.incident(loc)],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: 32,
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emergencyCase.incidentType.label,
                                  style: AppTextStyles.titleLarge,
                                ),
                                Text(
                                  Formatters.relative(emergencyCase.createdAt),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    Text('Description', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      emergencyCase.description.isEmpty
                          ? 'No description provided.'
                          : emergencyCase.description,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    if (emergencyCase.patientName != null) ...[
                      Text(
                        'Patient: ${emergencyCase.patientName}',
                        style: AppTextStyles.titleSmall,
                      ),
                    ],
                    // ── Attachments ──────────────────────────────
                    if (emergencyCase.attachments.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingL),
                      Text('Attachments', style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppDimensions.paddingS),
                      ...emergencyCase.attachments.map((a) {
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedAppButton(
                            label: AppStrings.reject,
                            color: AppColors.error,
                            onPressed: () => context.push(
                              AppRoutes.rejectReason,
                              extra: emergencyCase,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: PrimaryButton(
                            label: AppStrings.accept,
                            onPressed: () async {
                              await context
                                  .read<ResponderProvider>()
                                  .acceptAlert(emergencyCase.caseId);
                              if (!context.mounted) return;
                              context.go(
                                AppRoutes.navigationToCase,
                                extra: emergencyCase,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
