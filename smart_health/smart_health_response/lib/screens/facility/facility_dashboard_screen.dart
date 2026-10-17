import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/enums.dart';
import '../../core/configuration/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/facility_provider.dart';
import '../../widgets/cards/current_case_card.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/cards/upcoming_case_card.dart';
import '../../widgets/layout/section_header.dart';

class FacilityDashboardScreen extends StatefulWidget {
  const FacilityDashboardScreen({super.key});

  @override
  State<FacilityDashboardScreen> createState() => _FacilityDashboardScreenState();
}

class _FacilityDashboardScreenState extends State<FacilityDashboardScreen> {
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.userId;
      if (uid != null) {
        context.read<FacilityProvider>().load(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FacilityProvider>();
    final upcoming = p.incomingCases.firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(p.facility?.facilityName ?? 'Facility')),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final uid = context.read<AuthProvider>().currentUser?.userId;
                if (uid != null) await context.read<FacilityProvider>().load(uid);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                children: [
                  const SectionHeader(title: AppStrings.upcomingCases),
                  if (upcoming != null)
                    UpcomingCaseCard(
                      patientName: upcoming.patientName ?? 'Unknown patient',
                      etaMinutes: 5,
                      onShow: () => context.push(AppRoutes.incomingCase, extra: upcoming),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Text('No upcoming cases',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  const SectionHeader(title: AppStrings.currentCases),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Column(
                      children: [
                        ...p.currentCases.map((c) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingM),
                              child: CurrentCaseCard(
                                patientName: c.patientName ?? 'Patient',
                                status: c.caseStatus == CaseStatus.inTreatment
                                    ? AppStrings.underTreatment
                                    : AppStrings.received,
                                onTap: () => context.push(
                                    AppRoutes.caseStatusUpdate,
                                    extra: c),
                              ),
                            )),
                        if (p.currentCases.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingL),
                            child: Text('No current cases',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: AppStrings.facilityCases),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          icon: Icons.favorite_outline,
                          label: AppStrings.aed,
                          value: '${p.aedCount}',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: StatTile(
                          icon: Icons.bed_outlined,
                          label: AppStrings.numberOfBeds,
                          value: '${p.availableBeds}',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: StatTile(
                          icon: Icons.show_chart_outlined,
                          label: AppStrings.availabilityCases,
                          value: p.isAvailable ? AppStrings.available : 'Full',
                          valueColor: p.isAvailable ? AppColors.accent : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0:
              context.push(AppRoutes.facilityProfile);
              break;
            case 1:
              context.push(AppRoutes.facilityResponderTracking);
              break;
            case 2:
              context.push(AppRoutes.facilityReports);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_outlined), label: AppStrings.facility),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined), label: AppStrings.tracking),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined), label: AppStrings.cases),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: AppStrings.home),
        ],
      ),
    );
  }
}
