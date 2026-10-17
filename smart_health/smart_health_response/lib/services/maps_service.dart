import '../core/configuration/app_config.dart';

class MapsService {
  String tileUrl() => AppConfig.osmTileUrl;
  String userAgent() => AppConfig.osmUserAgent;
}
