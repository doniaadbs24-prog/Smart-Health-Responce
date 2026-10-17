import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';
import '../../widgets/status/eta_widget.dart';
import '../../widgets/status/status_chip.dart';

class CaseTrackDetailsScreen extends StatelessWidget {
  final EmergencyCase emergencyCase;
  const CaseTrackDetailsScreen({super.key, required this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final loc = emergencyCase.incidentLocation.toLatLng();
    return Scaffold(
      appBar: AppBar(title: const Text('Case Tracking')),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: OsmMapWidget(
              center: loc,
              markers: [MapMarkers.incident(loc)],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          emergencyCase.patientName ?? 'Patient',
                          style: AppTextStyles.titleLarge,
                        ),
                      ),
                      StatusChip(label: emergencyCase.caseStatus.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emergencyCase.incidentType.label,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  const Row(children: [EtaWidget(minutes: 6)]),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedAppButton(
                          label: 'Protocol',
                          icon: Icons.medical_services_outlined,
                          onPressed: () => context.push(
                            AppRoutes.medicalProtocol,
                            extra: emergencyCase,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Handover',
                          icon: Icons.handshake_outlined,
                          onPressed: () => context.push(
                            AppRoutes.handover,
                            extra: emergencyCase,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
