import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/enums.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  void _select(BuildContext context, UserRole role) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.selectRole)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.selectRoleSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              _RoleCard(
                icon: Icons.warning_amber_outlined,
                title: 'Reporter',
                desc: 'Report emergencies and request help quickly.',
                onTap: () => _select(context, UserRole.reporter),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _RoleCard(
                icon: Icons.medical_services_outlined,
                title: 'Responder',
                desc: 'Volunteer to respond to nearby emergency cases.',
                onTap: () => _select(context, UserRole.responder),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _RoleCard(
                icon: Icons.local_hospital_outlined,
                title: 'Receiving Facility',
                desc: 'Receive incoming patients at your hospital.',
                onTap: () => _select(context, UserRole.facility),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _RoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Administrator',
                desc: 'Oversee the system, users, and facilities.',
                onTap: () => _select(context, UserRole.admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
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
              BoxShadow(color: AppColors.shadow, blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.iconL,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      desc,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
