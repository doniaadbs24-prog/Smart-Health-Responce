import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          _Tile(icon: Icons.person_outline, title: 'Account', onTap: () {}),
          _Tile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push(AppRoutes.notifications)),
          _Tile(icon: Icons.lock_outline, title: 'Privacy', onTap: () {}),
          _Tile(icon: Icons.language_outlined, title: 'Language', subtitle: 'English'),
          _Tile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => context.push(AppRoutes.about)),
          _Tile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => context.push(AppRoutes.help)),
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
  final bool destructive;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
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
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}
