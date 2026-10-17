import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusKm = 6371.0;
  static final Distance _distance = const Distance();

  static double haversineKm(LatLng a, LatLng b) {
    final dLat = _toRad(b.latitude - a.latitude);
    final dLon = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);

    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return _earthRadiusKm * c;
  }

  static double meters(LatLng a, LatLng b) => _distance.as(LengthUnit.Meter, a, b);

  static double _toRad(double deg) => deg * pi / 180.0;

  static int estimatedMinutes(double distanceKm, {double avgSpeedKmh = 40.0}) {
    if (distanceKm <= 0) return 0;
    return (distanceKm / avgSpeedKmh * 60).round();
  }
}
