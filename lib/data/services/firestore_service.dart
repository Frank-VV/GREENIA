import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../models/schedule_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .update(data);
  }

  Future<void> incrementReportsCount(String uid) async {
    await _db
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .update({'reportsCount': FieldValue.increment(1)});
  }

  Future<void> incrementScansCount(String uid) async {
    await _db
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .update({'scansCount': FieldValue.increment(1)});
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  Future<String> createReport(ReportModel report) async {
    final ref = await _db
        .collection(AppConstants.collectionReports)
        .add(report.toFirestore());
    return ref.id;
  }

  Future<void> updateReport(String reportId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.collectionReports)
        .doc(reportId)
        .update(data);
  }

  Stream<List<ReportModel>> pendingReportsStream() {
    return _db
        .collection(AppConstants.collectionReports)
        .where('status', isEqualTo: AppConstants.statusPending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ReportModel.fromFirestore).toList());
  }

  Stream<List<ReportModel>> reviewedReportsStream() {
    return _db
        .collection(AppConstants.collectionReports)
        .where('status', whereIn: [
          AppConstants.statusReviewing,
          AppConstants.statusResolved,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ReportModel.fromFirestore).toList());
  }

  Stream<List<ReportModel>> allReportsStream() {
    return _db
        .collection(AppConstants.collectionReports)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReportModel.fromFirestore).toList());
  }

  Stream<List<ReportModel>> userReportsStream(String uid) {
    return _db
        .collection(AppConstants.collectionReports)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ReportModel.fromFirestore).toList());
  }

  Future<void> confirmReport(String reportId) async {
    await _db
        .collection(AppConstants.collectionReports)
        .doc(reportId)
        .update({'confirmations': FieldValue.increment(1)});
  }

  // ── Schedules ──────────────────────────────────────────────────────────────

  Future<ScheduleModel?> getSchedule(String zoneDocId) async {
    final doc = await _db
        .collection(AppConstants.collectionSchedules)
        .doc(zoneDocId)
        .get();
    if (!doc.exists) return null;
    return ScheduleModel.fromFirestore(doc);
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    final snap = await _db
        .collection(AppConstants.collectionSchedules)
        .get();
    return snap.docs.map(ScheduleModel.fromFirestore).toList();
  }
}
