import { getFirestore } from 'firebase-admin/firestore';
import {
  Entitlement,
  FeatureKey,
  MonthlyUsageCounter,
  PlanId,
  SubscriptionRecord,
  SubscriptionStatus,
} from '../../contracts/subscription';
import { getPlanDefinition } from './planCatalog';

const SUBSCRIPTIONS_COLLECTION = 'subscriptions';
const MONTHLY_USAGE_COLLECTION = 'monthlyUsageCounters';

function buildPlanEntitlements(planId: PlanId): Record<FeatureKey, Entitlement> {
  const plan = getPlanDefinition(planId);

  return {
    ai_chat: {
      feature: 'ai_chat',
      enabled: plan.features.ai_chat.enabled,
      source: 'plan',
    },
    ai_voice: {
      feature: 'ai_voice',
      enabled: plan.features.ai_voice.enabled,
      source: 'plan',
    },
  };
}

function toIsoNow(): string {
  return new Date().toISOString();
}

function usageDocId(userId: string, monthKey: string): string {
  return `${userId}_${monthKey}`;
}

export function getMonthKey(date = new Date()): string {
  const month = `${date.getUTCMonth() + 1}`.padStart(2, '0');
  return `${date.getUTCFullYear()}-${month}`;
}

export async function getOrCreateSubscription(userId: string): Promise<SubscriptionRecord> {
  const db = getFirestore();
  const ref = db.collection(SUBSCRIPTIONS_COLLECTION).doc(userId);
  const snapshot = await ref.get();

  if (snapshot.exists) {
    return snapshot.data() as SubscriptionRecord;
  }

  const now = toIsoNow();
  const created: SubscriptionRecord = {
    userId,
    planId: 'free',
    status: 'inactive',
    provider: 'unknown',
    updatedAt: now,
    entitlements: buildPlanEntitlements('free'),
  };

  await ref.set(created);
  return created;
}

export async function upsertSubscription(
  userId: string,
  payload: {
    planId: PlanId;
    status: SubscriptionStatus;
    provider: 'unknown' | 'app_store' | 'play_store' | 'stripe';
    providerProductId?: string;
    providerSubscriptionId?: string;
    currentPeriodStartAt?: string;
    currentPeriodEndAt?: string;
    canceledAt?: string;
    entitlementOverrides?: Partial<Record<FeatureKey, boolean>>;
  },
): Promise<SubscriptionRecord> {
  const db = getFirestore();
  const ref = db.collection(SUBSCRIPTIONS_COLLECTION).doc(userId);

  const baseEntitlements = buildPlanEntitlements(payload.planId);
  const entitlements: Record<FeatureKey, Entitlement> = {
    ai_chat: baseEntitlements.ai_chat,
    ai_voice: baseEntitlements.ai_voice,
  };

  if (typeof payload.entitlementOverrides?.ai_chat === 'boolean') {
    entitlements.ai_chat = {
      feature: 'ai_chat',
      enabled: payload.entitlementOverrides.ai_chat,
      source: 'override',
      reason: 'manual_override',
    };
  }

  if (typeof payload.entitlementOverrides?.ai_voice === 'boolean') {
    entitlements.ai_voice = {
      feature: 'ai_voice',
      enabled: payload.entitlementOverrides.ai_voice,
      source: 'override',
      reason: 'manual_override',
    };
  }

  const record: SubscriptionRecord = {
    userId,
    planId: payload.planId,
    status: payload.status,
    provider: payload.provider,
    providerProductId: payload.providerProductId,
    providerSubscriptionId: payload.providerSubscriptionId,
    currentPeriodStartAt: payload.currentPeriodStartAt,
    currentPeriodEndAt: payload.currentPeriodEndAt,
    canceledAt: payload.canceledAt,
    updatedAt: toIsoNow(),
    entitlements,
  };

  await ref.set(record, { merge: true });
  return record;
}

export async function getOrCreateMonthlyUsageCounter(
  userId: string,
  monthKey: string,
): Promise<MonthlyUsageCounter> {
  const db = getFirestore();
  const docId = usageDocId(userId, monthKey);
  const ref = db.collection(MONTHLY_USAGE_COLLECTION).doc(docId);
  const snapshot = await ref.get();

  if (snapshot.exists) {
    return snapshot.data() as MonthlyUsageCounter;
  }

  const counter: MonthlyUsageCounter = {
    userId,
    monthKey,
    used: {
      ai_chat: 0,
      ai_voice: 0,
    },
    updatedAt: toIsoNow(),
  };

  await ref.set(counter);
  return counter;
}

export async function incrementMonthlyUsage(
  userId: string,
  monthKey: string,
  feature: FeatureKey,
  amount: number,
): Promise<MonthlyUsageCounter> {
  const db = getFirestore();
  const docId = usageDocId(userId, monthKey);
  const ref = db.collection(MONTHLY_USAGE_COLLECTION).doc(docId);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const base = snapshot.exists ? (snapshot.data() as MonthlyUsageCounter) : {
      userId,
      monthKey,
      used: { ai_chat: 0, ai_voice: 0 },
    };

    const nextValue = Math.max(0, (base.used[feature] ?? 0) + amount);
    transaction.set(
      ref,
      {
        userId,
        monthKey,
        used: {
          ai_chat: feature === 'ai_chat' ? nextValue : (base.used.ai_chat ?? 0),
          ai_voice: feature === 'ai_voice' ? nextValue : (base.used.ai_voice ?? 0),
        },
        updatedAt: toIsoNow(),
      },
      { merge: true },
    );
  });

  const snapshot = await ref.get();
  return snapshot.data() as MonthlyUsageCounter;
}
