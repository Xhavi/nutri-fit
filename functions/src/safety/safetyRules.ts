export interface SafetySignals {
  containsSensitiveContent: boolean;
  escalationRecommended: boolean;
}

const SENSITIVE_PATTERNS: RegExp[] = [
  /suicid/i,
  /self[-\s]?harm/i,
  /eating\s+disorder/i,
  /purge|vomit\s+after\s+eat/i,
  /faint|dizzy|chest\s+pain/i,
  /stop\s+medication/i,
  /extreme\s+fast/i,
  /laxative\s+abuse/i,
];

export function detectSafetySignals(message: string): SafetySignals {
  const containsSensitiveContent = SENSITIVE_PATTERNS.some((pattern) => pattern.test(message));

  return {
    containsSensitiveContent,
    escalationRecommended: containsSensitiveContent,
  };
}

export function safetyDisclaimerText(): string {
  return 'Esta guía es informativa de bienestar y no reemplaza atención médica profesional.';
}
