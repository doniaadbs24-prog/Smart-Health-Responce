import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/cards/case_card.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/layout/empty_state.dart';
import '../../widgets/layout/section_header.dart';

class ResponderDashboardScreen extends StatefulWidget {
  const ResponderDashboardScreen({super.key});

  @override
  State<ResponderDashboardScreen> createState() => _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.userId;
      if (uid != null) {
        context.read<ResponderProvider>().load(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResponderProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.responderProfile),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingS),
            child: Row(
              children: [
                Text(p.isAvailable ? 'On' : 'Off',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: p.isAvailable ? AppColors.success : AppColors.textSecondary,
                    )),
                Switch(
                  value: p.isAvailable,
                  onChanged: (_) => context.read<ResponderProvider>().toggleAvailability(),
                  activeThumbColor: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final uid = context.read<AuthProvider>().currentUser?.userId;
                if (uid != null) await context.read<ResponderProvider>().load(uid);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                children: [
                  Text('Welcome, ${user?.fullName.split(' ').first ?? 'Responder'}',
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          icon: Icons.medical_services_outlined,
                          label: 'Active',
                          value: '${p.activeCases.length}',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: StatTile(
                          icon: Icons.notifications_active_outlined,
                          label: 'Alerts',
                          value: '${p.nearbyAlerts.length}',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: StatTile(
                          icon: Icons.star_rounded,
                          label: 'Rating',
                          value: (p.profile?.averageRating ?? 0).toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                  const SectionHeader(title: 'Nearby Alerts'),
                  if (p.nearbyAlerts.isEmpty)
                    const EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No alerts',
                      subtitle: 'New emergencies will appear here.',
                    )
                  else
                    ...p.nearbyAlerts.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                          child: CaseCard(
                            emergencyCase: c,
                            onTap: () => context.push(AppRoutes.alertNotification, extra: c),
                          ),
                        )),
                  const SectionHeader(title: 'My Active Cases'),
                  if (p.activeCases.isEmpty)
                    const EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No active cases',
                    )
                  else
                    ...p.activeCases.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                          child: CaseCard(
                            emergencyCase: c,
                            onTap: () => context.push(AppRoutes.caseTrackDetails, extra: c),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
