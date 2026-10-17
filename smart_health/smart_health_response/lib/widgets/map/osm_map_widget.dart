import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/configuration/app_config.dart';
import '../../core/configuration/dimensions.dart';

class OsmMapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final MapController? controller;
  final void Function(TapPosition, LatLng)? onTap;
  final bool interactive;

  const OsmMapWidget({
    super.key,
    required this.center,
    this.zoom = AppConfig.defaultZoom,
    this.markers = const [],
    this.polylines = const [],
    this.controller,
    this.onTap,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          onTap: onTap,
          interactionOptions: InteractionOptions(
            flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: AppConfig.osmTileUrl,
            userAgentPackageName: AppConfig.osmUserAgent,
          ),
          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
