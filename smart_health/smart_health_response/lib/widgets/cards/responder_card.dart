import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/responder_model.dart';
import '../../models/user_model.dart';
import '../../utils/extensions.dart';
import '../status/rating_stars.dart';

class ResponderCard extends StatelessWidget {
  final ResponderModel responder;
  final UserModel? user;
  final VoidCallback? onTap;

  const ResponderCard({super.key, required this.responder, this.user, this.onTap});

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
              CircleAvatar(
                radius: AppDimensions.avatarM / 2,
                backgroundColor: AppColors.primary,
                child: Text(
                  (user?.fullName ?? 'R').initials,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? 'Responder', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Row(
                      children: [
                        RatingStars(rating: responder.averageRating, size: 14),
                        const SizedBox(width: AppDimensions.paddingS),
                        Text('${responder.totalCasesResponded} cases',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: responder.isApproved ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                ),
                child: Text(
                  responder.isApproved ? 'Approved' : 'Pending',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: responder.isApproved ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
