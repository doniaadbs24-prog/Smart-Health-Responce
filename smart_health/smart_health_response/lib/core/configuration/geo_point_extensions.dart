import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

extension GeoPointX on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngX on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}
