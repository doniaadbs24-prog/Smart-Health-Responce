import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/extensions.dart';

class ReporterProfileScreen extends StatelessWidget {
  const ReporterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                    (user?.fullName ?? 'U').initials,
                    style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(user?.fullName ?? 'User', style: AppTextStyles.titleLarge),
                Text(user?.email ?? '', style: AppTextStyles.bodySmall),
                if (user?.phoneNumber != null && user!.phoneNumber.isNotEmpty)
                  Text(user.phoneNumber, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          _Tile(icon: Icons.contacts_outlined, title: 'Emergency Contacts'),
          _Tile(icon: Icons.bloodtype_outlined, title: 'Medical Profile'),
          _Tile(
            icon: Icons.history_outlined,
            title: 'Case History',
            onTap: () => context.push(AppRoutes.caseHistory),
          ),
          _Tile(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            onTap: () => context.push(AppRoutes.notifications),
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _Tile(
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title,
            style: AppTextStyles.titleSmall.copyWith(color: destructive ? AppColors.error : null)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      ),
    );
  }
}
