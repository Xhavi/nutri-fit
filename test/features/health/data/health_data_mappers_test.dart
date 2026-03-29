import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/features/health/data/mappers/health_data_mappers.dart';

void main() {
  group('HealthDataMappers', () {
    test('toStepSamples maps valid samples and filters invalid values', () {
      final List<Map<String, Object?>> raw = <Map<String, Object?>>[
        <String, Object?>{'timestamp': '2026-03-29T10:00:00Z', 'value': 3000, 'source': 'device'},
        <String, Object?>{'timestamp': 'invalid-date', 'value': 1200, 'source': 'device'},
      ];

      final samples = HealthDataMappers.toStepSamples(raw);

      expect(samples, hasLength(1));
      expect(samples.first.steps, 3000);
      expect(samples.first.source, 'device');
    });

    test('toWeightSamples parses numeric values from String and int', () {
      final List<Map<String, Object?>> raw = <Map<String, Object?>>[
        <String, Object?>{'timestamp': 1711706400000, 'value': '72.5'},
        <String, Object?>{'timestamp': 1711706400000, 'value': 70},
      ];

      final samples = HealthDataMappers.toWeightSamples(raw);

      expect(samples, hasLength(2));
      expect(samples.first.weightKg, 72.5);
      expect(samples.last.weightKg, 70.0);
    });

    test('toActivitySamples rounds doubles and ignores missing timestamp', () {
      final List<Map<String, Object?>> raw = <Map<String, Object?>>[
        <String, Object?>{'timestamp': '2026-03-29T10:00:00Z', 'value': 41.6},
        <String, Object?>{'value': 12},
      ];

      final samples = HealthDataMappers.toActivitySamples(raw);

      expect(samples, hasLength(1));
      expect(samples.first.activeMinutes, 42);
      expect(samples.first.source, 'unknown');
    });
  });
}
