import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/emergency_case_model.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';
import '../../widgets/status/eta_widget.dart';

class NavigationToCaseScreen extends StatelessWidget {
  final EmergencyCase? emergencyCase;
  const NavigationToCaseScreen({super.key, this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    final incident =
        emergencyCase?.incidentLocation.toLatLng() ??
        AppConfig.defaultMapCenter;
    final responder = LatLng(
      incident.latitude - 0.01,
      incident.longitude - 0.01,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Navigate to Case')),
      body: Column(
        children: [
          Expanded(
            child: OsmMapWidget(
              center: incident,
              markers: [
                MapMarkers.incident(incident),
                MapMarkers.responder(responder),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const EtaWidget(minutes: 8),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distance', style: AppTextStyles.caption),
                          Text('1.4 km', style: AppTextStyles.titleSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingL),
                PrimaryButton(
                  label: 'I have arrived',
                  icon: Icons.flag_outlined,
                  onPressed: () => context.push(
                    AppRoutes.medicalProtocol,
                    extra: emergencyCase,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
