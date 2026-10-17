import 'package:latlong2/latlong.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Smart Health Response';
  static const String appShortName = 'SHR';
  static const String appVersion = '1.0.0';

  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.shr.smart_health_response';
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // Self-hosted Flask file server. Firestore stores only the relative path
  // returned by the server; clients prepend this base URL on read.
  static const String apiBaseUrl = 'http://10.10.9.246:5000';

  static const LatLng defaultMapCenter = LatLng(16.8892, 42.5611);
  static const double defaultZoom = 13.0;

  static const double initialAlertRadiusKm = 5.0;
  static const double expandedAlertRadiusKm = 10.0;
  static const Duration alertAcceptanceTimeout = Duration(seconds: 60);
  static const Duration alertExpansionTimeout = Duration(minutes: 5);
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  static const Duration mockNetworkLatency = Duration(milliseconds: 600);

  static const String supportEmail = 'support@shr.com';
  static const String supportPhone = '+966 50 123 4567';
}
