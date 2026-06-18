import '../models/schedule_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/san_jeronimo_data.dart';

class ScheduleRepository {
  final FirestoreService _firestore = FirestoreService();

  Future<ScheduleModel?> getScheduleForZone(String zoneName) async {
    final docId = kZoneToDocId[zoneName];
    if (docId == null) return null;
    return _firestore.getSchedule(docId);
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    return _firestore.getAllSchedules();
  }
}
