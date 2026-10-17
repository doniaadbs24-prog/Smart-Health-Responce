import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../utils/extensions.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          _Tile(
            icon: Icons.backup_outlined,
            title: 'Backup Now',
            subtitle: 'Last backup 2 days ago',
            onTap: () => context.showSnack('Backup started'),
          ),
          _Tile(
            icon: Icons.restore_outlined,
            title: 'Restore from Backup',
            onTap: () => context.showSnack('Restore wizard'),
          ),
          _Tile(
            icon: Icons.archive_outlined,
            title: 'Archive Old Cases',
            subtitle: 'Cases older than 1 year',
            onTap: () => context.showSnack('Archived 12 cases'),
          ),
          _Tile(
            icon: Icons.delete_outline,
            title: 'GDPR Deletion Request',
            destructive: true,
            onTap: () => context.showSnack('Form opened'),
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
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
