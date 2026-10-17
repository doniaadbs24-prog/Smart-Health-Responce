import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/configuration/app_config.dart';
import '../core/errors/exceptions.dart';

class StorageService {
  Future<String> uploadProfilePhoto(String userId, File file) {
    return _upload(file, endpoint: '/upload/users/$userId/profile');
  }

  Future<String> uploadCertificate(
    String responderId,
    String certId,
    File file,
  ) {
    return _upload(
      file,
      endpoint: '/upload/responders/$responderId/certs/$certId',
    );
  }

  Future<String> uploadAttachment(
    String caseId,
    String attachmentId,
    File file,
  ) {
    return _upload(
      file,
      endpoint: '/upload/cases/$caseId/attachments/$attachmentId',
    );
  }

  Future<String> uploadFile(File file, String endpoint) => _upload(file, endpoint: endpoint);

  Future<void> deleteFile(String relativePath) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$relativePath');
    final res = await http.delete(uri);
    if (res.statusCode >= 400) {
      throw StorageException('Delete failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<String> _upload(File file, {required String endpoint}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw StorageException('Upload failed (${streamed.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    final relativePath = json['path'] as String?;
    if (relativePath == null || relativePath.isEmpty) {
      throw StorageException('Server response missing "path" field: $body');
    }
    return relativePath;
  }
}
