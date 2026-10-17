import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FileHelpers {
  FileHelpers._();

  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImageFromCamera() async {
    final x = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
    return x == null ? null : File(x.path);
  }

  static Future<File?> pickImageFromGallery() async {
    final x = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return x == null ? null : File(x.path);
  }

  static Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.first.path;
    return path == null ? null : File(path);
  }

  static String fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    return dot < 0 ? '' : path.substring(dot + 1).toLowerCase();
  }

  static String fileSizeReadable(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
