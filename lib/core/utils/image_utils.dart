import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  ImageUtils._();

  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const int compressQuality = 85;
  static const int thumbnailSize = 256;

  static Future<File?> compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final compressed = img.encodeJpg(decoded, quality: compressQuality);
      final compressedFile = File(file.path)..writeAsBytesSync(compressed);
      return compressedFile;
    } catch (e) {
      debugPrint('ImageUtils.compressImage error: $e');
      return null;
    }
  }

  static Future<Uint8List?> resizeForClassification(File file, int size) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(decoded, width: size, height: size);
      return Uint8List.fromList(img.encodeJpg(resized));
    } catch (e) {
      debugPrint('ImageUtils.resizeForClassification error: $e');
      return null;
    }
  }

  static bool isFileSizeOk(File file) {
    return file.lengthSync() <= maxFileSizeBytes;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
