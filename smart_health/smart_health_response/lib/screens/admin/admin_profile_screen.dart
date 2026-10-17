import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/cards/stat_tile.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final p = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.fullName ?? 'A').initials,
                    style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(user?.fullName ?? 'Administrator', style: AppTextStyles.titleLarge),
                Text(user?.email ?? '', style: AppTextStyles.bodySmall),
                if (user?.phoneNumber != null && user!.phoneNumber.isNotEmpty)
                  Text(user.phoneNumber, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text('System Overview', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.people_outline,
                  label: 'Users',
                  value: '${p.users.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.warning_amber_outlined,
                  label: 'Cases',
                  value: '${p.allCases.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'Facilities',
                  value: '${p.facilities.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.medical_services_outlined,
                  label: 'Responders',
                  value: '${p.responders.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          const Divider(),
          _ActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _ActionTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push(AppRoutes.help),
          ),
          _ActionTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => context.push(AppRoutes.about),
          ),
          _ActionTile(
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            destructive: true,
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              context.go(AppRoutes.onboarding);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool destructive;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: AppTextStyles.titleSmall
                .copyWith(color: destructive ? AppColors.error : null)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}
