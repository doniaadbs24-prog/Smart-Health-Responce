import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/configuration/colors.dart';

class MapMarkers {
  MapMarkers._();

  static Marker incident(LatLng point) => Marker(
        point: point,
        width: 40,
        height: 40,
        child: const _Pin(color: AppColors.error, icon: Icons.warning_amber_rounded),
      );

  static Marker responder(LatLng point) => Marker(
        point: point,
        width: 40,
        height: 40,
        child: const _Pin(color: AppColors.primary, icon: Icons.local_hospital_rounded),
      );

  static Marker facility(LatLng point) => Marker(
        point: point,
        width: 40,
        height: 40,
        child: const _Pin(color: AppColors.accent, icon: Icons.local_hospital_outlined),
      );

  static Marker reporter(LatLng point) => Marker(
        point: point,
        width: 40,
        height: 40,
        child: const _Pin(color: AppColors.info, icon: Icons.person_pin_circle_rounded),
      );

  static Marker aed(LatLng point) => Marker(
        point: point,
        width: 36,
        height: 36,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('AED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              )),
        ),
      );
}

class _Pin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _Pin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
