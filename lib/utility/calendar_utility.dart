import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CalendarUtility {
  static String dateNow() {
    return DateTime.now().toString().substring(0, 10);
  }

  static Future<void> init() async {
    await initializeDateFormatting('id_ID', null);
  }

  static String formatBasic(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID');
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
}
