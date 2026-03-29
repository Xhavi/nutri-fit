import { FeatureKey, PlanDefinition, PlanId } from '../../contracts/subscription';

const PLAN_CATALOG: Record<PlanId, PlanDefinition> = {
  free: {
    id: 'free',
    displayName: 'Base gratis',
    features: {
      ai_chat: { enabled: false, monthlyQuota: 0 },
      ai_voice: { enabled: false, monthlyQuota: 0 },
    },
  },
  premium_ai_monthly: {
    id: 'premium_ai_monthly',
    displayName: 'Premium IA mensual',
    features: {
      ai_chat: { enabled: true, monthlyQuota: 300 },
      ai_voice: { enabled: false, monthlyQuota: 0 },
    },
  },
};

export function getPlanDefinition(planId: PlanId): PlanDefinition {
  return PLAN_CATALOG[planId] ?? PLAN_CATALOG.free;
}

export function getPlanCatalog(): Record<PlanId, PlanDefinition> {
  return PLAN_CATALOG;
}

export function getFeatureQuota(planId: PlanId, feature: FeatureKey): number {
  return getPlanDefinition(planId).features[feature].monthlyQuota;
}
