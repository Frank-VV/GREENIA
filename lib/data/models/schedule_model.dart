import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String zoneName;
  final String timeStart;
  final String timeEnd;
  final List<int> daysOfWeek;
  final List<String> wasteTypes;

  const ScheduleModel({
    required this.id,
    required this.zoneName,
    required this.timeStart,
    required this.timeEnd,
    required this.daysOfWeek,
    required this.wasteTypes,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScheduleModel(
      id: doc.id,
      zoneName: data['zoneName'] as String? ?? '',
      timeStart: data['timeStart'] as String? ?? '07:00',
      timeEnd: data['timeEnd'] as String? ?? '09:00',
      daysOfWeek: List<int>.from(data['daysOfWeek'] as List? ?? []),
      wasteTypes: List<String>.from(data['wasteTypes'] as List? ?? []),
    );
  }

  String get scheduleRange => '$timeStart – $timeEnd';
}
