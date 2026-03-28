import '../models/health_data_models.dart';

abstract class HealthPermissionService {
  Future<Map<HealthMetricType, HealthPermissionStatus>> getPermissionStatus(
    Set<HealthMetricType> metrics,
  );

  Future<Map<HealthMetricType, HealthPermissionStatus>> requestPermissions(
    Set<HealthMetricType> metrics,
  );
}
