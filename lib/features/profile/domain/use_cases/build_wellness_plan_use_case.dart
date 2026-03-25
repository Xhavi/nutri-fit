import '../../services/wellness_calculation_service.dart';
import '../models/health_profile_models.dart';

class BuildWellnessPlanUseCase {
  BuildWellnessPlanUseCase({required WellnessCalculationService service})
    : _service = service;

  final WellnessCalculationService _service;

  WellnessCalculationResult execute(WellnessProfile profile) {
    return _service.calculate(profile);
  }
}
