import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          _Tile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push(AppRoutes.notifications)),
          _Tile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push(AppRoutes.settings)),
          _Tile(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              onTap: () => context.push(AppRoutes.feedback)),
          _Tile(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () => context.push(AppRoutes.help)),
          _Tile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => context.push(AppRoutes.about)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.titleSmall),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}
