import { HttpsError } from 'firebase-functions/https';
import { FeatureAccessResult, FeatureKey, SubscriptionRecord } from '../../contracts/subscription';
import { getFeatureQuota, getPlanCatalog } from './planCatalog';
import {
  getMonthKey,
  getOrCreateMonthlyUsageCounter,
  getOrCreateSubscription,
  incrementMonthlyUsage,
} from './subscriptionRepository';

function isSubscriptionActive(subscription: SubscriptionRecord): boolean {
  return subscription.status === 'active' || subscription.status === 'trialing';
}

export async function getUserPlanStatus(userId: string): Promise<{
  subscription: SubscriptionRecord;
  planCatalog: ReturnType<typeof getPlanCatalog>;
  monthKey: string;
  usage: Record<FeatureKey, number>;
}> {
  const subscription = await getOrCreateSubscription(userId);
  const monthKey = getMonthKey();
  const usageCounter = await getOrCreateMonthlyUsageCounter(userId, monthKey);

  return {
    subscription,
    planCatalog: getPlanCatalog(),
    monthKey,
    usage: usageCounter.used,
  };
}

export async function validateFeatureAccess(
  userId: string,
  feature: FeatureKey,
): Promise<FeatureAccessResult> {
  const subscription = await getOrCreateSubscription(userId);
  const monthKey = getMonthKey();
  const usageCounter = await getOrCreateMonthlyUsageCounter(userId, monthKey);
  const entitlement = subscription.entitlements[feature];

  if (!entitlement?.enabled) {
    return {
      allowed: false,
      planId: subscription.planId,
      status: subscription.status,
      monthKey,
      quota: 0,
      used: usageCounter.used[feature] ?? 0,
      remaining: 0,
      reason: 'feature_not_entitled',
    };
  }

  if (!isSubscriptionActive(subscription)) {
    return {
      allowed: false,
      planId: subscription.planId,
      status: subscription.status,
      monthKey,
      quota: 0,
      used: usageCounter.used[feature] ?? 0,
      remaining: 0,
      reason: 'subscription_not_active',
    };
  }

  const quota = getFeatureQuota(subscription.planId, feature);
  const used = usageCounter.used[feature] ?? 0;
  const remaining = Math.max(0, quota - used);

  if (remaining <= 0) {
    return {
      allowed: false,
      planId: subscription.planId,
      status: subscription.status,
      monthKey,
      quota,
      used,
      remaining,
      reason: 'monthly_quota_exceeded',
    };
  }

  return {
    allowed: true,
    planId: subscription.planId,
    status: subscription.status,
    monthKey,
    quota,
    used,
    remaining,
  };
}

export async function registerFeatureUsage(
  userId: string,
  feature: FeatureKey,
  amount: number,
): Promise<FeatureAccessResult> {
  if (amount <= 0) {
    throw new HttpsError('invalid-argument', 'Usage amount must be greater than 0.');
  }

  const access = await validateFeatureAccess(userId, feature);

  if (!access.allowed) {
    return access;
  }

  const counter = await incrementMonthlyUsage(userId, access.monthKey, feature, amount);
  const used = counter.used[feature] ?? 0;
  const remaining = Math.max(0, access.quota - used);

  return {
    ...access,
    used,
    remaining,
    allowed: remaining >= 0,
  };
}

export function assertAuthenticatedUser(userId?: string): string {
  if (!userId) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }
  return userId;
}
