import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/sos_button.dart';
import '../../widgets/cards/feature_card.dart';
import '../../widgets/layout/section_header.dart';

class ReporterDashboardScreen extends StatelessWidget {
  const ReporterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Health Response'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, ${user?.fullName.split(' ').first ?? 'there'}',
                  style: AppTextStyles.headlineMedium),
              Text('Stay safe and connected.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.paddingHuge),
              Center(
                child: SosButton(
                  size: 220,
                  onPressed: () => context.push(AppRoutes.sosAlert),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Center(
                child: Text('Tap to send emergency alert',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              const SectionHeader(title: 'Quick Access'),
              FeatureCard(
                icon: Icons.medical_information_outlined,
                title: 'First Aid Guides',
                description: 'CPR, choking, bleeding, burns, shock',
                onTap: () => context.push(AppRoutes.firstAidList),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              FeatureCard(
                icon: Icons.history_outlined,
                title: 'Case History',
                description: 'View your past emergency cases',
                onTap: () => context.push(AppRoutes.caseHistory),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              FeatureCard(
                icon: Icons.person_outline,
                title: 'My Profile',
                description: 'Manage emergency contacts and medical info',
                onTap: () => context.push(AppRoutes.reporterProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
