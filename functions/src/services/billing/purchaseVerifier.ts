import { PlanId, SubscriptionStatus } from '../../contracts/subscription';

export interface PurchaseVerificationInput {
  readonly provider: 'app_store' | 'play_store' | 'stripe';
  readonly receiptToken: string;
  readonly userId: string;
  readonly productId?: string;
  readonly orderId?: string;
}

export interface PurchaseVerificationResult {
  readonly planId: PlanId;
  readonly status: SubscriptionStatus;
  readonly providerProductId?: string;
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

export class PlayDeveloperApiPurchaseVerifier implements PurchaseVerifier {
  async verify(_input: PurchaseVerificationInput): Promise<PurchaseVerificationResult> {
    // TODO(google-play-production):
    // 1) Configure service account with Android Publisher API access.
    // 2) Read packageName + subscriptionId/basePlanId from secure env.
    // 3) Call purchases.subscriptionsv2.get with purchase token.
    // 4) Map Google states to SubscriptionStatus.
    // 5) Verify product and account binding before activation.
    throw new Error('Google Play Developer API verifier is not configured yet.');
  }
}
