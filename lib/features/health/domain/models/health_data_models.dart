enum HealthPermissionStatus { granted, denied, restricted, notDetermined, unsupported }

enum HealthMetricType { steps, weight, activityMinutes }

class HealthReadRequest {
  const HealthReadRequest({
    required this.start,
    required this.end,
    required this.metrics,
  });

  final DateTime start;
  final DateTime end;
  final Set<HealthMetricType> metrics;
}

class HealthStepsSample {
  const HealthStepsSample({
    required this.timestamp,
    required this.steps,
    required this.source,
  });

  final DateTime timestamp;
  final int steps;
  final String source;
}

class HealthWeightSample {
  const HealthWeightSample({
    required this.timestamp,
    required this.weightKg,
    required this.source,
  });

  final DateTime timestamp;
  final double weightKg;
  final String source;
}

class HealthActivitySample {
  const HealthActivitySample({
    required this.timestamp,
    required this.activeMinutes,
    required this.source,
  });

  final DateTime timestamp;
  final int activeMinutes;
  final String source;
}

class HealthDataBundle {
  const HealthDataBundle({
    this.steps = const <HealthStepsSample>[],
    this.weights = const <HealthWeightSample>[],
    this.activities = const <HealthActivitySample>[],
  });

  final List<HealthStepsSample> steps;
  final List<HealthWeightSample> weights;
  final List<HealthActivitySample> activities;

  bool get isEmpty => steps.isEmpty && weights.isEmpty && activities.isEmpty;
}
