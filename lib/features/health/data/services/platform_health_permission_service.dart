import 'package:flutter/services.dart';

import '../../domain/contracts/health_permission_service.dart';
import '../../domain/models/health_data_models.dart';

class PlatformHealthPermissionService implements HealthPermissionService {
  PlatformHealthPermissionService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_permissionsChannelName);

  static const String _permissionsChannelName = 'nutri_fit/health_permissions';

  final MethodChannel _channel;

  @override
  Future<Map<HealthMetricType, HealthPermissionStatus>> getPermissionStatus(
    Set<HealthMetricType> metrics,
  ) async {
    try {
      final List<String> metricKeys = metrics.map(_metricToWire).toList(growable: false);
      final Map<dynamic, dynamic>? rawResponse = await _channel.invokeMapMethod<dynamic, dynamic>(
        'getPermissionStatus',
        <String, Object?>{'metrics': metricKeys},
      );

      return _toPermissionMap(rawResponse, metrics);
    } on MissingPluginException {
      return _unsupported(metrics);
    } on PlatformException {
      return _unsupported(metrics);
    }
  }

  @override
  Future<Map<HealthMetricType, HealthPermissionStatus>> requestPermissions(
    Set<HealthMetricType> metrics,
  ) async {
    try {
      final List<String> metricKeys = metrics.map(_metricToWire).toList(growable: false);
      final Map<dynamic, dynamic>? rawResponse = await _channel.invokeMapMethod<dynamic, dynamic>(
        'requestPermissions',
        <String, Object?>{'metrics': metricKeys},
      );

      return _toPermissionMap(rawResponse, metrics);
    } on MissingPluginException {
      return _unsupported(metrics);
    } on PlatformException {
      return _unsupported(metrics);
    }
  }

  Map<HealthMetricType, HealthPermissionStatus> _toPermissionMap(
    Map<dynamic, dynamic>? raw,
    Set<HealthMetricType> requestedMetrics,
  ) {
    if (raw == null) {
      return _unsupported(requestedMetrics);
    }

    final Map<HealthMetricType, HealthPermissionStatus> mapped =
        <HealthMetricType, HealthPermissionStatus>{};
    for (final HealthMetricType metric in requestedMetrics) {
      final String key = _metricToWire(metric);
      final String? rawStatus = raw[key] as String?;
      mapped[metric] = _statusFromWire(rawStatus);
    }
    return mapped;
  }

  Map<HealthMetricType, HealthPermissionStatus> _unsupported(Set<HealthMetricType> metrics) {
    return <HealthMetricType, HealthPermissionStatus>{
      for (final HealthMetricType metric in metrics)
        metric: HealthPermissionStatus.unsupported,
    };
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

  HealthPermissionStatus _statusFromWire(String? value) {
    switch (value) {
      case 'granted':
        return HealthPermissionStatus.granted;
      case 'denied':
        return HealthPermissionStatus.denied;
      case 'restricted':
        return HealthPermissionStatus.restricted;
      case 'notDetermined':
        return HealthPermissionStatus.notDetermined;
      default:
        return HealthPermissionStatus.unsupported;
    }
  }
}
