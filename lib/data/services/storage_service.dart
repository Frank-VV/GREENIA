import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadReportPhoto({
    required String userId,
    required String reportId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child('reports/$userId/$reportId.jpg');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadReportPhoto error: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child('avatars/$userId');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadAvatar error: $e');
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      debugPrint('StorageService.deleteFile error: $e');
    }
  }
}
