import '../models/health_data_models.dart';

abstract class HealthDataSource {
  Future<HealthDataBundle> readHealthData(HealthReadRequest request);
}
