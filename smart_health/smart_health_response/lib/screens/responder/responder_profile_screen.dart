import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/responder_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/status/rating_stars.dart';

class ResponderProfileScreen extends StatelessWidget {
  const ResponderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final p = context.watch<ResponderProvider>().profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Responder Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Text((user?.fullName ?? 'R').initials,
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(user?.fullName ?? 'Responder', style: AppTextStyles.titleLarge),
                if (user?.email != null && user!.email.isNotEmpty)
                  Text(user.email, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingStars(rating: p?.averageRating ?? 0),
                    const SizedBox(width: 8),
                    Text((p?.averageRating ?? 0).toStringAsFixed(1),
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          _StatRow('Cases responded', '${p?.totalCasesResponded ?? 0}'),
          _StatRow('Success rate', '${(p?.successRate ?? 0).toStringAsFixed(0)}%'),
          _StatRow('Avg response time', '${(p?.responseTime ?? 0).toStringAsFixed(1)} min'),
          _StatRow('Qualification', p?.qualificationLevel.name ?? '—'),
          _StatRow('Specializations', (p?.specializations ?? []).join(', ')),
          const SizedBox(height: AppDimensions.paddingXL),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: Text('Settings', style: AppTextStyles.titleSmall),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => context.push(AppRoutes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: AppColors.error),
            title: Text('Sign Out',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
          Text(value.isEmpty ? '—' : value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }
}

