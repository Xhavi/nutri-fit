import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('normalizeDate removes hour and minutes', () {
      final DateTime raw = DateTime(2026, 3, 29, 23, 45, 10);

      final DateTime normalized = DateTimeUtils.normalizeDate(raw);

      expect(normalized, DateTime(2026, 3, 29));
    });

    test('formatIsoDate returns yyyy-MM-dd format with zero padding', () {
      final DateTime raw = DateTime(2026, 1, 5, 10, 30);

      final String isoDate = DateTimeUtils.formatIsoDate(raw);

      expect(isoDate, '2026-01-05');
    });
  });
}
