import 'package:flutter/services.dart';

import '../../domain/contracts/health_data_source.dart';
import '../../domain/models/health_data_models.dart';
import '../mappers/health_data_mappers.dart';

class PlatformHealthDataSource implements HealthDataSource {
  PlatformHealthDataSource({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_healthDataChannelName);

  static const String _healthDataChannelName = 'nutri_fit/health_data';

  final MethodChannel _channel;

  @override
  Future<HealthDataBundle> readHealthData(HealthReadRequest request) async {
    try {
      final Map<dynamic, dynamic>? rawResponse = await _channel.invokeMapMethod<dynamic, dynamic>(
        'readHealthData',
        <String, Object?>{
          'start': request.start.toUtc().toIso8601String(),
          'end': request.end.toUtc().toIso8601String(),
          'metrics': request.metrics.map(_metricToWire).toList(growable: false),
        },
      );

      if (rawResponse == null) {
        return const HealthDataBundle();
      }

      final List<Map<String, Object?>> rawSteps = _extractSamples(rawResponse['steps']);
      final List<Map<String, Object?>> rawWeights = _extractSamples(rawResponse['weights']);
      final List<Map<String, Object?>> rawActivities = _extractSamples(rawResponse['activities']);

      return HealthDataBundle(
        steps: request.metrics.contains(HealthMetricType.steps)
            ? HealthDataMappers.toStepSamples(rawSteps)
            : const <HealthStepsSample>[],
        weights: request.metrics.contains(HealthMetricType.weight)
            ? HealthDataMappers.toWeightSamples(rawWeights)
            : const <HealthWeightSample>[],
        activities: request.metrics.contains(HealthMetricType.activityMinutes)
            ? HealthDataMappers.toActivitySamples(rawActivities)
            : const <HealthActivitySample>[],
      );
    } on MissingPluginException {
      return const HealthDataBundle();
    } on PlatformException {
      return const HealthDataBundle();
    }
  }

  List<Map<String, Object?>> _extractSamples(Object? rawValue) {
    if (rawValue is! List<dynamic>) {
      return const <Map<String, Object?>>[];
    }

    return rawValue.whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> item) {
      return item.map<String, Object?>((dynamic key, dynamic value) {
        return MapEntry<String, Object?>(key.toString(), value as Object?);
      });
    }).toList(growable: false);
  }

  String _metricToWire(HealthMetricType metric) {
    switch (metric) {
      case HealthMetricType.steps:
        return 'steps';
      case HealthMetricType.weight:
        return 'weight';
      case HealthMetricType.activityMinutes:
        return 'activityMinutes';
    }
  }
}
