export type PlanId = 'free' | 'premium_ai_monthly';
export type SubscriptionStatus =
  | 'inactive'
  | 'trialing'
  | 'active'
  | 'past_due'
  | 'canceled'
  | 'expired';

export type FeatureKey = 'ai_chat' | 'ai_voice';

export interface PlanFeature {
  readonly enabled: boolean;
  readonly monthlyQuota: number;
}

export interface PlanDefinition {
  readonly id: PlanId;
  readonly displayName: string;
  readonly features: Record<FeatureKey, PlanFeature>;
}

export interface Entitlement {
  readonly feature: FeatureKey;
  readonly enabled: boolean;
  readonly source: 'plan' | 'override';
  readonly reason?: string;
}

export interface SubscriptionRecord {
  readonly userId: string;
  readonly planId: PlanId;
  readonly status: SubscriptionStatus;
  readonly provider: 'unknown' | 'app_store' | 'play_store' | 'stripe';
  readonly providerProductId?: string;
  readonly providerSubscriptionId?: string;
  readonly currentPeriodStartAt?: string;
  readonly currentPeriodEndAt?: string;
  readonly canceledAt?: string;
  readonly updatedAt: string;
  readonly entitlements: Record<FeatureKey, Entitlement>;
}

export interface MonthlyUsageCounter {
  readonly userId: string;
  readonly monthKey: string;
  readonly used: Record<FeatureKey, number>;
  readonly updatedAt: string;
}

export interface FeatureAccessResult {
  readonly allowed: boolean;
  readonly planId: PlanId;
  readonly status: SubscriptionStatus;
  readonly monthKey: string;
  readonly quota: number;
  readonly used: number;
  readonly remaining: number;
  readonly reason?: string;
}
