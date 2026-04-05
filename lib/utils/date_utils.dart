import 'package:intl/intl.dart';

class DateUtils {
  static String getTodayKey() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
