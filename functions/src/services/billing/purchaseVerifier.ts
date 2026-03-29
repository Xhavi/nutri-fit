import { PlanId, SubscriptionStatus } from '../../contracts/subscription';

export interface PurchaseVerificationInput {
  readonly provider: 'app_store' | 'play_store' | 'stripe';
  readonly receiptToken: string;
  readonly userId: string;
}

export interface PurchaseVerificationResult {
  readonly planId: PlanId;
  readonly status: SubscriptionStatus;
  readonly providerSubscriptionId?: string;
  readonly currentPeriodStartAt?: string;
  readonly currentPeriodEndAt?: string;
}

export interface PurchaseVerifier {
  verify(input: PurchaseVerificationInput): Promise<PurchaseVerificationResult>;
}

export class NotImplementedPurchaseVerifier implements PurchaseVerifier {
  async verify(_input: PurchaseVerificationInput): Promise<PurchaseVerificationResult> {
    throw new Error('Purchase verification adapter not implemented yet.');
  }
}
