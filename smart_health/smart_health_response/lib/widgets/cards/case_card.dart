import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../utils/formatters.dart';
import '../status/status_chip.dart';

class CaseCard extends StatelessWidget {
  final EmergencyCase emergencyCase;
  final VoidCallback? onTap;
  final String? trailing;

  const CaseCard({
    super.key,
    required this.emergencyCase,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Icon(_iconFor(emergencyCase.incidentType),
                        color: AppColors.primary, size: AppDimensions.iconM),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emergencyCase.patientName ?? 'Anonymous patient',
                            style: AppTextStyles.titleSmall),
                        Text(emergencyCase.incidentType.label,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  StatusChip(label: emergencyCase.caseStatus.label),
                ],
              ),
              if (emergencyCase.description.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Text(emergencyCase.description,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  const Icon(Icons.access_time, size: AppDimensions.iconS, color: AppColors.textTertiary),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(Formatters.relative(emergencyCase.createdAt),
                      style: AppTextStyles.caption),
                  const Spacer(),
                  if (trailing != null)
                    Text(trailing!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(IncidentType t) {
    switch (t) {
      case IncidentType.cardiacArrest:
        return Icons.monitor_heart_outlined;
      case IncidentType.trafficAccident:
        return Icons.car_crash_outlined;
      case IncidentType.severeBleed:
        return Icons.bloodtype_outlined;
      case IncidentType.choking:
        return Icons.air_outlined;
      case IncidentType.burns:
        return Icons.local_fire_department_outlined;
      case IncidentType.breathingDifficulty:
        return Icons.air_outlined;
      case IncidentType.other:
        return Icons.medical_services_outlined;
    }
  }
}
