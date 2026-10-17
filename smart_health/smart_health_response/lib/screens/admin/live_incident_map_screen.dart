import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/geo_point_extensions.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/map/map_markers.dart';
import '../../widgets/map/osm_map_widget.dart';

class LiveIncidentMapScreen extends StatelessWidget {
  const LiveIncidentMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final List<Marker> markers = [
      ...p.allCases.map(
        (c) => MapMarkers.incident(c.incidentLocation.toLatLng()),
      ),
      ...p.facilities.map((f) => MapMarkers.facility(f.location.toLatLng())),
      ...p.aeds.map((a) => MapMarkers.aed(a.location.toLatLng())),
      ...p.responders
          .where((r) => r.currentLocation != null)
          .map((r) => MapMarkers.responder(r.currentLocation!.toLatLng())),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Live Incident Map')),
      body: OsmMapWidget(center: AppConfig.defaultMapCenter, markers: markers),
    );
  }
}
