import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CalendarUtility {
  static String dateNow() {
    return DateTime.now().toLocal().toString().substring(0, 10);
  }

  static String dateNow2() {
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(DateTime.now().toLocal());
  }

  static String dateNow3() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'id_ID');
    return formatter.format(DateTime.now().toLocal()).toString();
  }

  static Future<void> init() async {
    await initializeDateFormatting('id_ID', null);
  }

  static String formatBasic(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID');
    return formatter.format(date);
  }

  static String formatBasic2(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  static String formatDB(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'id_ID');
    return formatter.format(date);
  }

  static String formatDB2(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd', 'id_ID');
    return "${formatter.format(date)} 00:00:00";
  }

  static String formatDB3(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd', 'id_ID');
    return formatter.format(date);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('d MMM y', 'id_ID');
    return formatter.format(date);
  }

  static String getTime(DateTime date) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(date);
  }

  static String getIntervalDate(DateTime start, DateTime end) {
    Duration duration = end.difference(start);
    int minutes = duration.inMinutes;
    int hours = duration.inHours;

    // Mengembalikan selisih waktu dalam menit dan jam
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      return '$hours jam';
    }
  }

  static String formatOvertimeInterval(
      String? overtimeStartAt, String? overtimeEndAt) {
    if (overtimeStartAt != null && overtimeEndAt != null) {
      DateTime start = DateTime.parse(overtimeStartAt).toLocal();
      DateTime end = DateTime.parse(overtimeEndAt).toLocal();
      String interval = getIntervalDate(start, end);
      return "($interval)";
    } else {
      return "";
    }
  }
}
