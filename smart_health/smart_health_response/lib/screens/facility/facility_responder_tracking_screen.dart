import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../core/constants/enums.dart';
import '../../providers/facility_provider.dart';
import '../../widgets/layout/empty_state.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';
import '../../widgets/status/eta_widget.dart';

class FacilityResponderTrackingScreen extends StatelessWidget {
  const FacilityResponderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FacilityProvider>();
    final incoming = p.incomingCases;
    final current = p.currentCases;
    final facilityLocation =
        p.facility?.location.toLatLng() ?? AppConfig.defaultMapCenter;

    // Build markers from real case data.
    final markers = <Marker>[
      MapMarkers.facility(facilityLocation),
    ];
    for (final c in incoming) {
      markers.add(MapMarkers.incident(c.incidentLocation.toLatLng()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Responders')),
      body: incoming.isEmpty && current.isEmpty
          ? const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No active tracking',
              subtitle: 'Incoming cases will appear on the map.',
            )
          : Column(
              children: [
                Expanded(
                  child: OsmMapWidget(
                    center: facilityLocation,
                    markers: markers,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          EtaWidget(
                            minutes: incoming.isEmpty ? 0 : 5,
                            label: 'Closest ETA',
                          ),
                          const SizedBox(width: AppDimensions.paddingL),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${incoming.length} incoming patient${incoming.length == 1 ? '' : 's'}',
                                  style: AppTextStyles.titleSmall,
                                ),
                                Text(
                                  '${current.length} in treatment',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (incoming.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingM),
                        const Divider(),
                        ...incoming.map(
                          (c) => ListTile(
                            dense: true,
                            leading: Icon(
                              _iconForStatus(c.caseStatus),
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: Text(
                              c.incidentType.label,
                              style: AppTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              c.patientName ?? 'Unknown',
                              style: AppTextStyles.caption,
                            ),
                            trailing: Text(
                              c.caseStatus.label,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _iconForStatus(CaseStatus status) {
    switch (status) {
      case CaseStatus.responderAssigned:
        return Icons.directions_run_outlined;
      case CaseStatus.inProgress:
        return Icons.local_shipping_outlined;
      case CaseStatus.handoverStarted:
        return Icons.swap_horiz_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
