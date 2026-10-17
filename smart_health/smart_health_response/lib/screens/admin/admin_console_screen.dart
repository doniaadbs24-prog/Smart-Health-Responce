import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/layout/section_header.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminConsole),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.adminProfile),
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<AdminProvider>().loadAll(),
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                children: [
                  Text('System Overview', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    children: [
                      Expanded(child: StatTile(icon: Icons.people_outline, label: 'Users', value: '${p.users.length}')),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(child: StatTile(icon: Icons.medical_services_outlined, label: 'Responders', value: '${p.responders.length}')),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      Expanded(child: StatTile(icon: Icons.local_hospital_outlined, label: 'Facilities', value: '${p.facilities.length}')),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(child: StatTile(icon: Icons.warning_amber_outlined, label: 'Cases', value: '${p.allCases.length}')),
                    ],
                  ),
                  const SectionHeader(title: 'Management'),
                  _AdminTile(icon: Icons.people_outline, title: 'Manage Users', onTap: () => context.push(AppRoutes.manageUsers)),
                  _AdminTile(icon: Icons.medical_services_outlined, title: 'Manage Responders', onTap: () => context.push(AppRoutes.manageResponders)),
                  _AdminTile(icon: Icons.person_outline, title: 'Manage Reporters', onTap: () => context.push(AppRoutes.manageReporters)),
                  _AdminTile(icon: Icons.local_hospital_outlined, title: 'Manage Facilities', onTap: () => context.push(AppRoutes.manageFacilities)),
                  _AdminTile(icon: Icons.favorite_outline, title: 'Manage AEDs', onTap: () => context.push(AppRoutes.manageAEDs)),
                  _AdminTile(icon: Icons.assignment_outlined, title: 'Manage Cases', onTap: () => context.push(AppRoutes.manageCases)),
                  _AdminTile(icon: Icons.menu_book_outlined, title: 'Manage First Aid Guides', onTap: () => context.push(AppRoutes.manageFirstAid)),
                  const SectionHeader(title: 'Tools'),
                  _AdminTile(icon: Icons.map_outlined, title: 'Live Incident Map', onTap: () => context.push(AppRoutes.liveIncidentMap)),
                  _AdminTile(icon: Icons.history_outlined, title: 'System Activity Log', onTap: () => context.push(AppRoutes.systemLog)),
                  _AdminTile(icon: Icons.bar_chart_outlined, title: 'Reports', onTap: () => context.push(AppRoutes.reports)),
                  _AdminTile(icon: Icons.campaign_outlined, title: 'Emergency Broadcast', onTap: () => context.push(AppRoutes.emergencyBroadcast)),
                  _AdminTile(icon: Icons.storage_outlined, title: 'Data Management', onTap: () => context.push(AppRoutes.dataManagement)),
                ],
              ),
            ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _AdminTile({required this.icon, required this.title, required this.onTap});

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
