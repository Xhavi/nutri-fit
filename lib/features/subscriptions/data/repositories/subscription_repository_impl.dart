import '../../domain/models/entitlement_status.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../adapters/billing_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required BillingDataSource billingDataSource})
      : _billingDataSource = billingDataSource;

  final BillingDataSource _billingDataSource;

  @override
  Future<void> initialize() => _billingDataSource.initialize();

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() => _billingDataSource.getMonthlyPlan();

  @override
  Future<EntitlementStatus> getEntitlementStatus() =>
      _billingDataSource.getEntitlementStatus();

  @override
  Stream<EntitlementStatus> watchEntitlementStatus() =>
      _billingDataSource.watchEntitlementStatus();

  @override
  Future<bool> purchaseMonthlyPlan() async {
    final SubscriptionPlan? plan = await getMonthlyPlan();
    if (plan == null) {
      return false;
    }

    return _billingDataSource.purchaseMonthlyPlan(plan);
  }

  @override
  Future<void> restorePurchases() => _billingDataSource.restorePurchases();

  @override
  Future<void> dispose() => _billingDataSource.dispose();
}
