import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class ReportRepository {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  Stream<List<ReportModel>> pendingReports() => _firestore.pendingReportsStream();
  Stream<List<ReportModel>> reviewedReports() => _firestore.reviewedReportsStream();
  Stream<List<ReportModel>> userReports(String uid) => _firestore.userReportsStream(uid);

  Future<String?> createReport({
    required String userId,
    required String userName,
    required String userAvatar,
    required File? photoFile,
    required double latitude,
    required double longitude,
    required String address,
    required String neighborhood,
    required String description,
    required String severity,
    required bool anonymous,
  }) async {
    try {
      final reportId = _uuid.v4();

      String photoUrl = '';
      if (photoFile != null) {
        photoUrl = await _storage.uploadReportPhoto(
              userId: userId,
              reportId: reportId,
              file: photoFile,
            ) ??
            '';
      }

      final report = ReportModel(
        id: reportId,
        userId: userId,
        userName: anonymous ? 'Vecino anónimo' : userName,
        userAvatar: anonymous ? '' : userAvatar,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
        address: address,
        neighborhood: neighborhood,
        description: description,
        severity: severity,
        status: AppConstants.statusPending,
        confirmations: 0,
        comments: 0,
        anonymous: anonymous,
        createdAt: Timestamp.now(),
      );

      await _firestore.createReport(report);
      await _firestore.incrementReportsCount(userId);
      return null;
    } catch (e) {
      return 'Error al publicar el reporte: $e';
    }
  }

  Future<void> confirmReport(String reportId) async {
    await _firestore.confirmReport(reportId);
  }
}
