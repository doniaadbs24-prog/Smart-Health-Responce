import '../core/configuration/app_config.dart';

String resolveFileUrl(String? storedPath) {
  if (storedPath == null || storedPath.isEmpty) return '';
  if (storedPath.startsWith('http://') || storedPath.startsWith('https://')) {
    return storedPath;
  }
  final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
  final path = storedPath.startsWith('/') ? storedPath : '/$storedPath';
  return '$base$path';
}
