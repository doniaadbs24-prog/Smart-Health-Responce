import 'package:geolocator/geolocator.dart' hide PermissionDeniedException;
import 'package:latlong2/latlong.dart';
import '../core/configuration/app_config.dart';
import '../core/errors/exceptions.dart';

class LocationService {
  Future<LatLng> getCurrent() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return AppConfig.defaultMapCenter;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw PermissionDeniedException('Location permission denied');
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw PermissionDeniedException('Location permission permanently denied');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  Stream<LatLng> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((p) => LatLng(p.latitude, p.longitude));
  }
}
