import '../contracts/health_data_source.dart';
import '../contracts/health_permission_service.dart';
import '../models/health_data_models.dart';

class HealthIntegrationService {
  HealthIntegrationService({
    required HealthDataSource dataSource,
    required HealthPermissionService permissionService,
  }) : _dataSource = dataSource,
       _permissionService = permissionService;

  final HealthDataSource _dataSource;
  final HealthPermissionService _permissionService;

  Future<HealthDataBundle> readAvailableHealthData({
    required DateTime start,
    required DateTime end,
    Set<HealthMetricType> preferredMetrics = const <HealthMetricType>{
      HealthMetricType.steps,
      HealthMetricType.weight,
      HealthMetricType.activityMinutes,
    },
    bool requestIfNeeded = false,
  }) async {
    final Map<HealthMetricType, HealthPermissionStatus> currentStatus =
        await _permissionService.getPermissionStatus(preferredMetrics);

    final Set<HealthMetricType> readableMetrics = _readableMetrics(currentStatus);
    if (readableMetrics.isEmpty && requestIfNeeded) {
      final Map<HealthMetricType, HealthPermissionStatus> requestedStatus =
          await _permissionService.requestPermissions(preferredMetrics);
      readableMetrics.addAll(_readableMetrics(requestedStatus));
    }

    if (readableMetrics.isEmpty) {
      return const HealthDataBundle();
    }

    return _dataSource.readHealthData(
      HealthReadRequest(start: start, end: end, metrics: readableMetrics),
    );
  }

  Set<HealthMetricType> _readableMetrics(
    Map<HealthMetricType, HealthPermissionStatus> permissionMap,
  ) {
    return permissionMap.entries
        .where((MapEntry<HealthMetricType, HealthPermissionStatus> entry) {
          return entry.value == HealthPermissionStatus.granted;
        })
        .map((MapEntry<HealthMetricType, HealthPermissionStatus> entry) => entry.key)
        .toSet();
  }
}
