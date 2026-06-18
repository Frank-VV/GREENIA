import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static const List<String> _dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  static const List<String> _fullDayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
  static const List<String> _monthNames = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String timeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'hace ${diff.inDays ~/ 7} sem';
    if (diff.inDays < 365) return 'hace ${diff.inDays ~/ 30} meses';
    return 'hace ${diff.inDays ~/ 365} años';
  }

  static String formatDate(DateTime date) {
    return '${date.day} de ${_monthNames[date.month - 1]} de ${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String dayShortName(int dayIndex) {
    // dayIndex: 1=Dom, 2=Lun, ... 7=Sáb
    if (dayIndex < 1 || dayIndex > 7) return '';
    return _dayNames[dayIndex - 1];
  }

  static String dayFullName(int dayIndex) {
    if (dayIndex < 1 || dayIndex > 7) return '';
    return _fullDayNames[dayIndex - 1];
  }

  // Flutter's weekday: 1=Mon...7=Sun → convert to app format (1=Dom...7=Sáb)
  static int flutterWeekdayToApp(int flutterWeekday) {
    // Flutter: Mon=1, Tue=2, ..., Sun=7
    // App:     Dom=1, Lun=2, ..., Sáb=7
    return flutterWeekday % 7 + 1;
  }

  static bool isCollectionDay(List<int> daysOfWeek) {
    final today = flutterWeekdayToApp(DateTime.now().weekday);
    return daysOfWeek.contains(today);
  }

  static DateTime? nextCollectionDate(List<int> daysOfWeek) {
    if (daysOfWeek.isEmpty) return null;
    final now = DateTime.now();
    for (int i = 0; i <= 7; i++) {
      final candidate = now.add(Duration(days: i));
      final appDay = flutterWeekdayToApp(candidate.weekday);
      if (daysOfWeek.contains(appDay)) {
        return candidate;
      }
    }
    return null;
  }

  static Duration? countdownToCollection(String timeStart) {
    final parts = timeStart.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
