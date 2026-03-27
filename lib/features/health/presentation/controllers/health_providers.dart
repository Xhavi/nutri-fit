import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/adapters/platform_health_data_source.dart';
import '../../data/services/platform_health_permission_service.dart';
import '../../domain/contracts/health_data_source.dart';
import '../../domain/contracts/health_permission_service.dart';
import '../../domain/services/health_integration_service.dart';

final Provider<HealthDataSource> healthDataSourceProvider = Provider<HealthDataSource>(
  (Ref ref) => PlatformHealthDataSource(),
);

final Provider<HealthPermissionService> healthPermissionServiceProvider =
    Provider<HealthPermissionService>((Ref ref) => PlatformHealthPermissionService());

final Provider<HealthIntegrationService> healthIntegrationServiceProvider =
    Provider<HealthIntegrationService>(
      (Ref ref) => HealthIntegrationService(
        dataSource: ref.watch(healthDataSourceProvider),
        permissionService: ref.watch(healthPermissionServiceProvider),
      ),
    );
