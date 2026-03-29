import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static DateTime normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String formatIsoDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(normalizeDate(dateTime));
  }
}
