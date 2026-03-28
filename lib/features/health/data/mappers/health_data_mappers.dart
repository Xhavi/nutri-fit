import '../../domain/models/health_data_models.dart';

class HealthDataMappers {
  const HealthDataMappers._();

  static List<HealthStepsSample> toStepSamples(List<Map<String, Object?>> rawSamples) {
    return rawSamples
        .map<HealthStepsSample?>((Map<String, Object?> raw) {
          final DateTime? timestamp = _parseDateTime(raw['timestamp']);
          final int? steps = _toInt(raw['value']);
          if (timestamp == null || steps == null) {
            return null;
          }

          return HealthStepsSample(
            timestamp: timestamp,
            steps: steps,
            source: (raw['source'] as String?) ?? 'unknown',
          );
        })
        .whereType<HealthStepsSample>()
        .toList(growable: false);
  }

  static List<HealthWeightSample> toWeightSamples(List<Map<String, Object?>> rawSamples) {
    return rawSamples
        .map<HealthWeightSample?>((Map<String, Object?> raw) {
          final DateTime? timestamp = _parseDateTime(raw['timestamp']);
          final double? weightKg = _toDouble(raw['value']);
          if (timestamp == null || weightKg == null) {
            return null;
          }

          return HealthWeightSample(
            timestamp: timestamp,
            weightKg: weightKg,
            source: (raw['source'] as String?) ?? 'unknown',
          );
        })
        .whereType<HealthWeightSample>()
        .toList(growable: false);
  }

  static List<HealthActivitySample> toActivitySamples(List<Map<String, Object?>> rawSamples) {
    return rawSamples
        .map<HealthActivitySample?>((Map<String, Object?> raw) {
          final DateTime? timestamp = _parseDateTime(raw['timestamp']);
          final int? activeMinutes = _toInt(raw['value']);
          if (timestamp == null || activeMinutes == null) {
            return null;
          }

          return HealthActivitySample(
            timestamp: timestamp,
            activeMinutes: activeMinutes,
            source: (raw['source'] as String?) ?? 'unknown',
          );
        })
        .whereType<HealthActivitySample>()
        .toList(growable: false);
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static int? _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _toDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
