import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../models/emergency_case_model.dart';
import '../../utils/formatters.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';
import '../../widgets/status/eta_widget.dart';

class IncomingCaseScreen extends StatelessWidget {
  final EmergencyCase emergencyCase;
  const IncomingCaseScreen({super.key, required this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final loc = emergencyCase.incidentLocation.toLatLng();
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Case')),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: OsmMapWidget(
              center: loc,
              markers: [MapMarkers.incident(loc), MapMarkers.responder(loc)],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          emergencyCase.patientName ?? 'Incoming patient',
                          style: AppTextStyles.titleLarge,
                        ),
                      ),
                      const EtaWidget(minutes: 5),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergencyCase.incidentType.label,
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    'Reported ${Formatters.relative(emergencyCase.createdAt)}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Responder', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Ahmed Khalid · CPR Expert',
                          style: AppTextStyles.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedAppButton(
                          label: 'Message',
                          icon: Icons.chat_outlined,
                          onPressed: () =>
                              context.push(AppRoutes.facilityCommunication),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Confirm Reception',
                          onPressed: () => context.push(
                            AppRoutes.patientReception,
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
