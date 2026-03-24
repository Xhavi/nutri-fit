import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatIsoDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
