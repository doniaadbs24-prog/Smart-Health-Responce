import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/facility_model.dart';

class FacilityCard extends StatelessWidget {
  final FacilityModel facility;
  final VoidCallback? onTap;

  const FacilityCard({super.key, required this.facility, this.onTap});

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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: AppColors.primary, size: AppDimensions.iconL),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(facility.facilityName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(facility.address, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Row(
                      children: [
                        const Icon(Icons.bed_outlined, size: AppDimensions.iconS, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text('${facility.availableBeds}/${facility.capacity} beds',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
