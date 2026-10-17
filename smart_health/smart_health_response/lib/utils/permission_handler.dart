import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  AppPermissions._();

  static Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationAlways() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<Map<Permission, PermissionStatus>> requestAll() {
    return [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ].request();
  }
}
